# DFW Tract-Level Rent (ACS 5-Year)

Closes §12.1's ACS item, unblocked 2026-07-28 once a Census API key was provided (the API now hard-requires one; see `data/raw/lodes/README.md`-style note in `data/processed/lodes/README.md` for the same "access got stricter" pattern with LODES's host).

Source:
- U.S. Census Bureau, American Community Survey 5-Year Estimates, 2023 vintage (2019–2023 period).
- Tables: `B25064` (median gross rent), `B25071` (median gross rent as a percentage of household income), `B25070` (gross rent as a percentage of income, distribution across 9 bins).
- Geography: tract level, all tracts in the 11 DFW counties (same FIPS set used throughout this project).
- API key used to make this pull is **not** stored in this repo (kept out of any committed file); regenerate or reuse the same free key from `api.census.gov/data/key_signup.html` for future pulls.

Raw file:
- `data/raw/acs/acs5_2023_dfw_rent.csv` — direct API response, one row per tract, 1,704 tracts across the 11 counties.

Processed file:
- `data/processed/acs/acs5_2023_dfw_tract_rent.csv` — renamed/cleaned columns:
  - `tract_geoid`, `county_fips`, `county_name`, `NAME` (Census's tract label).
  - `median_gross_rent`, `median_gross_rent_moe`: table B25064, dollars, with margin of error.
  - `median_gross_rent_pct_income`, `median_gross_rent_pct_income_moe`: table B25071.
  - `renter_hh_total`: table B25070 total renter-occupied households (denominator for the bins below).
  - `rent_pct_lt10`, `rent_pct_10to14_9`, ..., `rent_pct_50plus`: table B25070's 9 rent-burden bins (share of income spent on rent), as household counts, not yet converted to shares.

Sanity checks:
- 1,704 DFW tracts total (Dallas 645, Tarrant 449, Collin 220, Denton 193, Johnson 39, Ellis 36, Parker 29, Rockwall 29, Kaufman 27, Hunt 21, Wise 16) — this is a different tract count than the 1,312 tracts in `data/processed/geo/dfw_tract_to_place.csv`, because that crosswalk used 2019 Census tract boundaries while this ACS 2023 5-year release uses 2020 tract boundaries (the decennial redrew many DFW tracts, especially in fast-growing Collin/Denton/Tarrant). **Do not join these two files on `tract_geoid` without first reconciling 2019 vs. 2020 tract vintages** — a Census tract relationship/crosswalk file would be needed.
- 80 of 1,704 tracts have a negative (Census's suppression code, typically `-666666666`) `median_gross_rent` — these are tracts with too few sampled renter households for a reliable ACS 5-year estimate, not zero rent; excluded from the summary stats below.
- Non-suppressed median gross rent: mean $1,682/mo, median $1,583/mo, range $591–$3,501 across DFW tracts — a plausible spread for the DFW metro.

Next refinement: this closes $q_i^R$'s *data* gap; it has not yet been reconciled to the 2019-tract-vintage files elsewhere in this project (LODES, the WRLURI/gamma files, the `g(i)` crosswalk) — before using $q_i^R$ jointly with those, either re-pull the geography files at 2020-tract vintage or find a Census tract-relationship crosswalk to convert one direction.
