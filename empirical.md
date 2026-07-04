# Empirical Facts Roadmap

## Data Anchors

### Transit network: `NA_Transit`

Local path: `NA_Transit/` (inside project root)

Primary dataset:
- Source: The Transport Politic, Transit Explorer, April 2026.
- Citation: Yonah Freemark, Steven Vance, and OpenStreetMap contributors (2026). *The Transport Politic: Transit Explorer*. https://www.thetransportpolitic.com/transitexplorer
- License caveat: non-commercial, single-user; do not redistribute the base data.

Useful files:
- `NA_Transit/output/figures/lines_us.geojson`: US-filtered transit route segments (output of `02_filter_us.R`).
- `NA_Transit/output/figures/stations_us.geojson`: US-filtered stations.
- `NA_Transit/csv/lines.csv`: raw line/segment attributes (do not modify).
- `NA_Transit/csv/stations.csv`: raw station attributes (do not modify).
- `NA_Transit/R/03_explore.R`: existing exploratory analysis; already produced `city_route_km_by_mode.png` and `opening_year_distribution.png`.

Key fields:
- `region`: metro/city identifier. DFW string is `"Dallas TX USA"`.
- `mode`: transit technology (Light Rail, Metro, BRT, Commuter Rail, Streetcar).
- `project`: corridor/project name — use for line-level aggregation (segments ≠ lines).
- `year_open`: opening year.
- `route_km`: segment length (km).
- `riders`: ridership, sparse coverage.
- `status`: existing, under construction, planned, etc.
- `country`: use to filter to `"USA"`.

Caveats:
- Segments are not lines; use `project` as line-level unit.
- Historic closed streetcar data are incomplete.
- `riders` field has many NAs; do not use as primary outcome without flagging coverage.

---

### Commuting flows: LODES Dallas-Fort Worth

Local files (relative to project root):
- `data/raw/lodes/tx_od_main_JT00_2023.csv.gz`: raw Texas 2023 OD file.
- `data/raw/lodes/tx_xwalk.csv.gz`: Texas LODES crosswalk.
- `data/processed/lodes/dfw_od_main_JT00_2023_block.csv.gz`: block-level DFW flows.
- `data/processed/lodes/dfw_od_main_JT00_2023_tract.csv.gz`: **tract-to-tract aggregation — primary analysis file.**
- `data/processed/lodes/README.md`: county scope, columns, sanity checks.

Scope: Dallas-Fort Worth-Arlington MSA (11 counties). Flow included if either home or work block is in the MSA. Total: ~4.46 million jobs, ~1.55 million tract-pair rows.

Key fields:
- `w_tract`, `h_tract`: 11-digit Census tract FIPS (workplace and residence).
- `S000`: total jobs on that OD pair.
- `SE01`–`SE03`: earnings groups (low / mid / high).

Join key: `w_tract` and `h_tract` are 11-digit FIPS → link directly to `ctracts2000` in the Baum-Snow & Han data and to Census tract geometries from `tidycensus`.

---

### Housing supply elasticity: Baum-Snow & Han (2024)

Local path: `/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/`

Files:
- `gammas_hat_all.dta`: **tract-level**, 63,897 tracts nationwide.
- `region_gammas.dta`: **metro-level**, 306 metros.
- `gamma_hat_explanation_sep2023.pdf`: variable definitions.

#### Tract-level file (`gammas_hat_all.dta`)

| Field | Meaning |
|-------|---------|
| `ctracts2000` | 11-digit 2000 Census tract FIPS — joins to LODES `w_tract`/`h_tract` |
| `cbdname` | Metro name (`"Dallas"` for DFW) |
| `pctdis` | Normalized distance from metro CBD (0 = center, 1 = periphery) |
| `gamma01a_units_IV` | Housing supply elasticity, 2000–2010, units, IV estimate ← **primary** |
| `gamma11a_units_IV` | Housing supply elasticity, 2010–2020, units, IV estimate |
| `gamma01a_space_IV` | Elasticity for floor space (rather than unit count) |
| `sd_gamma01a_units_IV` | Standard error of primary estimate |
| `primary_sample` | Indicator: 1 = in the paper's primary estimation sample |
| `Trct_FrcDev_01` | Fraction of tract area developed in 2001 |
| `lsf_1_flat_plains` | Land supply factor (topographic constraint proxy) |

DFW coverage: **1,016 tracts**. Elasticity range: −0.52 to +0.99, median 0.36.
Low elasticity = more constrained supply = effectively restrictive, regardless of formal zoning code.

#### Metro-level file (`region_gammas.dta`)

| Field | Meaning |
|-------|---------|
| `cbdname` | Metro name |
| `WRLURI_metro2` | Wxharton Residential Land Use Regulatory Index |
| `region_gamma101a_units_IV` | Metro-level elasticity (inner ring, 2000–2010) |
| `region_gamma201a_units_IV` | Metro-level elasticity (outer ring, 2000–2010) |
| `Tot_FrcDev50_01` | Fraction of land within 50 km developed in 2001 |
| `Tot_FrcUnavail50_01` | Fraction unavailable (water, protected) within 50 km |
| `numtracts` | Number of tracts in metro |

306 metros. WRLURI range: −1.76 (permissive) to +2.81 (restrictive).
Dallas: WRLURI = −0.251 (relatively permissive overall; most restrictive metros are Boston-area suburbs).

Cross-metro join: match NA_Transit `region` strings to `cbdname` manually or via a lookup table (naming conventions differ).

---

## Facts and Evidence Plan

### Fact 1: Zoning and transportation are governed at different scales
**Evidence (institutional, no data needed):**
- Municipal zoning authority is local.
- Transportation investment decided by MPO / regional transit agency.
- Single municipality cannot internalize the effect of its zoning on regional transit returns.

**Model implication:** Municipalities do not internalize how their zoning choices lower the metropolitan transportation authority's return to transit investment.

---

### Fact 2: Transit returns require local density
**Evidence:**
- Cross-metro scatter: total transit route-km vs. metro population/employment density (NA_Transit + Census).
- Within-DFW: map employment concentration by tract (LODES inflows) + DART network overlay — shows that DART serves a small share of DFW employment geography.

**Planned figure:** `dfw_employment_map` — choropleth of employment inflows by tract, DART lines and stations overlaid.

**Model implication:** Transit investment has stronger density complementarity than road investment.

---

### Fact 3: Zoning limits the density response to accessibility
**Evidence:**
- Within-DFW: housing supply elasticity by tract (Baum-Snow & Han tract file, `gamma01a_units_IV`) mapped against DART station proximity. Low-elasticity tracts near stations = housing supply constrained even where transit exists.
- Merge path: LODES `w_tract` → `ctracts2000` (Baum-Snow & Han) → Census tract geometry (tidycensus) → DART station buffer (NA_Transit stations).
- Cross-metro: WRLURI vs. transit km per capita — restrictive metros have less transit network per person.

**Planned figures:**
- `dfw_elasticity_map` — choropleth of `gamma01a_units_IV` by DFW tract, DART overlay.
- `crossmetro_wrluri_transit` — scatter of WRLURI vs. transit route-km per 100k residents, 306 metros.

**Model implication:** Zoning lowers the marginal return to transit by suppressing density near high-accessibility locations.

---

### Fact 4: Restrictive zoning pushes employment and residents outward
**Evidence:**
- Within-DFW: compute employment accessibility index by tract (sum of jobs in nearby tracts, distance-weighted from LODES), plot against `pctdis` (distance from CBD). Compare elasticity gradient against accessibility gradient.
- High employment tracts at low `pctdis` with low elasticity = central locations that are constrained despite high demand.

**Planned figure:** `dfw_accessibility_elasticity` — scatter or binned plot of housing supply elasticity vs. distance from CBD, with employment density as point size.

**Model implication:** Road investment becomes relatively more attractive when growth is displaced outward, reinforcing the car-dependent equilibrium.

---

## Planned Analysis Scripts

| Script | Location | Inputs | Output |
|--------|----------|--------|--------|
| `04_dfw_case.R` | `NA_Transit/R/` | LODES tract file, stations_us.geojson (Dallas filter), tidycensus tracts | `dfw_employment_map` |
| `05_dfw_elasticity.R` | `NA_Transit/R/` | Baum-Snow Han tract file, DART stations, tidycensus tracts | `dfw_elasticity_map` |
| `06_crossmetro.R` | `NA_Transit/R/` | region_gammas.dta (WRLURI), NA_Transit lines (route_km by region) | `crossmetro_wrluri_transit` |

LODES data is outside the NA_Transit project root; reference it as `here::here("..", "data", "processed", "lodes", ...)` from within NA_Transit scripts, or use the absolute path `/Volumes/ORICO/Proposal for SYP/Proposal/data/processed/lodes/`.

Baum-Snow & Han data is at `/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/` — use absolute path since it lives outside the project.

