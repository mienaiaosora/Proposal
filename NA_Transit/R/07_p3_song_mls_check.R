# 07_p3_song_mls_check.R
# Robustness check for P3 using Jaehee Song's (2025) minimum lot size (MLS) data.
#
# Coverage caveat: Song's national municipality-level MLS estimates
# (mla_stats_state_muni_cbsa.csv) are CoreLogic-derived and excluded from the public
# replication package. The only municipality-level MLS data available locally is
# validation_set.csv -- actual codebook minimum lot sizes (mla_act) by zoning district,
# for all MAPC (Boston-area) towns plus ONE sampled municipality per county in ~18 other
# counties. This is an illustrative, small-N check, not a metro-representative replication:
# the single sampled municipality per county may not represent that metro's overall zoning
# regime.
#
# Two analyses:
#   (a) P3 re-check: log(transit_km) ~ Song MLS, restricted to the subset of metros that
#       are also in the existing 06 panel (have existing fixed-guideway transit + WRLURI).
#   (b) B&H/WRLURI cross-validation: does Song's direct codebook measure agree with the
#       elasticity/WRLURI ranking of restrictiveness? This does not require transit data,
#       so it uses the full WRLURI/B&H metro table (wrluri_dedup), giving a larger N.
#
# Output: regression table + figures -> ../results/

library(here)
NA_TRANSIT <- file.path(here::here(), "NA_Transit")
RESULTS    <- file.path(here::here(), "results")
DATA_DIR   <- here::here()

source(file.path(NA_TRANSIT, "R", "06_p3_identification.R"))

pacman::p_load(stringr)

SONG_DIR <- file.path(DATA_DIR, "data", "song_mls_estimator", "231447-V1", "data")

# ── 1. Load validation_set.csv and aggregate to municipality level ───────────
# Parcel-weighted mean of log(actual codebook MLS) across zoning districts within
# each municipality; weight = sample_apn (sampled parcel count per district), as a
# proxy for how much of the municipality each district governs.

validation <- read_csv(file.path(SONG_DIR, "validation_set.csv"), show_col_types = FALSE) |>
  mutate(fips = str_pad(as.character(fips), 5, pad = "0"))

muni_mls <- validation |>
  group_by(fips, id_muni, region) |>
  summarise(
    log_mla_muni = weighted.mean(log(mla_act), w = sample_apn),
    n_districts  = n(),
    n_parcels    = sum(sample_apn),
    .groups = "drop"
  )

# ── 2. Map county FIPS to CBSA, then CBSA to WRLURI cbdname ──────────────────
# Song's own "mapc" label (Boston-area validation sample) is treated directly as
# Boston, since MAPC's real planning-region boundary does not align cleanly with
# the Worcester, MA-CT CBSA that one of its member counties (Worcester County)
# technically belongs to.

cbsa_xw <- read_csv(file.path(SONG_DIR, "map", "cbsa2fipsxw.csv"), show_col_types = FALSE) |>
  filter(!is.na(fipsstatecode), !is.na(fipscountycode), fipsstatecode != "") |>
  mutate(fips = paste0(str_pad(fipsstatecode, 2, pad = "0"),
                        str_pad(fipscountycode, 3, pad = "0"))) |>
  distinct(fips, cbsatitle)

# Manually checked crosswalk: cbsatitle (Song/Census) -> cbdname (WRLURI / Baum-Snow & Han).
# Covers every non-mapc county present in validation_set.csv.
cbsa_to_cbdname <- tribble(
  ~cbsatitle,                                       ~cbdname,
  "Montgomery, AL",                                 "Montgomery",
  "Phoenix-Mesa-Scottsdale, AZ",                     "Phoenix",
  "Bridgeport-Stamford-Norwalk, CT",                 "Bridgeport",
  "Hartford-West Hartford-East Hartford, CT",        "Hartford",
  "Washington-Arlington-Alexandria, DC-VA-MD-WV",    "Washington",
  "Jacksonville, FL",                                "Jacksonville",
  "Detroit-Warren-Dearborn, MI",                     "Detroit",
  "Minneapolis-St. Paul-Bloomington, MN-WI",         "Minneapolis",
  "Manchester-Nashua, NH",                           "Manchester",
  "New York-Newark-Jersey City, NY-NJ-PA",           "New York",
  "Raleigh, NC",                                     "Raleigh",
  "Fargo, ND-MN",                                    "Fargo",
  "Cincinnati, OH-KY-IN",                             "Cincinnati",
  "Tulsa, OK",                                       "Tulsa",
  "Philadelphia-Camden-Wilmington, PA-NJ-DE-MD",     "Philadelphia",
  "El Paso, TX",                                     "El Paso",
  "Seattle-Tacoma-Bellevue, WA",                      "Seattle",
  "Milwaukee-Waukesha-West Allis, WI",               "Milwaukee"
)

muni_mls <- muni_mls |>
  left_join(cbsa_xw, by = "fips") |>
  left_join(cbsa_to_cbdname, by = "cbsatitle") |>
  mutate(cbdname = if_else(region == "mapc", "Boston", cbdname))

# ── 3. Aggregate to metro level ───────────────────────────────────────────────

metro_mls <- muni_mls |>
  filter(!is.na(cbdname)) |>
  group_by(cbdname) |>
  summarise(
    log_mla_metro = weighted.mean(log_mla_muni, w = n_parcels),
    n_munis       = n(),
    n_districts   = sum(n_districts),
    .groups = "drop"
  )

cat(sprintf(
  "\nSong MLS: %d municipalities -> %d metros (after CBSA match)\n",
  n_distinct(muni_mls$id_muni), nrow(metro_mls)
))

# ── 4a. Cross-validation against WRLURI / B&H (no transit restriction) ───────

valid_metros <- metro_mls |> inner_join(wrluri_dedup, by = "cbdname")
unmatched_wrluri <- metro_mls |> anti_join(wrluri_dedup, by = "cbdname")

cat(sprintf(
  "\n(b) WRLURI/B&H cross-validation sample: N = %d metros matched\n", nrow(valid_metros)
))
if (nrow(unmatched_wrluri) > 0) {
  cat("Unmatched (no WRLURI entry for this cbdname):\n")
  print(unmatched_wrluri |> select(cbdname, n_munis))
}

cat("\n--- log(MLS) vs WRLURI ---\n")
mb1 <- lm(log_mla_metro ~ WRLURI, data = valid_metros)
print(summary(mb1))
cat(sprintf("Correlation: %.3f\n", cor(valid_metros$log_mla_metro, valid_metros$WRLURI)))

cat("\n--- log(MLS) vs B&H elasticity (elast_inner) ---\n")
mb2 <- lm(log_mla_metro ~ elast_inner, data = valid_metros)
print(summary(mb2))
cat(sprintf("Correlation: %.3f\n", cor(valid_metros$log_mla_metro, valid_metros$elast_inner)))

# ── 4b. P3 re-check on the subset of metros already in the 06 transit panel ──

matched <- metro_mls |> inner_join(panel, by = "cbdname")
unmatched_panel <- metro_mls |> anti_join(panel, by = "cbdname")

cat(sprintf(
  "\n(a) P3 re-check sample: N = %d metros matched to the existing transit panel\n",
  nrow(matched)
))
if (nrow(unmatched_panel) > 0) {
  cat("Song metros not in the 06 transit panel (no existing FG transit match, or cbdname\n")
  cat("not present in the 06 lookup table -- see script header for known gaps):\n")
  print(unmatched_panel |> select(cbdname, n_munis))
}
print(matched |> select(cbdname, log_mla_metro, transit_km, WRLURI, elast_inner))

cat("\n--- P3 re-check: bivariate specifications (N is small; SEs will be wide) ---\n")
pa1 <- lm(log(transit_km) ~ WRLURI,        data = matched)
pa2 <- lm(log(transit_km) ~ elast_inner,   data = matched)
pa3 <- lm(log(transit_km) ~ log_mla_metro, data = matched)

cat("\n--- P3 re-check: with controls (log numtracts, FracUnavail) ---\n")
pa4 <- lm(log(transit_km) ~ WRLURI        + log(numtracts) + FracUnavail, data = matched)
pa5 <- lm(log(transit_km) ~ elast_inner   + log(numtracts) + FracUnavail, data = matched)
pa6 <- lm(log(transit_km) ~ log_mla_metro + log(numtracts) + FracUnavail, data = matched)

prop3_models <- list(pa1 = pa1, pa2 = pa2, pa3 = pa3, pa4 = pa4, pa5 = pa5, pa6 = pa6)
for (nm in names(prop3_models)) {
  m <- prop3_models[[nm]]
  tid <- tidy(m) |>
    mutate(stars = star(p.value)) |>
    mutate(across(c(estimate, std.error), \(x) sprintf("%.4f", x)))
  cat(sprintf("\nModel %s  N=%-3d  R2=%.3f\n", nm, nobs(m), summary(m)$r.squared))
  print(tid |> select(term, estimate, std.error, stars), n = 10)
}

# ── 5. Save outputs ────────────────────────────────────────────────────────

write_csv(metro_mls, file.path(RESULTS, "song_mls_metro.csv"))

bh_table <- bind_rows(
  tidy(mb1) |> mutate(model = "log_mla ~ WRLURI"),
  tidy(mb2) |> mutate(model = "log_mla ~ elast_inner")
) |>
  mutate(stars = star(p.value)) |>
  select(model, term, estimate, std.error, stars)

p3_table <- bind_rows(lapply(names(prop3_models), \(nm) {
  tidy(prop3_models[[nm]]) |>
    mutate(model = nm, n = nobs(prop3_models[[nm]]), stars = star(p.value)) |>
    select(model, n, term, estimate, std.error, stars)
}))

write_csv(bh_table, file.path(RESULTS, "reg_p3_song_mls_bh_validation.csv"))
write_csv(p3_table, file.path(RESULTS, "reg_p3_song_mls.csv"))

# ── 6. Figures ────────────────────────────────────────────────────────────

fig_bh1 <- valid_metros |>
  ggplot(aes(x = WRLURI, y = log_mla_metro)) +
  geom_smooth(method = "lm", se = TRUE,
              colour = "steelblue3", fill = "steelblue3", alpha = 0.15,
              linewidth = 0.8) +
  geom_point(colour = "grey35", size = 2.2) +
  geom_text_repel(aes(label = cbdname), size = 2.3, family = "serif",
                   max.overlaps = 20, segment.size = 0.3, colour = "grey35") +
  labs(
    x = "WRLURI  (higher = more restrictive)",
    y = expression(log(Minimum~Lot~Size)),
    caption = sprintf("N = %d metros; corr = %.2f", nrow(valid_metros),
                       cor(valid_metros$log_mla_metro, valid_metros$WRLURI))
  ) +
  theme_transit() +
  theme(plot.caption = element_text(size = 7, hjust = 0, colour = "grey40"))

fig_bh2 <- valid_metros |>
  ggplot(aes(x = elast_inner, y = log_mla_metro)) +
  geom_smooth(method = "lm", se = TRUE,
              colour = "steelblue3", fill = "steelblue3", alpha = 0.15,
              linewidth = 0.8) +
  geom_point(colour = "grey35", size = 2.2) +
  geom_text_repel(aes(label = cbdname), size = 2.3, family = "serif",
                   max.overlaps = 20, segment.size = 0.3, colour = "grey35") +
  labs(
    x = "Housing supply elasticity (Baum-Snow & Han, inner)",
    y = expression(log(Minimum~Lot~Size)),
    caption = sprintf("N = %d metros; corr = %.2f", nrow(valid_metros),
                       cor(valid_metros$log_mla_metro, valid_metros$elast_inner))
  ) +
  theme_transit() +
  theme(plot.caption = element_text(size = 7, hjust = 0, colour = "grey40"))

fig_bh_combined <- (fig_bh1 | fig_bh2) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", family = "serif"))

ggsave(file.path(RESULTS, "fig_p3_song_mls_check.pdf"),
       plot = fig_bh_combined, width = 13, height = 5.5, units = "in", device = "pdf")
ggsave(file.path(RESULTS, "fig_p3_song_mls_check.png"),
       plot = fig_bh_combined, width = 13, height = 5.5, units = "in", dpi = 300)

fig_transit <- matched |>
  ggplot(aes(x = log_mla_metro, y = log(transit_km))) +
  geom_smooth(method = "lm", se = TRUE,
              colour = "steelblue3", fill = "steelblue3", alpha = 0.15,
              linewidth = 0.8) +
  geom_point(colour = "grey35", size = 2.2) +
  geom_text_repel(aes(label = cbdname), size = 2.3, family = "serif",
                   max.overlaps = 20, segment.size = 0.3, colour = "grey35") +
  labs(
    x = expression(log(Minimum~Lot~Size)~"(Song MLS)"),
    y = expression(log(Transit~km)),
    caption = sprintf(
      "N = %d metros matched to existing P3 transit panel; bivariate OLS slope = %+.3f",
      nrow(matched), coef(pa3)["log_mla_metro"]
    )
  ) +
  theme_transit() +
  theme(plot.caption = element_text(size = 7, hjust = 0, colour = "grey40"))

ggsave(file.path(RESULTS, "fig_p3_song_mls_transit.pdf"),
       plot = fig_transit, width = 6.5, height = 4.5, units = "in", device = "pdf")
ggsave(file.path(RESULTS, "fig_p3_song_mls_transit.png"),
       plot = fig_transit, width = 6.5, height = 4.5, units = "in", dpi = 300)

cat(sprintf("\nOutputs written to %s\n", RESULTS))
