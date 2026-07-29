# DFW Transit GTFS Static Feeds (2026-07-28)

Per §12.1 item 6 ("needed once route choice is introduced, not for the current benchmark"): static GTFS feeds for all three DFW-area transit operators, pulled directly from each agency's own feed URL (no aggregator, no auth needed).

| File | Agency | Source URL |
|---|---|---|
| `dart_gtfs.zip` | Dallas Area Rapid Transit (DART) | `https://www.dart.org/transitdata/latest/google_transit.zip` |
| `trinity_metro_gtfs.zip` | Trinity Metro (Fort Worth Transportation Authority, incl. TEXRail) | `http://sched.ridetm.org/gtfs/fwtatransitdata.zip` |
| `dcta_gtfs.zip` | Denton County Transportation Authority (DCTA, incl. the A-train) | `https://gtfs.remix.com/dcta_denton_tx_us.zip` |

All three are official agency-hosted feeds, not third-party mirrors (verified against each agency's own GTFS-data page: `dart.org/transitdata`, `ridetrinitymetro.org/gtfs-data/`, `dcta.net/resources/open-data`). Each archive was spot-checked with `unzip -l` to confirm it's a valid GTFS bundle (standard files like `agency.txt`, `stops.txt`, `routes.txt`, `stop_times.txt` present).

Not yet processed into route/stop tables for the model — flagged in `quantification_exogenous_characteristics.md` §11 as needed only once endogenous multi-route/mode choice is introduced. For the current benchmark (fixed exogenous routes), these feeds are useful now mainly for identifying rail/BRT station locations as candidate high-accessibility nodes.
