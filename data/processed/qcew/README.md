# BLS QCEW DFW County Wages

Per §12.1 item 3: sharpens `w_j` beyond the LODES OD file's coarse earnings bins (`SE01`/`SE02`/`SE03`) with actual average annual/weekly pay by county and industry.

Source:
- U.S. Bureau of Labor Statistics, Quarterly Census of Employment and Wages (QCEW), Open Data API.
- Endpoint: `https://data.bls.gov/cew/data/api/{year}/a/area/{county_fips}.csv` (annual-averages file; no API key required).
- Year: 2023 (matches the LODES 2023 vintage).
- Geography: same 11-county DFW set used throughout (`data/processed/lodes/README.md`).

Raw files (one per county, full QCEW annual-averages extract — all ownership/industry/aggregation levels):
- `data/raw/qcew/qcew_{county_fips}_2023_annual.csv`

Processed files:
- `qcew_dfw_county_total_2023.csv`: county-level, all industries, all ownerships (`agglvl_code == 70`, `own_code == 0`, `industry_code == 10`). One row per county: establishment count, average employment, total wages, average weekly wage, average annual pay.
- `qcew_dfw_county_supersector_private_2023.csv`: county × NAICS supersector, **private ownership only** (`agglvl_code == 73`, `own_code == 5`). QCEW does not publish a NAICS-supersector breakdown pooled across ownership types at the county level (only total-all-industries is available unsplit, `agglvl_code == 70`); private ownership is used here as the standard QCEW convention for industry-level wage tables and because government-sector pay is set administratively rather than reflecting local labor-market accessibility, which is the object `w_j` is meant to capture. If workplace wages for public-sector-heavy tracts need separate treatment, the raw per-county files also contain `own_code` 1 (federal), 2 (state), and 3 (local) government breakdowns at `agglvl_code` 73–74.

Columns kept in both processed files: `area_fips`, `county_name`, (`industry_code`, `own_code` in the supersector file), `year`, `annual_avg_estabs`, `annual_avg_emplvl`, `total_annual_wages`, `annual_avg_wkly_wage`, `avg_annual_pay`.

Sanity check — county-total average annual pay, 2023 (`qcew_dfw_county_total_2023.csv`): ranges from $53,825 (Kaufman) to $86,340 (Dallas), consistent with Dallas and Tarrant Counties' urban-core wage premium relative to the outer-ring counties (Ellis, Hunt, Johnson, Kaufman, Parker, Rockwall, Wise), matching the expected DFW wage gradient.

Next refinement: this is county-level, not tract- or workplace-location-level. If `w_j` needs finer spatial resolution than county, QCEW's finest published geography is county-by-industry (used here); a tract-level wage surface would need to come from LODES earnings bins (already available) reweighted by these county-industry means, or from a separate microdata source (e.g. ACS/LEHD-based small-area income estimates).
