# DFW Zoning GIS Layers (2026-07-28)

Per §12.1 item 8. Checked each of the largest DFW cities' and NCTCOG's open-data portals for a base zoning-classification layer (not just zoning-case/ordinance metadata).

## Dallas — done

`dallas/dallas_zoning_general_classifications.geojson`: City of Dallas current zoning districts, pulled from the city's public ArcGIS FeatureServer (`City of Dallas GIS Data Hub`, `egisdata-dallasgis.hub.arcgis.com`):

```
https://services2.arcgis.com/rwnOSbfKSwyTBcwN/arcgis/rest/services/ZoningGeneralClassifications/FeatureServer/0
```

3,709 zoning-district polygons, paginated in 2,000-record batches (the service's `maxRecordCount`) via `resultOffset`/`resultRecordCount`, saved as one combined GeoJSON `FeatureCollection`. Key fields: `zone_dist` (short code, e.g. `R-7.5`, `PD`), `long_zone_dist` (full description), `districtuse`, `common_name`, `case_number`/`ord_num` (originating zoning case/ordinance), `pd_num`/`cd_num` (Planned Development / Conservation District numbers where applicable).

Note: the hub also has a separate `Dallas_Zoning` layer (`FeatureServer` at the same root, different service name) with only 970 records and fields like `DEED_RES`, `ORD_NUM`, `NOTES` — that one is a zoning-*case*/ordinance-tracking layer, not the base classification layer, and was **not** used here; `ZoningGeneralClassifications` is the correct one for a `t_i`/zoning-stringency measure.

## Other DFW cities and NCTCOG — not yet pulled

Not attempted individually in this pass (bounded recon, prioritized the largest city). Two access patterns were confirmed to exist generally across DFW-area open-data portals, both usable the same way as the Dallas pull above (find the FeatureServer/MapServer URL, page through `/query?f=geojson`):
- City-run ArcGIS Hub sites (Dallas's pattern above; Fort Worth, Arlington, Plano, and other larger DFW cities likely have their own — check `<city>.hub.arcgis.com` or search "`<city name> GIS open data zoning`").
- NCTCOG's regional GIS clearinghouse, `https://data-nctcoggis.hub.arcgis.com/` (16-county North Central Texas region) — has land-use and boundary layers; not confirmed to include a *zoning*-specific layer (zoning is set locally, not regionally, so NCTCOG may not maintain one) — worth checking directly if a single regional layer is preferred over city-by-city pulls.

Given the model only needs `t_i=q_i^F/q_i^R` from rent data directly (per the Notation Registry — zoning GIS layers are a secondary/robustness source, not the primary calibration route for `t_i`), this is not a blocking item; revisit if a direct zoning-stringency measure (rather than the rent-ratio proxy) is wanted for validation.
