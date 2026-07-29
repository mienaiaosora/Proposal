# DFW County Appraisal District Parcel Data (2026-07-28)

Per §12.1 item 5: closes `H̄_i^R`, `H̄_j^F`, and (jointly with rents) the Glaeser-Gyourko-style commercial zoning-tax proxy. Checked each of the 11 DFW counties' appraisal districts (CADs) for public bulk parcel/appraisal-roll downloads. Contrary to the original checklist's assumption that this needs "contacting" the CADs, at least two of the largest publish genuinely open, unauthenticated bulk downloads — checked both, downloaded both.

## Dallas County (DCAD) — done, attribute roll only, no geometry

`dallas_dcad/DCAD2026_REAL_PROPERTY_CERT_APPR_ROLL.zip` (125MB zip, ~2.6GB uncompressed `.DAT` file), from DCAD's own "Data Products" page (`dallascad.org/dataproducts.aspx`), certified 2026 real-property appraisal roll — publicly downloadable with no login. This is an **attribute-only** flat file (property characteristics, valuations, land use codes — the field layout is documented in a companion `Add_Change_File_Format.xls`, not yet extracted/parsed here); it does **not** include parcel geometry. To map it spatially, it would need to be joined to a separate DCAD parcel-boundary GIS layer (DCAD's GIS help page, `maps.dcad.org/prd/dpm/help.htm`, references one, not yet located/pulled).

## Tarrant County (TAD) — done, full parcel shapefile with geometry

`tarrant_tad/tad_parcels.zip` (124MB), from Tarrant Appraisal District's ArcGIS Hub open-data portal (`gis-tad.opendata.arcgis.com`, dataset "TAD Parcels"), pulled as a shapefile export (also available as CSV/GeoJSON/KML from the same portal, or live from the underlying `ArcGIS GeoServices REST` endpoint `tad.newedgeservices.com/arcgis/rest/services/OD_TAD/OD_Parcels/MapServer/0`). This one **does** include parcel polygon geometry, keyed by `TAXPIN`.

## Remaining 9 counties — not yet pulled

Collin, Denton, Ellis, Hunt, Johnson, Kaufman, Parker, Rockwall, Wise. Not attempted individually in this bounded pass. The two patterns confirmed above (a CAD's own "data products" page serving flat appraisal-roll files, or a CAD-run ArcGIS Hub open-data portal serving a genuine parcel-geometry layer) are worth checking for each remaining CAD before assuming a manual request is needed — in Texas, bulk data downloads from CADs are common (many are required or choose to publish them for tax-transparency reasons). Search "`<county> appraisal district data download`" or "`<county> appraisal district open data`" for each.

Combined, Dallas + Tarrant already cover the two largest DFW counties by population and by tract count in this project's other data (see `data/processed/lodes/README.md`'s county tract-count breakdown), so this is a reasonable partial result even before pulling the remaining 9.
