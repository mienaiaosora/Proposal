# DFW Tract-to-Place Crosswalk (`g(i)`)

Per §12.1 item 10: constructs the mapping `g(i)` from each residence/workplace tract `i` to its municipality `g`, needed to assign tracts to the municipalities that set zoning in the model.

Source shapefiles:
- Tracts: 2019 Census Cartographic Boundary Files, Texas, 500k resolution — `https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_48_tract_500k.zip`, downloaded fresh (not previously in the repo). Raw copy: `data/raw/geo/cb_2019_48_tract_500k/`.
- Places (incorporated cities/CDPs): already in the repo at `data/song_mls_estimator/231447-V1/data/map/cb_2019_us_place_500k/` (same 2019 500k vintage — matches the tract file).

Method:
1. Filter tracts to the 11 DFW counties (same FIPS set as `data/processed/lodes/README.md`); filter places to Texas.
2. Reproject both layers to Texas Centric Albers Equal-Area (EPSG:3083) for accurate area computation.
3. Overlay (polygon intersection) tracts against places; for each tract, assign the place with the **largest area of overlap** (not necessarily majority — see caveat below).
4. Tracts with zero overlap with any Census place (fully unincorporated land) are kept with `place_geoid = NULL`, `place_name = "Unincorporated / no Census place"`.

Output: `dfw_tract_to_place.csv`, one row per DFW tract:
- `tract_geoid`: 11-digit 2019 Census tract GEOID.
- `county_fips`.
- `place_geoid`, `place_name`: the assigned Census place (or null/unincorporated).
- `frac_tract_in_place`: the assigned place's share of the tract's land area — **not always close to 1**. A tract straddling a city boundary, where most of its area is unincorporated county land but a small corner falls inside a place, is still assigned to that place under the largest-overlap rule even if `frac_tract_in_place` is small (e.g. 0.03). If `g(i)` needs a stricter "tract is genuinely inside municipality `g`" definition, filter on a `frac_tract_in_place` threshold (e.g. ≥0.5) and reclassify low-overlap tracts as unincorporated/unassigned instead.

Sanity checks:
- 1,312 DFW tracts total; 1,309 assigned to a place, 3 with no place overlap (fully unincorporated).
- Largest place counts by number of assigned tracts: Dallas (302), Fort Worth (154), Arlington (70), Plano (57), Irving (52) — consistent with known DFW city sizes.
- A polygon-overlay warning reported 1,383 dropped sliver geometries (line/point intersections from tracts and places sharing only a boundary edge, not real area overlap) — expected and immaterial to the largest-area assignment rule.

Next refinement: some DFW places are CDPs (Census-designated places, not incorporated, no local zoning authority) rather than true municipalities. If the model's `g(i)` needs to exclude CDPs (since they have no municipal government to set zoning), filter `cb_2019_us_place_500k`'s `LSAD` field (`25` = city/incorporated place vs. `57` = CDP) before the overlay step — not yet done here, this crosswalk includes both.
