# 07_p3_mls_mechanism.R
# Proposition 3 mechanism test using Song's MLS/MLA evidence.
#
# This script does two things:
#   1. Always summarizes the included Song output tables that are relevant for P3.
#   2. If the excluded CBG-level MLA intermediate file exists, runs a Dallas
#      station-area mechanism test:
#        log(density) ~ log(MLA) * near_DART + controls.

suppressPackageStartupMessages({
  library(data.table)
  library(sf)
})

ROOT <- normalizePath(file.path(getwd()), mustWork = TRUE)
SONG <- file.path(ROOT, "data", "song_mls_estimator", "231447-V1")
OUT  <- file.path(ROOT, "results")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

song_out <- file.path(SONG, "output")

read_if_exists <- function(path) {
  if (!file.exists(path)) return(NULL)
  fread(path)
}

star <- function(coef, se) {
  t <- abs(coef / se)
  fifelse(t > 2.58, "***", fifelse(t > 1.96, "**", fifelse(t > 1.65, "*", "")))
}

# ---------------------------------------------------------------------------
# 1. Evidence available in the included Song output tables
# ---------------------------------------------------------------------------

reg_by_mla <- read_if_exists(file.path(song_out, "reg_by_mla.csv"))
reg_bldg   <- read_if_exists(file.path(song_out, "reg_bldg_chars.csv"))

evidence <- data.table()

if (!is.null(reg_by_mla)) {
  price_rows <- reg_by_mla[
    y_var == "LOG_PRICE" & x_var == "mla_est_post40" & spec == 11,
    .(
      evidence = fifelse(data == "deed", "Sale price", "Rental listing price"),
      data,
      coefficient = coef,
      se
    )
  ]
  evidence <- rbind(evidence, price_rows, fill = TRUE)
}

if (!is.null(reg_bldg)) {
  bldg_rows <- reg_bldg[
    spec == 1 & var %in% c("LOG_land_sqft", "LOG_univ_bldg_sqft"),
    .(
      evidence = fifelse(
        var == "LOG_land_sqft",
        "Lot size",
        "Building square feet"
      ),
      data,
      coefficient = coef,
      se
    )
  ]
  evidence <- rbind(evidence, bldg_rows, fill = TRUE)
}

if (nrow(evidence) > 0) {
  evidence[, `:=`(
    t_stat = coefficient / se,
    stars = star(coefficient, se)
  )]
  fwrite(evidence, file.path(OUT, "p3_mls_existing_evidence.csv"))
  print(evidence)
} else {
  message("No included Song output tables were found.")
}

# ---------------------------------------------------------------------------
# 2. Full station-area MLA test, if CBG-level MLA intermediate exists
# ---------------------------------------------------------------------------

mla_cbg_path <- file.path(SONG, "INT", "mla_est", "by_geo", "mla_stats_cbg_muni.csv")
if (!file.exists(mla_cbg_path)) {
  msg <- paste(
    "Skipped full station-area regression.",
    "Missing excluded Song intermediate:",
    mla_cbg_path
  )
  writeLines(msg, file.path(OUT, "p3_mls_station_area_status.txt"))
  message(msg)
  quit(save = "no", status = 0)
}

cbg_chars_path <- file.path(SONG, "data", "CBG_chars.csv")
cbg_shape_path <- file.path(
  SONG, "data", "map", "cb_2019_us_bg_500k", "cb_2019_us_bg_500k.shp"
)
stations_path <- file.path(ROOT, "NA_Transit", "data", "processed", "stations_us.geojson")

stopifnot(file.exists(cbg_chars_path), file.exists(cbg_shape_path), file.exists(stations_path))

mla <- fread(mla_cbg_path, colClasses = c(cbg_geoid = "character"))
chars <- fread(cbg_chars_path)
chars[, cbg_geoid := substr(GEO_ID, nchar(GEO_ID) - 11, nchar(GEO_ID))]

cbg <- merge(
  mla[, .(
    cbg_geoid,
    N_apn,
    N_apn_built40 = N_apn.built40,
    mla_est = med_mla_post40,
    mla_bunching = N_mla_post40.built40
  )],
  chars,
  by = "cbg_geoid"
)

cbg <- cbg[
  N_apn_built40 >= 100 &
    !is.na(mla_est) &
    mla_est >= 2500 &
    mla_est <= 5 * 43560
]

# Dallas-area counties in the core DFW metro.
dallas_counties <- c(
  "48085", "48113", "48121", "48139", "48231",
  "48251", "48367", "48397", "48439", "48497"
)
cbg[, county_fips := substr(cbg_geoid, 1, 5)]
cbg <- cbg[county_fips %in% dallas_counties]

bg <- st_read(cbg_shape_path, quiet = TRUE)
bg <- bg[bg$GEOID %in% cbg$cbg_geoid, c("GEOID", "ALAND", "geometry")]
bg <- st_transform(bg, 5070)
bg_cent <- st_centroid(bg)

stations <- st_read(stations_path, quiet = TRUE)
stations <- stations[stations$region == "Dallas TX USA", ]
stations <- st_transform(stations, 5070)

near_05 <- lengths(st_is_within_distance(bg_cent, stations, dist = 804.672)) > 0
near_025 <- lengths(st_is_within_distance(bg_cent, stations, dist = 402.336)) > 0
near_1 <- lengths(st_is_within_distance(bg_cent, stations, dist = 1609.344)) > 0
dist_station_m <- as.numeric(st_distance(bg_cent, st_union(stations)))

geo <- data.table(
  cbg_geoid = bg$GEOID,
  land_area_m2 = as.numeric(bg$ALAND),
  near_dart = as.integer(near_05),
  near_dart_025 = as.integer(near_025),
  near_dart_1mi = as.integer(near_1),
  dist_station_m = dist_station_m
)

dt <- merge(cbg, geo, by = "cbg_geoid")
dt[, `:=`(
  log_mla = log(mla_est),
  pop_dens = pop_tot / land_area_m2,
  unit_dens = n_units / land_area_m2,
  log_pop_dens = log(pop_dens),
  log_unit_dens = log(unit_dens),
  log_units = log(n_units),
  log_inc = log(as.numeric(med_hh_inc)),
  p_educ_bplus = (educ_bachelor + educ_master + educ_prof + educ_doctor) / educ_all
)]
dt[!is.finite(log_pop_dens), log_pop_dens := NA_real_]
dt[!is.finite(log_unit_dens), log_unit_dens := NA_real_]
dt[!is.finite(log_units), log_units := NA_real_]
dt[!is.finite(log_inc), log_inc := NA_real_]

controls <- "dist_to_cbg + log_inc + p_white + p_black + p_asian + p_educ_bplus"
models <- list(
  pop_density_05mi = as.formula(paste("log_pop_dens ~ log_mla * near_dart +", controls)),
  unit_density_05mi = as.formula(paste("log_unit_dens ~ log_mla * near_dart +", controls)),
  units_05mi = as.formula(paste("log_units ~ log_mla * near_dart + log(land_area_m2) +", controls)),
  pop_density_025mi = as.formula(paste("log_pop_dens ~ log_mla * near_dart_025 +", controls)),
  pop_density_1mi = as.formula(paste("log_pop_dens ~ log_mla * near_dart_1mi +", controls))
)

tidy_lm <- function(name, fit) {
  coefs <- summary(fit)$coefficients
  data.table(
    model = name,
    term = rownames(coefs),
    coefficient = coefs[, 1],
    se = coefs[, 2],
    t_stat = coefs[, 3],
    p_value = coefs[, 4],
    n = nobs(fit),
    r2 = summary(fit)$r.squared
  )
}

fits <- lapply(models, lm, data = dt)
reg <- rbindlist(Map(tidy_lm, names(fits), fits))
reg[, stars := star(coefficient, se)]

fwrite(reg, file.path(OUT, "p3_mls_station_area_regressions.csv"))
fwrite(dt, file.path(OUT, "p3_mls_dallas_cbg_analysis.csv"))

print(reg[grepl("log_mla", term)])
