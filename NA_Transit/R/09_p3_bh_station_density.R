# 09_p3_bh_station_density.R
# Proposition 3 mechanism test using tract-level Baum-Snow & Han elasticity.
#
# Question:
#   Do more permissive tracts, measured by higher B&H housing supply elasticity,
#   have higher density, especially near DART stations?
#
# Interpretation:
#   B&H elasticity is permissiveness, not restrictiveness. The model predicts
#   positive coefficients on elasticity for density outcomes, and especially a
#   positive elasticity x near-station interaction if zoning matters most around
#   transit.

suppressPackageStartupMessages({
  library(data.table)
  library(haven)
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
# 1. B&H tract elasticities: Dallas metro
# ---------------------------------------------------------------------------

bh_path <- "/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/gammas_hat_all.dta"
bh <- as.data.table(read_dta(bh_path))

bh <- bh[cbdname == "Dallas"]
bh[, tract_fips := sprintf("%011.0f", as.numeric(ctracts2000))]
bh <- unique(bh[, .(
  tract_fips,
  gamma01a_units_IV,
  gamma11a_units_IV,
  gamma01a_space_IV,
  pctdis
)])

# ---------------------------------------------------------------------------
# 2. Build tract density from CBG ACS chars and CBG geometries
# ---------------------------------------------------------------------------

cbg_chars <- fread(file.path(SONG, "data", "CBG_chars.csv"))
cbg_chars[, cbg_geoid := substr(GEO_ID, nchar(GEO_ID) - 11, nchar(GEO_ID))]
cbg_chars[, tract_fips := substr(cbg_geoid, 1, 11)]
cbg_chars <- cbg_chars[tract_fips %in% bh$tract_fips]

bg_path <- file.path(SONG, "data", "map", "cb_2019_us_bg_500k", "cb_2019_us_bg_500k.shp")
bg <- st_read(bg_path, quiet = TRUE)
bg <- bg[bg$GEOID %in% cbg_chars$cbg_geoid, c("GEOID", "ALAND", "geometry")]
bg <- st_transform(bg, 5070)

bg_dt <- data.table(
  cbg_geoid = bg$GEOID,
  land_area_m2 = as.numeric(bg$ALAND)
)

cbg <- merge(cbg_chars, bg_dt, by = "cbg_geoid")
tract_density <- cbg[, .(
  pop_tot = sum(pop_tot, na.rm = TRUE),
  n_units = sum(n_units, na.rm = TRUE),
  land_area_m2 = sum(land_area_m2, na.rm = TRUE),
  n_cbg = .N,
  med_hh_inc = weighted.mean(as.numeric(med_hh_inc), w = pop_tot, na.rm = TRUE),
  p_white = weighted.mean(p_white, w = pop_tot, na.rm = TRUE),
  p_black = weighted.mean(p_black, w = pop_tot, na.rm = TRUE),
  p_asian = weighted.mean(p_asian, w = pop_tot, na.rm = TRUE)
), by = tract_fips]

tract_density[, `:=`(
  pop_density = pop_tot / land_area_m2,
  unit_density = n_units / land_area_m2,
  log_pop_density = log(pop_tot / land_area_m2),
  log_unit_density = log(n_units / land_area_m2),
  log_units = log(n_units),
  log_land_area = log(land_area_m2),
  log_inc = log(med_hh_inc)
)]

tract_density[!is.finite(log_inc), log_inc := NA_real_]

# Tract geometries from unioned CBGs.
bg$tract_fips <- substr(bg$GEOID, 1, 11)
tract_geom <- bg |>
  dplyr::group_by(tract_fips) |>
  dplyr::summarise(geometry = sf::st_union(geometry), .groups = "drop")
tract_cent <- st_centroid(tract_geom)

# ---------------------------------------------------------------------------
# 3. DART station proximity
# ---------------------------------------------------------------------------

stations <- st_read(file.path(ROOT, "NA_Transit", "data", "processed", "stations_us.geojson"), quiet = TRUE)
stations <- stations[stations$region == "Dallas TX USA", ]
stations <- st_transform(stations, 5070)

dist_station_m <- as.numeric(st_distance(tract_cent, st_union(stations)))
near_05 <- dist_station_m <= 804.672
near_1 <- dist_station_m <= 1609.344

near_dt <- data.table(
  tract_fips = tract_geom$tract_fips,
  near_dart_05mi = as.integer(near_05),
  near_dart_1mi = as.integer(near_1),
  dist_station_m = dist_station_m
)

panel <- merge(bh, tract_density, by = "tract_fips")
panel <- merge(panel, near_dt, by = "tract_fips")
panel <- panel[
  is.finite(log_pop_density) &
    is.finite(log_unit_density) &
    !is.na(gamma01a_units_IV)
]

panel[, restrictiveness := -gamma01a_units_IV]

# ---------------------------------------------------------------------------
# 4. Regressions
# ---------------------------------------------------------------------------

controls <- "+ pctdis + log_inc + p_white + p_black + p_asian"

m1 <- lm(log_pop_density ~ gamma01a_units_IV, data = panel)
m2 <- lm(as.formula(paste("log_pop_density ~ gamma01a_units_IV", controls)), data = panel)
m3 <- lm(as.formula(paste("log_pop_density ~ gamma01a_units_IV * near_dart_05mi", controls)), data = panel)
m4 <- lm(as.formula(paste("log_unit_density ~ gamma01a_units_IV * near_dart_05mi", controls)), data = panel)
m5 <- lm(as.formula(paste("log_units ~ gamma01a_units_IV * near_dart_05mi + log_land_area", controls)), data = panel)
m6 <- lm(as.formula(paste("log_pop_density ~ gamma11a_units_IV * near_dart_05mi", controls)), data = panel)
m7 <- lm(as.formula(paste("log_pop_density ~ gamma01a_units_IV * near_dart_1mi", controls)), data = panel)
m8 <- lm(log_pop_density ~ restrictiveness * near_dart_05mi + pctdis + log_inc + p_white + p_black + p_asian, data = panel)

regs <- rbindlist(list(
  tidy_lm("pop_density_bivar", m1),
  tidy_lm("pop_density_controls", m2),
  tidy_lm("pop_density_near05_interaction", m3),
  tidy_lm("unit_density_near05_interaction", m4),
  tidy_lm("units_near05_interaction", m5),
  tidy_lm("pop_density_gamma11_near05_interaction", m6),
  tidy_lm("pop_density_near1_interaction", m7),
  tidy_lm("pop_density_restrictiveness_near05", m8)
))

fwrite(panel, file.path(OUT, "p3_bh_station_density_panel.csv"))
fwrite(regs, file.path(OUT, "reg_p3_bh_station_density.csv"))

# ---------------------------------------------------------------------------
# 5. Figure
# ---------------------------------------------------------------------------

fig <- ggplot(panel, aes(x = gamma01a_units_IV, y = log_pop_density)) +
  geom_smooth(method = "lm", se = TRUE, colour = "steelblue3",
              fill = "steelblue3", alpha = 0.15, linewidth = 0.8) +
  geom_point(aes(colour = factor(near_dart_05mi)), alpha = 0.7, size = 1.6) +
  scale_colour_manual(
    values = c("0" = "grey55", "1" = "firebrick3"),
    labels = c("0" = "Farther than 0.5 mi", "1" = "Within 0.5 mi")
  ) +
  labs(
    x = "B&H housing supply elasticity (higher = more permissive)",
    y = "Log tract population density",
    colour = "DART access",
    caption = sprintf("Dallas matched tracts: N = %d; near-DART tracts = %d",
                      nrow(panel), sum(panel$near_dart_05mi))
  ) +
  theme_bw(base_size = 10) +
  theme(
    legend.position = "bottom",
    plot.caption = element_text(size = 7, hjust = 0, colour = "grey40")
  )

ggsave(file.path(OUT, "fig_p3_bh_station_density.pdf"), fig,
       width = 6.5, height = 4.5, units = "in", device = "pdf")
ggsave(file.path(OUT, "fig_p3_bh_station_density.png"), fig,
       width = 6.5, height = 4.5, units = "in", dpi = 300)

cat("\nPanel summary:\n")
print(panel[, .(
  n_tracts = .N,
  near05 = sum(near_dart_05mi),
  near1 = sum(near_dart_1mi),
  mean_gamma = mean(gamma01a_units_IV, na.rm = TRUE),
  mean_log_pop_density = mean(log_pop_density, na.rm = TRUE)
)])

cat("\nKey B&H elasticity terms:\n")
print(regs[grepl("gamma01a_units_IV|gamma11a_units_IV|restrictiveness", term),
           .(model, n, r2, term, estimate, std.error, p.value, stars)])

cat(sprintf("\nOutputs written to %s\n", OUT))
