# 00_setup.R
# Source this file at the top of every analysis script.
# Loads all packages and defines shared plot theme.

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")

pacman::p_load(
  here,           # project-relative paths via here::here()
  sf,             # vector spatial data (read, transform, manipulate)
  terra,          # raster spatial data
  tidyverse,      # dplyr, ggplot2, readr, tidyr, stringr, forcats
  mapview,        # interactive map inspection (not for final figures)
  tmap,           # thematic maps (alternative to ggplot2 for some tasks)
  exactextractr,  # fast raster extraction to polygons
  tidycensus,     # Census / ACS data via API
  units,          # physical unit conversion (e.g., km to miles)
  RColorBrewer,   # colorblind-safe palettes
  viridis         # perceptually uniform color scales
)

# ── Shared ggplot2 theme ──────────────────────────────────────────────────────
# Serif font, minimal decoration — matches typical economics journal style.
# Use theme_transit() for all non-map figures; theme_transit_map() for maps.

theme_transit <- function(base_size = 11, base_family = "serif") {
  theme_classic(base_size = base_size, base_family = base_family) +
    theme(
      plot.title       = element_blank(),   # titles go in the paper caption
      axis.line        = element_line(colour = "grey40", linewidth = 0.35),
      axis.ticks       = element_line(colour = "grey40", linewidth = 0.35),
      axis.text        = element_text(colour = "grey20"),
      axis.title       = element_text(colour = "grey20"),
      legend.position  = "bottom",
      legend.title     = element_text(face = "bold"),
      strip.background = element_blank(),
      strip.text       = element_text(face = "bold", colour = "grey20"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
}

theme_transit_map <- function(base_size = 11, base_family = "serif") {
  theme_void(base_size = base_size, base_family = base_family) +
    theme(
      plot.title      = element_blank(),
      legend.position = "bottom",
      legend.title    = element_text(face = "bold"),
      strip.background = element_blank(),
      strip.text      = element_text(face = "bold")
    )
}

# ── Save helpers ──────────────────────────────────────────────────────────────
# ggsave wrappers that always produce both PDF and PNG at publication resolution.

save_figure <- function(name, plot = last_plot(), width = 6.5, height = 4.5) {
  ggsave(here::here("output", "figures", paste0(name, ".pdf")),
         plot = plot, width = width, height = height, units = "in", device = cairo_pdf)
  ggsave(here::here("output", "figures", paste0(name, ".png")),
         plot = plot, width = width, height = height, units = "in", dpi = 300)
  invisible(plot)
}

# ── CRS constants ─────────────────────────────────────────────────────────────
CRS_STORAGE  <- 4326   # WGS84 — for saving/sharing spatial data
CRS_ANALYSIS <- 5070   # NAD83 Albers Equal Area (CONUS) — for distances/areas
