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
