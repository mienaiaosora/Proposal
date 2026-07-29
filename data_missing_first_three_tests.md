# Data Gaps for the First Three Empirical Tests

This note follows the first three tests in Section 6 of
`model_comments_organized.md`. It distinguishes data already available from
data required for the preferred empirical design.

## Important geography issue

Baum-Snow and Han's `ctracts2000` identifies 2000 Census tracts. The 2023 LODES
files use 2020 Census blocks and tracts. These identifiers must not be treated
as a direct one-to-one join.

Missing:

- a 2000-to-2010/2020 tract relationship file;
- explicit allocation weights, preferably population or housing-unit weights;
- a documented choice of the analysis geography.

Required output:

`data/processed/crosswalks/tract2000_to_analysis.csv`

with:

- `tract2000`;
- `tract_fips`;
- `weight`.

## Test 1: Accessibility shock × housing-supply restrictiveness

### Already available

- DFW station locations and opening years from Transit Explorer;
- Baum-Snow and Han tract-level housing-supply elasticities;
- a 2023 LODES OD cross section;
- current cross-sectional population and housing-unit controls in the Song
  replication files.

### Missing

1. A harmonized tract-year outcome panel containing at least:
   - housing units;
   - residential floor space or permitted floor area;
   - population;
   - employment;
   - residential rents or prices;
   - transit ridership, where geographically available.
2. The 2000-to-analysis-tract crosswalk described above.
3. A complete DFW tract geometry file:
   `data/processed/geography/dfw_analysis_tracts.gpkg`.
4. A defensible accessibility measure by tract and year:
   - distance-to-open-station is the minimum;
   - a GTFS/network travel-time accessibility index is preferred.
5. Historical station service and closure information if openings are used as
   events.
6. Pre-opening covariates and a decision about the event window.

### Candidate sources

- Decennial Census and ACS five-year tract tables;
- HUD USPS vacancy/address data;
- Census Building Permits Survey, where geography permits;
- local permit and appraisal records;
- Zillow/ZTRAX or another consistent price and floor-space source;
- agency station-entry or route-level ridership records;
- historical GTFS or NTD service data.

## Test 2: Cross-boundary displacement

### Already available

- 2019 Census place boundaries;
- Baum-Snow and Han effective housing-supply elasticity;
- current tract/CBG characteristics;
- DFW transit stations and opening years.

### Missing

1. Time-varying municipal zoning or permitted-capacity data.
2. Residential and commercial construction or floor-space outcomes by small
   geography and year.
3. Historical municipal boundaries aligned to each outcome year.
4. Dated local zoning reforms, transportation shocks, or demand shocks.
5. Parcel- or tract-level allowable use, FAR, height, lot-size, and density.
6. A boundary-pair construction file containing:
   - boundary identifier;
   - tract or parcel on each side;
   - distance to the boundary;
   - pre-period similarity measures;
   - treatment timing.

### Why Baum-Snow and Han alone are insufficient

Their elasticity is a reduced-form housing-supply response that combines
regulation, topography, undeveloped land, and redevelopment opportunities. It
is not a direct zoning rule, and one cross section cannot establish that
development was displaced across a boundary after a shock.

### Candidate sources

- municipal zoning GIS layers and zoning histories;
- NCTCOG regional land-use layers;
- Dallas, Fort Worth, Plano, and other municipal open-data portals;
- county appraisal districts;
- local building-permit microdata;
- Zoneomics/ZoneComics if coverage and licensing are feasible.

## Test 3: Residential–commercial zoning and jobs–housing imbalance

### Already available

- 2023 LODES block-to-block flows;
- the LODES block-to-place crosswalk;
- municipality identifiers;
- residential population attached to jobs, workplace employment, inbound
  commuting, outbound commuting, and within-place commuting.

The available script constructs these outcomes immediately.

### Missing

The central explanatory variable:

- permitted residential floor-space capacity;
- permitted commercial floor-space capacity; or
- a defensible residential share of total permitted capacity.

Required file:

`data/processed/zoning/municipality_capacity.csv`

with at least:

- `place_code`;
- `residential_capacity`;
- `commercial_capacity`.

Preferred additional controls:

- municipal land area;
- total permitted FAR;
- developed share;
- topographic constraints;
- distance to the CBD;
- baseline highway and transit access;
- income and demographic composition;
- pre-period population and employment;
- municipality age and boundary changes.

### Important current-data limitation

The local LODES file is `JT00` (all jobs), whereas primary jobs (`JT01`) are
preferable for a worker-based jobs–housing measure. A `JT01` pull should be
added and the results compared.

## Priority order

1. Obtain or build `municipality_capacity.csv`; this completes Test 3.
2. Build a correct 2000-to-analysis-tract crosswalk.
3. Assemble tract-year Census/ACS outcomes for Test 1.
4. Obtain historical zoning and permit data for the preferred Test 2 design.
5. Pull LODES `JT01` for robustness.
