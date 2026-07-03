# 08_p3_mls_station_density.R
# Proposition 3 mechanism test:
#   Does restrictive zoning, measured by Song's minimum lot size, predict lower
#   density around existing transit stations?
#
# Available-data implementation:
#   The public Song package does not include CBG-level MLA or municipality
#   boundary-linked MLA. I therefore aggregate Song's validation-set minimum lot
#   size to the metro level, then measure station-area density using CBGs whose
#   centroids are within 0.5 miles of existing fixed-guideway stations.

suppressPackageStartupMessages({
  library(data.table)
  library(sf)
  library(ggplot2)
})

ROOT <- normalizePath(getwd(), mustWork = TRUE)
SONG <- file.path(ROOT, "data", "song_mls_estimator", "231447-V1")
OUT  <- file.path(ROOT, "results")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

sf_use_s2(FALSE)

star <- function(p) {
  fifelse(p < 0.01, "***", fifelse(p < 0.05, "**", fifelse(p < 0.10, "*", "")))
}

tidy_lm <- function(name, fit) {
  co <- summary(fit)$coefficients
  out <- data.table(
    model = name,
    n = nobs(fit),
    r2 = summary(fit)$r.squared,
    term = rownames(co),
    estimate = co[, 1],
    std.error = co[, 2],
    p.value = co[, 4]
  )
  out[, stars := star(p.value)]
  out[]
}

# ---------------------------------------------------------------------------
# 1. Song validation-set MLA: zoning district -> municipality -> metro
# ---------------------------------------------------------------------------

validation <- fread(file.path(SONG, "data", "validation_set.csv"))
validation[, fips := sprintf("%05d", as.integer(fips))]

muni_mla <- validation[, .(
  log_mla_muni = weighted.mean(log(mla_act), w = sample_apn, na.rm = TRUE),
  n_districts = .N,
  n_parcels = sum(sample_apn, na.rm = TRUE)
), by = .(fips, id_muni, region)]

cbsa_xw <- fread(file.path(SONG, "data", "map", "cbsa2fipsxw.csv"))
cbsa_xw <- cbsa_xw[!is.na(fipsstatecode) & !is.na(fipscountycode)]
cbsa_xw[, fips := paste0(
  sprintf("%02d", as.integer(fipsstatecode)),
  sprintf("%03d", as.integer(fipscountycode))
)]
cbsa_xw <- unique(cbsa_xw[, .(fips, cbsatitle)])

cbsa_to_cbd <- data.table(
  cbsatitle = c(
    "Boston-Cambridge-Newton, MA-NH",
    "Montgomery, AL",
    "Phoenix-Mesa-Scottsdale, AZ",
    "Bridgeport-Stamford-Norwalk, CT",
    "Hartford-West Hartford-East Hartford, CT",
    "Washington-Arlington-Alexandria, DC-VA-MD-WV",
    "Jacksonville, FL",
    "Detroit-Warren-Dearborn, MI",
    "Minneapolis-St. Paul-Bloomington, MN-WI",
    "Manchester-Nashua, NH",
    "New York-Newark-Jersey City, NY-NJ-PA",
    "Raleigh, NC",
    "Fargo, ND-MN",
    "Cincinnati, OH-KY-IN",
    "Tulsa, OK",
    "Philadelphia-Camden-Wilmington, PA-NJ-DE-MD",
    "El Paso, TX",
    "Seattle-Tacoma-Bellevue, WA",
    "Milwaukee-Waukesha-West Allis, WI"
  ),
  cbdname = c(
    "Boston",
    "Montgomery",
    "Phoenix",
    "Bridgeport",
    "Hartford",
    "Washington",
    "Jacksonville",
    "Detroit",
    "Minneapolis",
    "Manchester",
    "New York",
    "Raleigh",
    "Fargo",
    "Cincinnati",
    "Tulsa",
    "Philadelphia",
    "El Paso",
    "Seattle",
    "Milwaukee"
  )
)

muni_mla <- merge(muni_mla, cbsa_xw, by = "fips", all.x = TRUE)
muni_mla <- merge(muni_mla, cbsa_to_cbd, by = "cbsatitle", all.x = TRUE)
muni_mla[region == "mapc", cbdname := "Boston"]

metro_mla <- muni_mla[!is.na(cbdname), .(
  log_mla_metro = weighted.mean(log_mla_muni, w = n_parcels, na.rm = TRUE),
  n_munis = uniqueN(id_muni),
  n_districts = sum(n_districts),
  n_parcels = sum(n_parcels)
), by = cbdname]

# ---------------------------------------------------------------------------
# 2. Metro controls and Transit Explorer region lookup
# ---------------------------------------------------------------------------

wrluri <- fread(file.path(ROOT, "data", "processed", "wrluri", "wrluri_metro.csv"))
setnames(
  wrluri,
  old = c("WRLURI_metro2", "Tot_FrcUnavail50_01", "region_gamma101a_units_IV"),
  new = c("WRLURI", "FracUnavail", "elast_inner")
)
setorder(wrluri, cbdname, -numtracts)
wrluri_dedup <- wrluri[, .SD[1], by = cbdname]

lookup <- data.table(
  region = c(
    "Boston MA USA",
    "Cincinnati OH USA",
    "Detroit MI USA",
    "El Paso TX USA",
    "Minneapolis MN USA",
    "New York NY USA",
    "Philadelphia PA USA",
    "Phoenix AZ USA",
    "Seattle WA USA",
    "Washington DC USA",
    "Milwaukee WI USA"
  ),
  cbdname = c(
    "Boston", "Cincinnati", "Detroit", "El Paso", "Minneapolis",
    "New York", "Philadelphia", "Phoenix", "Seattle", "Washington",
    "Milwaukee"
  )
)

analysis_metros <- merge(metro_mla, lookup, by = "cbdname")
analysis_metros <- merge(analysis_metros, wrluri_dedup, by = "cbdname", all.x = TRUE)

# Counties in the mapped CBSAs, for filtering CBGs.
metro_counties <- merge(cbsa_xw, cbsa_to_cbd, by = "cbsatitle")
metro_counties <- metro_counties[cbdname %in% analysis_metros$cbdname]
metro_counties <- unique(metro_counties[, .(cbdname, fips)])

# ---------------------------------------------------------------------------
# 3. CBG density and station buffers
# ---------------------------------------------------------------------------

cbg_chars <- fread(file.path(SONG, "data", "CBG_chars.csv"))
cbg_chars[, cbg_geoid := substr(GEO_ID, nchar(GEO_ID) - 11, nchar(GEO_ID))]
cbg_chars[, fips := substr(cbg_geoid, 1, 5)]
cbg_chars <- cbg_chars[fips %in% metro_counties$fips]
cbg_chars <- merge(cbg_chars, metro_counties, by = "fips", allow.cartesian = TRUE)

bg_path <- file.path(SONG, "data", "map", "cb_2019_us_bg_500k", "cb_2019_us_bg_500k.shp")
bg <- st_read(bg_path, quiet = TRUE)
bg <- bg[bg$GEOID %in% cbg_chars$cbg_geoid, c("GEOID", "ALAND", "geometry")]
bg <- st_transform(bg, 5070)
bg_cent <- st_centroid(bg)

geo <- data.table(
  cbg_geoid = bg$GEOID,
  land_area_m2 = as.numeric(bg$ALAND)
)
cbg <- merge(cbg_chars, geo, by = "cbg_geoid")

stations <- st_read(file.path(ROOT, "NA_Transit", "data", "processed", "stations_us.geojson"), quiet = TRUE)
station_modes <- c(
  "Metro", "Light Rail", "Light Metro", "Bus Rapid Transit",
  "Arterial Rapid Transit", "Regional Rail", "Monorail"
)
stations <- stations[stations$region %in% analysis_metros$region & stations$mode %in% station_modes, ]
stations <- st_transform(stations, 5070)

near_any <- rep(FALSE, nrow(bg_cent))
for (reg in unique(stations$region)) {
  cbd <- lookup[region == reg, cbdname]
  cbg_ids <- cbg[cbdname == cbd, cbg_geoid]
  i_bg <- which(bg$GEOID %in% cbg_ids)
  i_st <- which(stations$region == reg)
  if (length(i_bg) == 0 || length(i_st) == 0) next
  near_any[i_bg] <- lengths(st_is_within_distance(bg_cent[i_bg, ], stations[i_st, ], dist = 804.672)) > 0
}

near_dt <- data.table(cbg_geoid = bg$GEOID, near_station_05mi = as.integer(near_any))
cbg <- merge(cbg, near_dt, by = "cbg_geoid")

metro_density <- cbg[, .(
  metro_pop = sum(pop_tot, na.rm = TRUE),
  metro_units = sum(n_units, na.rm = TRUE),
  metro_land_m2 = sum(land_area_m2, na.rm = TRUE),
  n_cbg = .N
), by = cbdname]

station_density <- cbg[near_station_05mi == 1, .(
  station_pop = sum(pop_tot, na.rm = TRUE),
  station_units = sum(n_units, na.rm = TRUE),
  station_land_m2 = sum(land_area_m2, na.rm = TRUE),
  n_station_cbg = .N
), by = cbdname]

panel <- merge(analysis_metros, metro_density, by = "cbdname")
panel <- merge(panel, station_density, by = "cbdname", all.x = TRUE)
panel[is.na(n_station_cbg), `:=`(
  station_pop = 0,
  station_units = 0,
  station_land_m2 = NA_real_,
  n_station_cbg = 0
)]

panel[, `:=`(
  metro_pop_density = metro_pop / metro_land_m2,
  metro_unit_density = metro_units / metro_land_m2,
  station_pop_density = station_pop / station_land_m2,
  station_unit_density = station_units / station_land_m2,
  log_numtracts = log(numtracts)
)]

panel[, `:=`(
  log_station_pop_density = log(station_pop_density),
  log_station_unit_density = log(station_unit_density),
  log_metro_pop_density = log(metro_pop_density),
  log_metro_unit_density = log(metro_unit_density),
  log_station_density_ratio = log(station_pop_density / metro_pop_density)
)]

panel <- panel[is.finite(log_station_pop_density) & n_station_cbg > 0]

# ---------------------------------------------------------------------------
# 4. Regressions
# ---------------------------------------------------------------------------

m1 <- lm(log_station_pop_density ~ log_mla_metro, data = panel)
m2 <- lm(log_station_unit_density ~ log_mla_metro, data = panel)
m3 <- lm(log_station_density_ratio ~ log_mla_metro, data = panel)
m4 <- lm(log_station_pop_density ~ log_mla_metro + log_numtracts + FracUnavail, data = panel)
m5 <- lm(log_station_density_ratio ~ log_mla_metro + log_numtracts + FracUnavail, data = panel)

panel_ge10 <- panel[n_station_cbg >= 10]
m6 <- lm(log_station_pop_density ~ log_mla_metro, data = panel_ge10)
m7 <- lm(log_station_density_ratio ~ log_mla_metro, data = panel_ge10)
m8 <- lm(log_station_pop_density ~ log_mla_metro + log_numtracts + FracUnavail, data = panel_ge10)

regs <- rbindlist(list(
  tidy_lm("station_pop_density_bivar", m1),
  tidy_lm("station_unit_density_bivar", m2),
  tidy_lm("station_density_ratio_bivar", m3),
  tidy_lm("station_pop_density_controls", m4),
  tidy_lm("station_density_ratio_controls", m5),
  tidy_lm("station_pop_density_bivar_ge10cbg", m6),
  tidy_lm("station_density_ratio_bivar_ge10cbg", m7),
  tidy_lm("station_pop_density_controls_ge10cbg", m8)
))

fwrite(panel, file.path(OUT, "p3_mls_station_density_panel.csv"))
fwrite(regs, file.path(OUT, "reg_p3_mls_station_density.csv"))

# ---------------------------------------------------------------------------
# 5. Figure
# ---------------------------------------------------------------------------

fig <- ggplot(panel, aes(x = log_mla_metro, y = log_station_pop_density)) +
  geom_smooth(method = "lm", se = TRUE, colour = "steelblue3",
              fill = "steelblue3", alpha = 0.15, linewidth = 0.8) +
  geom_point(colour = "grey35", size = 2.3) +
  geom_text(aes(label = cbdname), nudge_y = 0.035, size = 2.5, colour = "grey25") +
  labs(
    x = "Metro log minimum lot size (Song validation data)",
    y = "Log population density within 0.5 mi of stations",
    caption = sprintf(
      "N = %d metros; CBG centroid within 0.5 mile of existing fixed-guideway stations",
      nrow(panel)
    )
  ) +
  theme_bw(base_size = 10) +
  theme(plot.caption = element_text(size = 7, hjust = 0, colour = "grey40"))

ggsave(file.path(OUT, "fig_p3_mls_station_density.pdf"), fig,
       width = 6.5, height = 4.5, units = "in", device = "pdf")
ggsave(file.path(OUT, "fig_p3_mls_station_density.png"), fig,
       width = 6.5, height = 4.5, units = "in", dpi = 300)

cat("\nStation-area density panel:\n")
print(panel[, .(
  cbdname, log_mla_metro, n_station_cbg,
  log_station_pop_density, log_station_density_ratio
)][order(log_mla_metro)])

cat("\nRegression terms involving log_mla_metro:\n")
print(regs[term == "log_mla_metro", .(model, n, r2, estimate, std.error, p.value, stars)])

cat(sprintf("\nOutputs written to %s\n", OUT))
