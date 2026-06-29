# CLAUDE.md — NA_Transit Project

## Project Overview

**Research question**: Tranist and local zoning regulations are often determined independently, This proposal aims to explore the potential inefficiency of this mismatch where local municipality zoning deters the optimal transit network.(Second year research, identification strategy being Quantitative Spatial Model.)

**Stage**: Data exploration and proposal development.

**Primary tool**: R (tidyverse + sf ecosystem). The user has basic tidyverse proficiency but no prior geospatial R experience — always explain geospatial operations when introducing them.

**Geographic scope**: Specific US cities, comparative case study design. Filter out Canada and Mexico unless explicitly requested.

---

## Dataset

**Source**: The Transport Politic: Transit Explorer (Yonah Freemark & Steven Vance)
**Version**: April 2026
**License**: Non-commercial, single-user. Data cannot be redistributed. Any output using this data must cite:
> Yonah Freemark, Steven Vance, and OpenStreetMap contributors (2026). *The Transport Politic: Transit Explorer*. https://www.thetransportpolitic.com/transitexplorer

**Two spatial layers** (available as CSV, GeoJSON, Shapefile in `csv/`, `geojson/`, `shapefile/`):

### `lines` — transit route segments

| Field | Description |
|-------|-------------|
| `fid` | Feature ID |
| `mode` | Transit mode (e.g., Light Rail, Metro, BRT, Commuter Rail) |
| `region` | City/region name |
| `agency` | Operating agency |
| `name` | Line name |
| `year_open` | Year segment opened |
| `cost_usd` | Construction cost (USD) |
| `riders` | Ridership |
| `status` | `existing`, `under construction`, `planned`, etc. |
| `grade` | Physical separation (subway, at-grade, elevated) |
| `construct` | Construction type |
| `automated` | Whether automated |
| `year_clos` | Year closed (if applicable) |
| `route_km` | Segment length (km) |
| `country` | Country code (USA, CAN, MEX) |
| `project` | Project/corridor name |

### `stations` — transit stops

| Field | Description |
|-------|-------------|
| `fid` | Feature ID |
| `line` | Associated line fid |
| `mode` | Transit mode |
| `name` | Station name |
| `region` | City/region name |
| `year_open` | Year station opened |
| `status` | Operating status |
| `grade` | Physical grade |
| `year_clos` | Year closed |
| `country` | Country code |
| `name_local` | Local language name |

### Critical data caveats (from Read_Me.txt)

1. **Segments != lines**: One transit line may be split into multiple segments (e.g., by opening year). Never count segments as distinct lines.
2. **Historic streetcar data is incomplete and less reliable.** Use cautiously; note limitations explicitly.
3. **Coverage is uneven**: Cities with more documentation have more detail. Absence of data is not absence of transit.
4. **`project` field is the right unit for line-level analysis** (aggregates segments belonging to the same corridor).

---

## Directory Layout

```
NA_Transit/
├── CLAUDE.md               <- this file
├── .claude/
│   └── settings.json
├── R/
│   ├── 00_setup.R          <- source() this first in every script
│   ├── 01_load_data.R      <- read raw GeoJSON -> sf objects
│   ├── 02_filter_us.R      <- filter to US cities, standardize CRS
│   └── 03_explore.R        <- summary stats, quick maps
├── output/
│   ├── figures/            <- .pdf + .png exports (publication-ready)
│   └── tables/             <- .tex + .csv exports
├── data/
│   └── processed/          <- derived datasets (never commit large files)
├── csv/                    <- raw data (do not modify)
├── geojson/                <- raw data (do not modify)
├── shapefile/              <- raw data (do not modify)
└── Read_Me.txt
```

**Never modify files in `csv/`, `geojson/`, or `shapefile/`.** These are the raw source data.

---

## R Coding Standards

- **Style**: tidyverse style guide. Pipes: use `|>` (native pipe, R >= 4.1).
- **Spatial**: always use `sf` for vector data. Never use base-R `plot()` for spatial output -- use `ggplot2 + geom_sf()` for static maps, `mapview()` for interactive inspection only.
- **Paths**: always use `here::here()` -- never hardcode absolute paths.
- **Libraries**: load from `R/00_setup.R` via `source(here::here("R", "00_setup.R"))`.
- **Comments**: only comment the *why* (a non-obvious constraint, a data quirk, a workaround). Never narrate what the code does.
- **CRS**: standardize to **EPSG:4326** (WGS84) for storage; reproject to **EPSG:5070** (Albers Equal Area, US) for area/distance calculations.

---

## Figure Standards (publication-ready)

All figures must use `theme_transit()` (defined in `R/00_setup.R`). Rules:

- Font: serif (matching typical journal style)
- No chart junk: no grid lines on maps, minimal axis decoration
- Color palettes: colorblind-safe (`viridis` or `RColorBrewer` "Set2")
- Export size: 6.5" wide (single column) or 13" wide (double column), 300 dpi minimum
- Export format: both `.pdf` (vector, for submission) and `.png` (raster, for sharing)
- No titles embedded in the figure -- captions go in the paper

---

## Workflow Rules

1. **Plan first**: for any non-trivial task, Claude presents a plan and waits for approval before writing code.
2. **One script per stage**: each `R/0X_*.R` file has a single, well-defined purpose.
3. **Reproducibility**:
   - All scripts must run top-to-bottom without manual intervention.
   - Use `set.seed()` for any stochastic operation.
   - Track packages with `renv` (initialize when starting analysis).
4. **Output discipline**: scripts write to `output/` or `data/processed/` -- never to the raw data folders.
5. **Check-in triggers** (Claude should pause and ask): ambiguous variable definitions, choice of cities to include, identification strategy decisions, any operation that modifies or overwrites data.

---

## Analysis Stages (current roadmap)

- [ ] Stage 1: Load and inspect data (`01_load_data.R`)
- [ ] Stage 2: Filter to US cities, clean fields (`02_filter_us.R`)
- [ ] Stage 3: Exploratory analysis -- mode distribution, opening year trends, city coverage (`03_explore.R`)
- [ ] Stage 4: Select target cities for case study
- [ ] Stage 5: Merge with housing/rent data (ACS via `tidycensus`, or external source TBD)
- [ ] Stage 6: Causal identification design (difference-in-differences or RD around opening years -- TBD)
- [ ] Stage 7: Proposal writeup support
