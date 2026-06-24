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
