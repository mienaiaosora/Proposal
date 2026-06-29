# 02_filter_us.R
# Filter lines and stations to the United States, standardize CRS,
# and save cleaned sf objects for downstream analysis.
# STUB — cities to include will be decided after Stage 3 exploration.

source(here::here("R", "00_setup.R"))
source(here::here("R", "01_load_data.R"))

# ── Filter to USA ─────────────────────────────────────────────────────────────

lines_us <- lines_raw |>
  filter(country == "USA", status == "existing")

stations_us <- stations_raw |>
  filter(country == "USA", status == "existing")

cat("US existing lines:   ", nrow(lines_us), "\n")
cat("US existing stations:", nrow(stations_us), "\n")

# ── Standardize CRS to WGS84 for storage ─────────────────────────────────────

lines_us    <- sf::st_transform(lines_us,    CRS_STORAGE)
stations_us <- sf::st_transform(stations_us, CRS_STORAGE)

# ── TODO: select target cities ───────────────────────────────────────────────
# After running 03_explore.R, decide which metro areas to keep.
# Replace this stub with a filter on the `region` field, e.g.:
#
# target_cities <- c("Chicago IL", "Washington DC", "Portland OR")
# lines_us <- lines_us |> filter(region %in% target_cities)

# ── Save ──────────────────────────────────────────────────────────────────────

sf::st_write(lines_us,    here::here("data", "processed", "lines_us.geojson"),
             delete_dsn = TRUE, quiet = TRUE)
sf::st_write(stations_us, here::here("data", "processed", "stations_us.geojson"),
             delete_dsn = TRUE, quiet = TRUE)

cat("Saved: data/processed/lines_us.geojson\n")
cat("Saved: data/processed/stations_us.geojson\n")
