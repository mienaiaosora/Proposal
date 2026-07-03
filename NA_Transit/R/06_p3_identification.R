# 06_p3_identification.R
# P3 identification analysis: does restrictive zoning suppress transit investment?
#
# Three strategies:
#   (1) Post-war subsample (year_first >= 1945) — removes legacy endogeneity
#   (2) Control for pre-automobile urban form (year_first as continuous control)
#   (3) Housing supply elasticity (Baum-Snow & Han) as alternative zoning measure
#
# Bonus: planned transit km as outcome (removes historical stock entirely)
#
# Output: regression table + figures → ../results/

library(here)
NA_TRANSIT <- file.path(here::here(), "NA_Transit")
RESULTS    <- file.path(here::here(), "results")
DATA_DIR   <- here::here()

source(file.path(NA_TRANSIT, "R", "00_setup.R"))

pacman::p_load(broom, ggrepel, patchwork, scales)

# ── Fixed-guideway modes (excludes streetcars, commuter/intercity rail) ───────

FG_MODES <- c("Metro", "Light Rail", "BRT", "Light Metro",
              "Regional Rail", "Arterial Rapid Transit", "Monorail")

# ── 1. Existing fixed-guideway transit: km and year of first opening ──────────

lines_existing <- sf::st_read(
  file.path(NA_TRANSIT, "data", "processed", "lines_us.geojson"),
  quiet = TRUE
) |>
  sf::st_drop_geometry() |>
  filter(mode %in% FG_MODES)

metro_existing <- lines_existing |>
  group_by(region) |>
  summarise(
    transit_km = sum(route_km, na.rm = TRUE),
    year_first = min(year_open, na.rm = TRUE),
    .groups = "drop"
  )

# ── 2. Planned transit: km (reveals investment intentions, no historical stock) ─

lines_all <- sf::st_read(
  file.path(NA_TRANSIT, "geojson", "lines.geojson"), quiet = TRUE
) |>
  sf::st_drop_geometry() |>
  filter(
    country == "USA",
    mode    %in% FG_MODES,
    status  %in% c("planned", "under construction")
  )

metro_planned <- lines_all |>
  group_by(region) |>
  summarise(planned_km = sum(route_km, na.rm = TRUE), .groups = "drop")

# ── 3. WRLURI metro data ──────────────────────────────────────────────────────

wrluri <- read_csv(
  file.path(DATA_DIR, "data", "processed", "wrluri", "wrluri_metro.csv"),
  show_col_types = FALSE
) |>
  rename(
    WRLURI      = WRLURI_metro2,
    FracUnavail = Tot_FrcUnavail50_01,
    elast_inner = region_gamma101a_units_IV,
    elast_outer = region_gamma201a_units_IV
  )

# Deduplicate: a few cbdnames appear twice with different region_all codes
# (e.g. Albany NY vs GA). Keep the metro with more tracts = larger/correct match.
wrluri_dedup <- wrluri |>
  group_by(cbdname) |>
  slice_max(numtracts, n = 1, with_ties = FALSE) |>
  ungroup()

# ── 4. Metro name lookup: Transit Explorer → WRLURI cbdname ──────────────────
# Constructed by manual inspection of region strings vs cbdname list.

lookup <- tribble(
  ~region,                   ~cbdname,
  "Albany NY USA",           "Albany",
  "Albuquerque NM USA",      "Albuquerque",
  "Atlanta GA USA",          "Atlanta",
  "Austin TX USA",           "Austin",
  "Baltimore MD USA",        "Baltimore",
  "Bay Area CA USA",         "San Francisco",
  "Birmingham AL USA",       "Birmingham",
  "Boston MA USA",           "Boston",
  "Buffalo NY USA",          "Buffalo",
  "Charlotte NC USA",        "Charlotte",
  "Chattanooga TN USA",      "Chattanooga",
  "Chicago IL USA",          "Chicago",
  "Cincinnati OH USA",       "Cincinnati",
  "Cleveland OH USA",        "Cleveland",
  "Columbus OH USA",         "Columbus",
  "Dallas TX USA",           "Dallas",
  "Denver CO USA",           "Denver",
  "Detroit MI USA",          "Detroit",
  "Dubuque IA USA",          "Dubuque",
  "El Paso TX USA",          "El Paso",
  "Eugene OR USA",           "Eugene",
  "Fort Collins CO USA",     "Fort Collins",
  "Fresno CA USA",           "Fresno",
  "Grand Rapids MI USA",     "Grand Rapids",
  "Hartford CT USA",         "Hartford",
  "Houston TX USA",          "Houston",
  "Huntsville AL USA",       "Huntsville",
  "Jacksonville FL USA",     "Jacksonville",
  "Kansas City MO USA",      "Kansas City",
  "Las Vegas NV USA",        "Las Vegas",
  "Little Rock AR USA",      "Little Rock",
  "Los Angeles CA USA",      "Los Angeles",
  "Madison WI USA",          "Madison",
  "Memphis TN USA",          "Memphis",
  "Miami FL USA",            "Miami",
  "Milwaukee WI USA",        "Milwaukee",
  "Minneapolis MN USA",      "Minneapolis",
  "New Haven CT USA",        "New Haven",
  "New Orleans LA USA",      "New Orleans",
  "New York NY USA",         "New York",
  "Norfolk VA USA",          "Norfolk",
  "Oklahoma City OK USA",    "Oklahoma City",
  "Omaha NE USA",            "Omaha",
  "Orlando FL USA",          "Orlando",
  "Philadelphia PA USA",     "Philadelphia",
  "Phoenix AZ USA",          "Phoenix",
  "Pittsburgh PA USA",       "Pittsburgh",
  "Portland OR USA",         "Portland",
  "Providence RI USA",       "Providence",
  "Reno NV USA",             "Reno",
  "Richmond VA USA",         "Richmond",
  "Sacramento CA USA",       "Sacramento",
  "Salt Lake UT USA",        "Salt Lake Ciel",
  "San Diego CA USA",        "San Diego",
  "Seattle WA USA",          "Seattle",
  "St. Louis MO USA",        "St Louis",
  "Tampa FL USA",            "Tampa",
  "Washington DC USA",       "Washington"
)

# ── 5. Merge ──────────────────────────────────────────────────────────────────

panel <- metro_existing |>
  inner_join(lookup,       by = "region") |>
  inner_join(wrluri_dedup, by = "cbdname") |>
  left_join(metro_planned, by = "region") |>
  mutate(
    planned_km = replace_na(planned_km, 0),
    legacy     = year_first < 1945,
    # Short city label for plots
    city_label = region |>
      str_remove(" USA$") |>
      str_remove(" [A-Z]{2}$") |>
      str_replace("Bay Area", "SF Bay Area")
  )

postwar <- filter(panel, !legacy)

cat(sprintf("Matched metros: %d  (legacy: %d, post-war: %d)\n",
            nrow(panel), sum(panel$legacy), sum(!panel$legacy)))
cat("\nSample overview:\n")
panel |>
  select(city_label, transit_km, year_first, WRLURI, elast_inner, legacy) |>
  arrange(year_first) |>
  print(n = 60)

# ── 6. Regressions ────────────────────────────────────────────────────────────
# Outcome: log(transit_km). Zoning: WRLURI (higher = more restrictive) or
# elast_inner (higher = more permissive → model predicts + coefficient).

m1 <- lm(log(transit_km) ~ WRLURI + log(numtracts) + FracUnavail,
         data = panel)
m2 <- lm(log(transit_km) ~ WRLURI + log(numtracts) + FracUnavail,
         data = postwar)
m3 <- lm(log(transit_km) ~ WRLURI + log(numtracts) + FracUnavail + year_first,
         data = panel)
m4 <- lm(log(transit_km) ~ elast_inner + log(numtracts) + FracUnavail,
         data = panel)
m5 <- lm(log(transit_km) ~ elast_inner + log(numtracts) + FracUnavail,
         data = postwar)

models <- list(m1, m2, m3, m4, m5)

star <- function(p) {
  dplyr::case_when(
    p < 0.01 ~ "***", p < 0.05 ~ "**", p < 0.10 ~ "*", TRUE ~ ""
  )
}

cat("\n=== Regression results (coefficients / SE) ===\n")
for (i in seq_along(models)) {
  m   <- models[[i]]
  tid <- tidy(m)
  cat(sprintf(
    "\nModel (%d)  N=%-3d  R2=%.3f\n", i, nobs(m), summary(m)$r.squared
  ))
  tid |>
    mutate(stars = star(p.value)) |>
    mutate(across(c(estimate, std.error), \(x) sprintf("%.4f", x))) |>
    select(term, estimate, std.error, stars) |>
    print(n = 20)
}

# ── 7. Figures ────────────────────────────────────────────────────────────────

slope_all <- round(coef(m1)["WRLURI"], 3)
slope_pw  <- round(coef(m2)["WRLURI"], 3)
n_all     <- nrow(panel)
n_pw      <- nrow(postwar)

p_all <- panel |>
  ggplot(aes(x = WRLURI, y = log(transit_km))) +
  geom_smooth(method = "lm", se = TRUE,
              colour = "steelblue3", fill = "steelblue3", alpha = 0.15,
              linewidth = 0.8) +
  geom_point(aes(colour = legacy), size = 2.2) +
  geom_text_repel(aes(label = city_label, colour = legacy),
                  size = 2.3, family = "serif",
                  max.overlaps = 20, segment.size = 0.3) +
  scale_colour_manual(
    values = c("FALSE" = "grey35", "TRUE" = "firebrick3"),
    labels = c("FALSE" = "Post-war", "TRUE" = "Legacy (pre-1945)")
  ) +
  labs(
    x       = "WRLURI  (higher = more restrictive)",
    y       = expression(log(Transit~km)),
    colour  = NULL,
    caption = sprintf(
      "N = %d; OLS slope = %+.3f (endogenous: legacy + economic-success confounds)",
      n_all, slope_all
    )
  ) +
  theme_transit() +
  theme(
    plot.caption = element_text(size = 7, hjust = 0, colour = "grey40"),
    legend.position = "bottom"
  )

p_postwar <- postwar |>
  ggplot(aes(x = WRLURI, y = log(transit_km))) +
  geom_smooth(method = "lm", se = TRUE,
              colour = "steelblue3", fill = "steelblue3", alpha = 0.15,
              linewidth = 0.8) +
  geom_point(colour = "grey35", size = 2.2) +
  geom_text_repel(aes(label = city_label),
                  size = 2.3, family = "serif",
                  max.overlaps = 20, segment.size = 0.3, colour = "grey35") +
  labs(
    x       = "WRLURI  (higher = more restrictive)",
    y       = expression(log(Transit~km)),
    caption = sprintf(
      "Post-war metros only (year_first >= 1945); N = %d; OLS slope = %+.3f",
      n_pw, slope_pw
    )
  ) +
  theme_transit() +
  theme(plot.caption = element_text(size = 7, hjust = 0, colour = "grey40"))

p_combined <- (p_all | p_postwar) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", family = "serif"))

# Save figures
ggsave(file.path(RESULTS, "fig_p3_legacy_comparison.pdf"),
       plot = p_combined, width = 13, height = 5.5,
       units = "in", device = "pdf")
ggsave(file.path(RESULTS, "fig_p3_legacy_comparison.png"),
       plot = p_combined, width = 13, height = 5.5,
       units = "in", dpi = 300)
ggsave(file.path(RESULTS, "fig_p3_postwar.pdf"),
       plot = p_postwar, width = 6.5, height = 4.5,
       units = "in", device = "pdf")
ggsave(file.path(RESULTS, "fig_p3_postwar.png"),
       plot = p_postwar, width = 6.5, height = 4.5,
       units = "in", dpi = 300)

cat(sprintf("\nFigures saved to %s\n", RESULTS))
