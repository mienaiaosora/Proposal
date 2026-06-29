# 03_explore.R
# Exploratory analysis of US transit network.
# Produces: summary tables and publication-ready figures for city selection.
# STUB — expand after 02_filter_us.R is finalized.

source(here::here("R", "00_setup.R"))

lines_us    <- sf::st_read(here::here("data", "processed", "lines_us.geojson"), quiet = TRUE)
stations_us <- sf::st_read(here::here("data", "processed", "stations_us.geojson"), quiet = TRUE)

# ── Drop geometry for tabular work ───────────────────────────────────────────

lines_tbl    <- sf::st_drop_geometry(lines_us)
stations_tbl <- sf::st_drop_geometry(stations_us)

# ── City-level summary ────────────────────────────────────────────────────────
# route_km may be NA for some segments; sum with na.rm.
# Use `project` as the line-level unit (not fid) per data caveats.

city_summary <- lines_tbl |>
  group_by(region, mode) |>
  summarise(
    n_segments  = n(),
    n_projects  = n_distinct(project, na.rm = TRUE),
    total_km    = sum(route_km, na.rm = TRUE),
    year_first  = min(year_open, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(total_km))

print(city_summary, n = 30)

# ── Figure: route km by mode, top US cities ───────────────────────────────────
# TODO: finalize city selection before producing this figure.

top_cities <- city_summary |>
  group_by(region) |>
  summarise(total_km = sum(total_km)) |>
  slice_max(total_km, n = 20) |>
  pull(region)

p_city_km <- city_summary |>
  filter(region %in% top_cities) |>
  mutate(region = fct_reorder(region, total_km, sum)) |>
  ggplot(aes(x = total_km, y = region, fill = mode)) +
  geom_col() +
  scale_fill_brewer(palette = "Set2") +
  labs(x = "Route length (km)", y = NULL, fill = "Mode") +
  theme_transit()

save_figure("city_route_km_by_mode", p_city_km, width = 6.5, height = 7)

# ── Figure: opening year distribution ────────────────────────────────────────

p_openings <- lines_tbl |>
  filter(!is.na(year_open), year_open >= 1900) |>
  count(year_open, mode) |>
  ggplot(aes(x = year_open, y = n, fill = mode)) +
  geom_col() +
  scale_fill_brewer(palette = "Set2") +
  labs(x = "Year opened", y = "Segments opened", fill = "Mode") +
  theme_transit()

save_figure("opening_year_distribution", p_openings, width = 6.5, height = 4)
