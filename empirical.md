# Empirical Facts Roadmap

## Transit data anchor: `NA_Transit`

Use the local `NA_Transit` project as the main source for transit network facts.

Local path:
`/Users/corgi/Library/Mobile Documents/com~apple~CloudDocs/NA_Transit`

Primary dataset:
- Source: The Transport Politic, Transit Explorer, April 2026.
- Citation: Yonah Freemark, Steven Vance, and OpenStreetMap contributors (2026). *The Transport Politic: Transit Explorer*. https://www.thetransportpolitic.com/transitexplorer
- License caveat: non-commercial, single-user; do not redistribute the base data.

Useful files:
- `data/processed/lines_us.geojson`: processed U.S. transit route segments.
- `data/processed/stations_us.geojson`: processed U.S. stations.
- `csv/lines.csv`: raw line/segment attributes.
- `csv/stations.csv`: raw station attributes.
- `R/03_explore.R`: existing exploratory analysis for mode distribution, opening years, and city coverage.

Key fields for this proposal:
- `region`: metro/city identifier.
- `mode`: transit technology, such as Light Rail, Metro, BRT, or Commuter Rail.
- `agency`: operating agency.
- `project`: corridor/project name; use this for line-level aggregation because route files are split into segments.
- `year_open`: opening year, useful for historical buildout and event timing.
- `route_km`: segment length, useful for network extent.
- `riders`: ridership, where available.
- `status`: existing, under construction, planned, etc.
- station `year_open`: station opening timing.

Important caveats:
- Segments are not lines. Do not count segment rows as distinct lines.
- Historic closed streetcar data are incomplete and should be used only with explicit caveats.
- Coverage varies by city; absence of a recorded project is not proof of no transit.
- Store derived outputs in the proposal project, but do not copy or redistribute raw source data.

## Commuting flow data anchor: LODES Dallas-Fort Worth

Use LEHD Origin-Destination Employment Statistics (LODES8) for commuting-flow moments.

Local files:
- `data/raw/lodes/tx_od_main_JT00_2023.csv.gz`: raw Texas 2023 OD main-jobs file.
- `data/raw/lodes/tx_xwalk.csv.gz`: raw Texas LODES crosswalk.
- `data/processed/lodes/dfw_od_main_JT00_2023_block.csv.gz`: Dallas-Fort Worth-Arlington block-level flow subset.
- `data/processed/lodes/dfw_od_main_JT00_2023_tract.csv.gz`: tract-to-tract flow aggregation.
- `data/processed/lodes/README.md`: source notes, county scope, columns, and sanity checks.

Current scope:
- Dallas-Fort Worth-Arlington MSA county set.
- A flow is included if either its home block or work block is in the MSA county set.
- This keeps within-metro, inbound, and outbound commuting flows.

Key fields:
- `w_geocode`, `h_geocode`: workplace and residence Census blocks.
- `w_tract`, `h_tract`: workplace and residence Census tracts in the processed tract file.
- `S000`: total jobs.
- `SA01`-`SA03`: age groups.
- `SE01`-`SE03`: earnings groups.
- `SI01`-`SI03`: industry groups.

Use in the proposal:
- Construct residence-workplace flow moments.
- Compare employment accessibility around transit corridors.
- Build tract-level commuting matrices for the spatial equilibrium model.
- Combine with ACS tract variables and `NA_Transit` station/line geography.

## Fact 1: Zoning and transportation are governed at different scales
Evidence:
- Municipal zoning authority
- MPO/regional transportation authority
- Transit agency board/funding variation

Model implication:
- Municipalities do not internalize regional transportation returns.

## Fact 2: Transit returns require local density
Evidence:
- Ridership per station / per route mile
- Station-area population and employment density
- From `NA_Transit`: route-km, stations, opening years, modes, projects, and available ridership by city/corridor

Model implication:
- Transit investment has stronger density complementarity than road investment.

## Fact 3: Zoning limits the density response to accessibility
Evidence:
- Lower housing growth near transit in restrictive places
- Lower permits / units / FAR near stations

Model implication:
- Zoning lowers the marginal return to transit.

## Fact 4: Restrictive zoning pushes growth outward
Evidence:
- Population/employment decentralization
- Longer commutes, higher car mode share

Model implication:
- Road investment becomes relatively more attractive.
