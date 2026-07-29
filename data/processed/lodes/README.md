# Dallas-Area LODES Flow Data

Source:
- U.S. Census Bureau LEHD Origin-Destination Employment Statistics, LODES8.
- State: Texas.
- Year: 2023.
- OD file: `tx_od_main_JT00_2023.csv.gz`.
- Crosswalk: `tx_xwalk.csv.gz`.

Raw files:
- `data/raw/lodes/tx_od_main_JT00_2023.csv.gz`
- `data/raw/lodes/tx_xwalk.csv.gz`

Processed files:
- `dfw_od_main_JT00_2023_block.csv.gz`: block-to-block job flows where either the workplace block or residence block is in the Dallas-Fort Worth-Arlington MSA county set.
- `dfw_od_main_JT00_2023_tract.csv.gz`: tract-to-tract aggregation of the block file.

Dallas-Fort Worth-Arlington county set:
- Collin County: `48085`
- Dallas County: `48113`
- Denton County: `48121`
- Ellis County: `48139`
- Hunt County: `48231`
- Johnson County: `48251`
- Kaufman County: `48257`
- Parker County: `48367`
- Rockwall County: `48397`
- Tarrant County: `48439`
- Wise County: `48497`

Filter rule:
- Keep a row if either `w_geocode` or `h_geocode` starts with one of the county FIPS codes above.
- This preserves within-DFW, inbound-to-DFW, and outbound-from-DFW flows.

Columns:
- `w_geocode`: workplace Census block.
- `h_geocode`: residence Census block.
- `w_tract`: workplace Census tract, derived from the first 11 digits of `w_geocode`.
- `h_tract`: residence Census tract, derived from the first 11 digits of `h_geocode`.
- `S000`: total jobs.
- `SA01`, `SA02`, `SA03`: jobs by worker age group.
- `SE01`, `SE02`, `SE03`: jobs by earnings group.
- `SI01`, `SI02`, `SI03`: jobs by industry group.

Sanity checks:
- Block-level processed file: 4,159,207 rows including header.
- Tract-level processed file: 1,548,071 rows including header.
- Tract-level `S000` sum: 4,460,409 jobs.

Next refinement:
- If the proposal needs City of Dallas rather than the full metro area, filter blocks using an explicit city/place boundary or parse the LODES crosswalk with a CSV-aware tool. Do not treat Dallas County as equivalent to City of Dallas.

## JT01 (primary jobs), 2026-07-28

Per §12.1 item 1: re-pulled as `JT01` (primary jobs only, i.e. each worker's single highest-paying job) rather than `JT00` (all jobs, including secondary/multiple-job holders), since `JT01` is the standard choice for a one-workplace-per-worker discrete-choice model like this one's.

Source:
- Same LODES8/2023/Texas vintage as the JT00 pull above, `tx_od_main_JT01_2023.csv.gz`.
- **Host correction**: the JT00 README above doesn't state a URL, but the download host used at the time was `lehd.ce.census.gov`, which no longer resolves. LEHD's current host is `lehd.ces.census.gov` (note the extra `s`) — e.g. `https://lehd.ces.census.gov/data/lodes/LODES8/tx/od/tx_od_main_JT01_2023.csv.gz`. Use this host for any future LODES re-pulls, including if JT00 is ever re-downloaded.
- Reuses the existing `data/raw/lodes/tx_xwalk.csv.gz` crosswalk (state- and vintage-invariant).

Raw file:
- `data/raw/lodes/tx_od_main_JT01_2023.csv.gz`

Processed files (same filter rule, same DFW county set, same column derivation as the JT00 files above):
- `dfw_od_main_JT01_2023_block.csv.gz`
- `dfw_od_main_JT01_2023_tract.csv.gz`

Sanity checks:
- Statewide JT01 row count: 11,225,546 (vs. JT00's larger, unrecorded statewide count — JT01 is a subset of JT00 by construction, since it excludes secondary jobs).
- DFW-filtered block-level rows: 3,874,380 (JT00: 4,159,207 — about 7% fewer, consistent with dropping secondary jobs).
- DFW-filtered tract-level rows: 1,467,209 (JT00: 1,548,071).
- Tract-level `S000` sum: 4,152,953 jobs (JT00: 4,460,409 — about 6.9% fewer total jobs, in line with the row-count drop).

Use JT01 as the primary series for calibration (single workplace per worker matches the model's discrete residence–workplace choice); keep JT00 as a robustness/coverage check per the original §12.1 note.
