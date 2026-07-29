# WRLURI Metro Data

Source file copied from:

`/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/region_gammas.dta`

Project copies:

- Raw copy: `data/raw/wrluri/region_gammas.dta`
- Processed CSV: `data/processed/wrluri/wrluri_metro.csv`

The processed CSV contains 306 metropolitan areas and keeps the variables needed for the cross-metro zoning-transit test:

- `cbdname`: metro name in the Baum-Snow and Han data.
- `region_all`: metro identifier.
- `WRLURI_metro2`: Wharton Residential Land Use Regulatory Index; higher values mean more restrictive land-use regulation.
- `Tot_FrcDev50_01`: fraction of land within 50 km developed in 2001.
- `Tot_FrcUnavail50_01`: fraction of land within 50 km unavailable for development.
- `numtracts`: number of tracts in the metro sample.
- `region_gamma101a_units_IV`: inner-ring metro housing supply elasticity, units, 2000-2010.
- `region_gamma201a_units_IV`: outer-ring metro housing supply elasticity, units, 2000-2010.
- `region_gamma101a_space_IV`: inner-ring metro housing supply elasticity, floor space, 2000-2010.
- `region_gamma201a_space_IV`: outer-ring metro housing supply elasticity, floor space, 2000-2010.

For Proposition 3, join this file to the NA_Transit metro route-km aggregation by manually matching `cbdname` to the Transit Explorer `region` field.

## Tract-level elasticities (`gammas_hat_all.dta`)

Source file copied from:

`/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/gammas_hat_all.dta`

Companion documentation copied from the same location: `gamma_hat_explanation_sep2023.pdf`.

Project copies:

- Raw copy: `data/raw/wrluri/gammas_hat_all.dta`, `data/raw/wrluri/gamma_hat_explanation_sep2023.pdf`
- Processed CSV: `data/processed/wrluri/gammas_hat_dfw_tract.csv`

This is the **tract-level** companion to `region_gammas.dta` above: Baum-Snow & Han (2023, *JPE*, "The Microgeography of Housing Supply") predicted housing-supply elasticities for 63,897 tract-year observations across 24,532 tracts in 169 U.S. metro regions. The processed CSV keeps only the 1,016 tracts with `cbdname == "Dallas"` (Baum-Snow & Han's CBSA/CBD grouping for the DFW metro — covers 9 of the 11 counties in this project's DFW set; Hunt and Wise Counties have no qualifying tracts under their estimation-sample criteria, §1.3 of the explanation PDF: ZTRAX unit-count coverage ≥75% of the 2000 Census count, ≥500 units in the tract as of Dec. 2000, and a computable repeat-sales index in both 2000 and 2010).

Columns kept (renamed `ctracts2000` → `tract_geoid`, an 11-digit 2000 Census tract GEOID; `county_fips` derived as its first 5 digits):

- `tract_geoid`, `county_fips`, `cbdname`, `region_all`: identifiers.
- `pctdis`: fraction of the tract's land within the CBSA that is not developable (distance/availability control used in the FMM class-probability model).
- `primary_sample`: 1 if the tract is in Baum-Snow & Han's core estimation sample (not just predicted out-of-sample).
- `Trct_FrcDev_01`, `Trct_FrcDev_11`: fraction of tract land developed as of 2001 / 2011 (the two vintages the elasticities are predicted from).
- `wgt`, `H_share`: estimation weight and the tract's housing-unit share of its metro.
- `gamma01b_*_FMM` / `sd_gamma01b_*_FMM` (TYPE ∈ `units`, `space`, `newunits`, `newspace`, `devl`): the paper's **recommended** estimates (§2.2 of the explanation PDF) — quadratic specification (`b`), finite-mixture-model estimator (`FMM`), 2001 developed-fraction vintage (`01`) — with prediction standard deviations. `units`/`space` are housing-unit and floor-space supply elasticities; `newunits`/`newspace` are the analogous new-construction-only measures (technically not elasticities, see PDF §1.4); `devl` is land-development responsiveness.
- `gamma01a_units_IV`, `gamma01a_space_IV` (+ `sd_`): the simpler linear/IV alternative, kept for robustness comparison against the FMM estimates.

For this project's `t_i`/`H̄_i^R` calibration, `gamma01b_space_FMM` (floor-space supply elasticity) is the closest match to the model's zoning-responsiveness margin; `gamma01b_units_FMM` is the closer match if calibrating against a units-based housing-supply elasticity instead.
