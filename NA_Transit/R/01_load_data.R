# 01_load_data.R
# Read the raw GeoJSON layers into sf objects and run basic sanity checks.
# Output: lines_raw and stations_raw (not saved — downstream scripts re-source this).

source(here::here("R", "00_setup.R"))

# ── Read ──────────────────────────────────────────────────────────────────────

lines_raw <- sf::st_read(here::here("geojson", "lines.geojson"), quiet = FALSE)
stations_raw <- sf::st_read(here::here("geojson", "stations.geojson"), quiet = FALSE)

# ── Inspect ───────────────────────────────────────────────────────────────────

cat("\n── LINES ──────────────────────────────────────────\n")
cat("Rows:  ", nrow(lines_raw), "\n")
cat("Fields:", paste(names(lines_raw), collapse = ", "), "\n")
cat("CRS:   ", sf::st_crs(lines_raw)$input, "\n")

cat("\n── STATIONS ────────────────────────────────────────\n")
cat("Rows:  ", nrow(stations_raw), "\n")
cat("Fields:", paste(names(stations_raw), collapse = ", "), "\n")
cat("CRS:   ", sf::st_crs(stations_raw)$input, "\n")

# Country breakdown — confirms North America scope before we filter to US
cat("\n── Country counts (lines) ──────────────────────────\n")
print(lines_raw |> sf::st_drop_geometry() |> count(country, sort = TRUE))

cat("\n── Mode counts (lines, all countries) ─────────────\n")
print(lines_raw |> sf::st_drop_geometry() |> count(mode, sort = TRUE))

cat("\n── Status counts (lines) ───────────────────────────\n")
print(lines_raw |> sf::st_drop_geometry() |> count(status, sort = TRUE))

# Quick interactive map — run in RStudio; not for final output
# mapview(lines_raw, zcol = "mode")
# mapview(stations_raw, zcol = "mode")
