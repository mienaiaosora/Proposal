# Testing Model Propositions

This note translates the model's first-order conditions into three empirical tests. The purpose is not to claim full causal identification at this stage, but to show that the data can discipline the key mechanism: local congestion motives tighten zoning, transit access amplifies this motive, and restrictive land use lowers the return to transit investment.

## Overview

The model implies the following chain:

1. High employment and population concentration raise the municipal marginal congestion cost of loosening zoning.
2. Transit access raises residential attractiveness and population pressure, which can trigger a zoning-tightening response.
3. Restrictive zoning suppresses density around transit, reducing the return to transit investment at the metropolitan scale.

Empirically, I use housing supply elasticity from Baum-Snow and Han as the tract- or metro-level proxy for zoning restrictiveness. Lower elasticity means the local housing stock responds less to demand shocks, so it corresponds to more restrictive zoning or tighter effective land-use constraints.

## Data Sources

### Tract-Level Dallas-Fort Worth Data

Primary files:

- LODES tract commuting flows: `data/processed/lodes/dfw_od_main_JT00_2023_tract.csv.gz`
- Baum-Snow and Han tract elasticities: `/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/gammas_hat_all.dta`
- DART stations: `NA_Transit/data/processed/stations_us.geojson`

Key variables:

- `w_tract`: 11-digit workplace Census tract FIPS from LODES.
- `h_tract`: 11-digit residence Census tract FIPS from LODES.
- `S000`: total jobs on each origin-destination pair.
- `ctracts2000`: 11-digit tract FIPS in Baum-Snow and Han.
- `cbdname`: metro identifier; use `"Dallas"` for DFW.
- `pctdis`: normalized distance from the CBD.
- `gamma01a_units_IV`: primary tract-level housing supply elasticity.
- `gamma11a_units_IV`: alternative elasticity measure for 2010-2020.

### Cross-Metro Data

Primary files:

- Baum-Snow and Han metro elasticities and WRLURI: `/Volumes/ORICO/Housing_sup_elasticity_Baum-snow/region_gammas.dta`
- Transit Explorer route segments: `NA_Transit/data/processed/lines_us.geojson`

Key variables:

- `cbdname`: Baum-Snow and Han metro name.
- `WRLURI_metro2`: Wharton Residential Land Use Regulatory Index.
- `Tot_FrcUnavail50_01`: fraction of unavailable land within 50 km.
- `region`: Transit Explorer metro/city identifier.
- `route_km`: route segment length in kilometers.
- `mode`: transit technology.
- `status`: use existing/open systems for the baseline.

Because `region` and `cbdname` use different naming conventions, the cross-metro test requires a manually checked metro-name lookup table.

## Proposition 1: Employment Concentration Tightens Residential Zoning

### Model Logic

In the municipal zoning FOC, the congestion cost from loosening residential zoning includes:

$$
N_i \cdot \frac{\partial \bar{U}_i}{\partial \phi}
\cdot (1+\rho)\eta_N N_i^\rho
\cdot \frac{\partial N_i}{\partial \bar{H}_i^R}.
$$

There is a parallel term involving employment concentration:

$$
(1+\rho)\eta_L L_i^\rho.
$$

Thus, locations with large employment inflows face higher marginal congestion costs from allowing more residential density. The municipal optimum should therefore be more restrictive in high-employment tracts.

### Testable Prediction

Housing supply elasticity should be lower in tracts with larger employment inflows:

$$
\gamma_i = \beta_0 + \beta_1 \log L_i + \beta_2 \text{pctdis}_i + \varepsilon_i,
$$

with:

$$
\hat{\beta}_1 < 0.
$$

### Variable Construction

1. Filter Baum-Snow and Han tract data to DFW:

   - Keep observations with `cbdname == "Dallas"`.
   - Use `gamma01a_units_IV` as the baseline outcome.
   - Keep `pctdis` and any available standard error or sample indicator.

2. Construct tract employment inflows from LODES:

   $$
   L_i = \sum_h S000_{hi},
   $$

   where `i` is the workplace tract `w_tract`.

3. Join employment to elasticity:

   - Join `w_tract` to `ctracts2000`.
   - Convert both identifiers to character strings padded to 11 digits.

4. Define:

   $$
   \log L_i = \log(1 + L_i).
   $$

   The `+1` keeps zero-employment tracts in the sample.

### Baseline Specification

```r
lm(gamma01a_units_IV ~ log1p(employment) + pctdis, data = dfw_tracts)
```

### Preferred Additions

Add controls that separate zoning restrictiveness from physical land constraints:

$$
\gamma_i =
\beta_0
+ \beta_1 \log L_i
+ \beta_2 \text{pctdis}_i
+ \beta_3 \text{Trct\_FrcDev\_01}_i
+ \beta_4 \text{lsf\_1\_flat\_plains}_i
+ \varepsilon_i.
$$

Recommended robustness checks:

- Use `gamma11a_units_IV` instead of `gamma01a_units_IV`.
- Use `gamma01a_space_IV` instead of unit elasticity.
- Estimate weighted regressions using the inverse variance of the elasticity estimate if `sd_gamma01a_units_IV` is available.
- Bin `pctdis` and compare employment gradients within CBD-distance bins.
- Map residualized elasticity after controlling for `pctdis`.

### Interpretation

A negative coefficient on `log1p(employment)` is consistent with the model's municipal FOC: high-employment locations face larger congestion costs and therefore choose tighter effective residential zoning. This is a consistency test, not yet a causal estimate.

## Proposition 2: Transit Access Triggers a Zoning-Tightening Response

### Model Logic

Transit access lowers commuting costs:

$$
\tau_{ij} = \tau_{ij}(I_{ij}, n_{ij}), \qquad
\frac{\partial \tau_{ij}}{\partial I_{ij}} \leq 0.
$$

Lower commuting costs raise indirect utility:

$$
\tilde{V}_{ij}
=
\frac{B_iY_{ij}}{\tau_{ij}(q_i^R)^{1-\alpha}},
$$

which raises choice probabilities:

$$
\pi_{ij}
=
\frac{T_iE_j\tilde{V}_{ij}^{\epsilon}}{\Phi}.
$$

As more households choose transit-accessible locations, local population pressure rises. The marginal congestion cost in the municipal FOC increases, so the municipality may tighten residential zoning. In equilibrium, the observed density response to transit access is therefore suppressed.

### Testable Prediction

Conditional on employment concentration and CBD distance, tracts near DART stations should have lower housing supply elasticity. This effect should be stronger in suburban tracts, where transit access provides a larger accessibility shock.

Baseline regression:

$$
\gamma_i =
\beta_0
+ \beta_1 \mathbf{1}[\text{near station}]_i
+ \beta_2 \text{pctdis}_i
+ \beta_3 \log L_i
+ \beta_4
\mathbf{1}[\text{near station}]_i \times \text{pctdis}_i
+ \varepsilon_i.
$$

Expected signs:

$$
\hat{\beta}_1 < 0,
\qquad
\hat{\beta}_4 < 0.
$$

### Variable Construction

1. Filter DART stations:

   - Load `NA_Transit/data/processed/stations_us.geojson`.
   - Keep `region == "Dallas TX USA"`.
   - Restrict to existing stations if a `status` variable is available.

2. Create station buffers:

   - Baseline: 0.5 mile buffer around each station.
   - Robustness: 0.25 mile and 1 mile buffers.

3. Create tract-level station access:

   - Load DFW Census tract geometries.
   - Mark `near_station_i = 1` if the tract centroid falls inside any station buffer.
   - Alternative: mark `near_station_i = 1` if the tract polygon intersects a station buffer.
   - Alternative continuous measure: distance from tract centroid to nearest station.

4. Merge with the Proposition 1 tract dataset:

   - Outcome: `gamma01a_units_IV`.
   - Controls: `log1p(employment)`, `pctdis`.

### Baseline Specification

```r
lm(
  gamma01a_units_IV ~ near_station * pctdis + log1p(employment),
  data = dfw_tracts
)
```

### Preferred Additions

Add tract controls:

$$
\gamma_i =
\beta_0
+ \beta_1 \text{near}_i
+ \beta_2 \text{pctdis}_i
+ \beta_3 \log L_i
+ \beta_4 \text{near}_i \times \text{pctdis}_i
+ \beta_5 \text{Trct\_FrcDev\_01}_i
+ \beta_6 \text{lsf\_1\_flat\_plains}_i
+ \varepsilon_i.
$$

Recommended robustness checks:

- Replace `near_station` with distance to nearest station.
- Estimate separately for central and suburban tracts split by median `pctdis`.
- Use station-line access rather than station-only access.
- Compare light rail stations separately from commuter rail stations if mode information permits.
- Exclude downtown Dallas tracts to check whether the result is driven only by the CBD.
- Use tract fixed bins for `pctdis` rather than a linear control.

### Interpretation

A negative `near_station` coefficient is consistent with the core mechanism: transit access raises local attractiveness, and municipalities respond by limiting the housing supply response. A negative interaction with `pctdis` suggests the tightening response is stronger in suburban tracts.

Important caution: this is an equilibrium consistency check. A cross-sectional relationship between station proximity and low elasticity could also reflect reverse causation: transit may have been routed through corridors that were already more or less permissive. The causal version of this test should use historical rail routes, planned-but-unbuilt routes, station siting instruments, or other sources of quasi-random variation in transit access.

## Proposition 3: Restrictive Zoning Reduces the Transit Authority's Return

### Model Logic

The transportation authority chooses investment by equating marginal benefit to marginal cost:

$$
\frac{N}{\epsilon}
\Gamma\left(1-\frac{1}{\epsilon}\right)
\Phi^{1/\epsilon-1}
\frac{\partial \Phi}{\partial I_{jk}}
=
\mu \delta_{jk}.
$$

The marginal benefit of transit investment depends on:

$$
\Phi_{ij}
=
T_iE_j\tilde{V}_{ij}^{\epsilon},
$$

where:

$$
\tilde{V}_{ij}
=
\frac{B_iY_{ij}}{\tau_{ij}(q_i^R)^{1-\alpha}}.
$$

Tighter zoning lowers residential capacity, raises residential rents, and suppresses the density and ridership response around transit nodes. This lowers the return to transit investment. Across metropolitan areas, more restrictive land-use regimes should therefore have smaller transit networks relative to population.

### Testable Prediction

Across metros, WRLURI should be negatively correlated with transit network density:

$$
\log(\text{transit km per capita})_m
=
\beta_0
+ \beta_1 \text{WRLURI}_m
+ \beta_2 \log(\text{pop density})_m
+ \beta_3 \text{unavailable land fraction}_m
+ \varepsilon_m,
$$

with:

$$
\hat{\beta}_1 < 0.
$$

### Variable Construction

1. Aggregate transit route-km by metro:

   $$
   \text{TransitKM}_m = \sum_{\ell \in m} \text{route\_km}_{\ell}.
   $$

   Use `NA_Transit/data/processed/lines_us.geojson`, filter to the United States, and keep existing/open transit lines for the baseline.

2. Construct transit network density:

   $$
   \text{Transit km per capita}_m
   =
   \frac{\text{TransitKM}_m}{\text{Population}_m}.
   $$

   If population is not already merged, use Census/ACS metro population or a Baum-Snow and Han metro population variable if available.

3. Merge to Baum-Snow and Han metro data:

   - Match Transit Explorer `region` to Baum-Snow and Han `cbdname`.
   - Keep all 306 Baum-Snow and Han metros where possible.
   - Flag unmatched metros and inspect large systems manually.

4. Add controls:

   - `WRLURI_metro2`
   - `Tot_FrcUnavail50_01`
   - population density
   - optional regional fixed effects

### Baseline Specification

```r
lm(
  log(transit_km_per_capita) ~ WRLURI_metro2 + log(pop_density) + Tot_FrcUnavail50_01,
  data = metro_panel
)
```

Use:

```r
log1p(transit_km_per_capita)
```

if there are metros with zero measured transit route-km.

### Preferred Additions

Recommended robustness checks:

- Separate rail route-km from total transit route-km.
- Exclude commuter rail if the focus is intraurban fixed-guideway transit.
- Use route-km per square kilometer as an alternative outcome.
- Use metro-level housing supply elasticity instead of WRLURI.
- Control for region, historic city age, or pre-automobile development proxies.
- Run the regression with and without New York, Chicago, Boston, Philadelphia, San Francisco, and Washington, DC.
- Inspect whether results are driven by a small number of legacy transit metros.

### Interpretation

A negative WRLURI coefficient supports the model's cross-metro implication: restrictive zoning lowers the payoff to transit investment by limiting the density response around transit-accessible locations. This does not prove that zoning caused the current network size, because transit networks are historically persistent. The result is best framed as evidence that the observed cross-metro pattern is consistent with the model's transit-zoning complementarity.

## Robustness Check: Song (2025) Minimum Lot Size Data

### Motivation

SB's feedback (`comments from SB.md`, lines 15, 25, 198) calls for disciplining the
land-use constraint with zoning measures beyond housing supply elasticity where
possible. Jaehee Song's replication package
(`data/song_mls_estimator/231447-V1/`, "The Effects of Residential Zoning in U.S.
Housing Markets") provides a more direct, structurally-grounded measure: actual
codebook minimum lot size (MLS) by zoning district. This section uses it to (a)
re-check Proposition 3 with MLS as an alternative zoning measure, and (b) test
whether WRLURI and Baum-Snow & Han (B&H) elasticity actually agree with this direct
measure for the same places — a validation of the proxies themselves.

### Data Coverage Caveat

Song's *national* municipality-level MLS output (`mla_stats_state_muni_cbsa.csv`) is
CoreLogic-derived and excluded from the public replication package. The only
municipality-level MLS data available is `data/validation_set.csv` — actual codebook
minimum lot sizes (`mla_act`) by zoning district, for all MAPC (Boston-area) towns
plus **one sampled municipality per county** in ~18 other counties. This is an
illustrative, small-N robustness check, **not** a metro-representative replication:
the single sampled municipality per county may not represent that metro's overall
zoning regime, and the sample of counties itself was built for Song's own validation
exercise, not for metro coverage.

### Variable Construction

Implemented in `NA_Transit/R/07_p3_song_mls_check.R`:

1. Within each municipality, take the parcel-weighted mean of `log(mla_act)` across
   its sampled zoning districts (weight = `sample_apn`, the sampled parcel count per
   district).
2. Map each municipality's county FIPS to a CBSA via Song's
   `data/map/cbsa2fipsxw.csv`, then to the WRLURI `cbdname` / Transit Explorer
   `region` naming convention via a manually checked crosswalk (same pattern as the
   `lookup` tribble in `06_p3_identification.R`). Song's own `"mapc"` label is mapped
   directly to Boston.
3. Aggregate to metro level (parcel-weighted mean across municipalities; degenerates
   to one value per metro except Boston, which has 34 MAPC municipalities).

Result: 55 municipalities → 19 metros. One (Jacksonville) fails to match WRLURI due
to a pre-existing `cbdname` data-quality issue (`"Jacksonville,NC"` instead of
`"Jacksonville"`) that already excludes Jacksonville from the main P3 panel in
`06_p3_identification.R` — left as-is rather than patched, to avoid silently changing
the existing pipeline's matched sample.

### Specifications

**(a) P3 re-check** — restricted to the 10 metros that are *also* in the existing P3
transit panel (existing fixed-guideway transit + WRLURI match): re-estimate
`log(transit_km) ~ zoning_measure [+ log(numtracts) + FracUnavail]` with
`zoning_measure` ∈ {WRLURI, B&H `elast_inner`, Song `log(mla_metro)`}, bivariate and
with controls.

**(b) WRLURI/B&H cross-validation** — does *not* require transit data, so it uses the
full 18-metro WRLURI/B&H match: `log(mla_metro) ~ WRLURI` and
`log(mla_metro) ~ elast_inner`, plus simple correlations.

### Results

**(a) P3 re-check (N = 10):**

| Zoning measure | Bivariate coef. | Bivariate R² | With controls | Expected sign |
|---|---|---|---|---|
| WRLURI | +2.553** | 0.58 | +2.302** | negative |
| B&H `elast_inner` | −6.208 (n.s.) | 0.16 | −5.682 (n.s.) | positive |
| Song `log(mla_metro)` | −0.388 (n.s.) | 0.01 | −0.761 (n.s.) | negative |

WRLURI's puzzling *positive* coefficient (the opposite of the model's prediction)
persists even in this 10-metro subsample, both with and without controls. B&H
elasticity is also wrong-signed here, consistent with the full-panel result in
`06_p3_identification.R`. Song's direct MLS measure is the only one of the three with
the theoretically correct sign (larger minimum lot size → less transit), but the
coefficient is far from significant (SE comparable to or larger than the estimate) —
this should be read as "not inconsistent with the model," not as confirmation; N = 10
has essentially no power.

**(b) WRLURI/B&H cross-validation (N = 18):**

| Comparison | Coefficient | Correlation | p-value |
|---|---|---|---|
| `log(mla_metro)` ~ WRLURI | +0.005 | 0.01 | 0.97 |
| `log(mla_metro)` ~ `elast_inner` | −0.404 | −0.14 | 0.59 |

WRLURI shows **no** relationship at all with Song's direct codebook measure in this
sample. B&H elasticity has the theoretically expected sign (more elastic supply ↔
smaller minimum lot size) but the relationship is weak and statistically
indistinguishable from zero.

### Interpretation

This small sample does not contradict the model, but it also does not confirm it —
N = 10–18 is underpowered for any of these tests. The more useful finding is in part
(b): WRLURI in particular shows essentially zero correlation with a direct,
codebook-based measure of zoning stringency for the same places. This is suggestive
evidence that the "wrong-signed" WRLURI result in the main P3 analysis may partly
reflect a **measurement-validity problem** — WRLURI may not cleanly track the specific
land-use lever (minimum lot size / density caps) the model's mechanism operates
through — rather than a failure of the zoning-transit complementarity itself. This
strengthens the case (independent of this check) for pursuing a causal identification
strategy with a more direct zoning measure, and for treating WRLURI-based results in
the proposal with appropriate caution given this validity concern. A natural follow-up,
if a path to the restricted CoreLogic-derived national MLS data opens up, is to redo
both checks with full metro coverage instead of this single-municipality-per-county
sample.

### Outputs

- `results/song_mls_metro.csv` — metro-level aggregated MLS measure + match diagnostics.
- `results/reg_p3_song_mls.csv`, `results/reg_p3_song_mls_bh_validation.csv` — regression tables for (a) and (b).
- `results/fig_p3_song_mls_check.pdf`/`.png` — log(MLS) vs. WRLURI and vs. B&H elasticity (N = 18).
- `results/fig_p3_song_mls_transit.pdf`/`.png` — log(MLS) vs. log(transit km) (N = 10).

## Suggested Output Tables and Figures

### Table 1: Employment Concentration and Housing Supply Elasticity

Columns:

1. `gamma01a_units_IV` on `log1p(employment)`.
2. Add `pctdis`.
3. Add land/development controls.
4. Weighted by inverse elasticity variance.
5. Alternative outcome: `gamma11a_units_IV`.

### Table 2: DART Access and Housing Supply Elasticity

Columns:

1. `near_station` only.
2. Add `pctdis`.
3. Add `log1p(employment)`.
4. Add `near_station x pctdis`.
5. Add land/development controls.

### Table 3: WRLURI and Transit Route-Km Across Metros

Columns:

1. WRLURI only.
2. Add population density.
3. Add unavailable land fraction.
4. Add region fixed effects.
5. Exclude legacy transit metros.

### Figure 1: DFW Employment Concentration and DART

Map tract employment inflows, overlay DART lines and stations.

### Figure 2: DFW Housing Supply Elasticity and DART

Map `gamma01a_units_IV`, overlay DART stations. Low-elasticity tracts near stations are the visual counterpart to Proposition 2.

### Figure 3: Residualized Elasticity vs. Employment

Plot residualized `gamma01a_units_IV` against residualized `log1p(employment)` after controlling for `pctdis`.

### Figure 4: WRLURI vs. Transit Km Per Capita

Cross-metro scatter with fitted line. Label major legacy transit metros and Dallas.

## Implementation Order

1. Build the DFW tract analysis file.
2. Run Proposition 1 as the simplest validation of the congestion-zoning link.
3. Add station buffers and run Proposition 2.
4. Build the cross-metro transit route-km file and metro-name lookup.
5. Run Proposition 3.
6. Convert the results into one table per proposition and one figure per mechanism.

## Language for the Proposal

These tests should be described as empirical discipline for the model rather than final causal estimates. Proposition 1 and Proposition 2 are within-DFW equilibrium consistency checks. Proposition 3 is a cross-metro pattern that tests whether the aggregate transit network is smaller in places where land use is more restrictive. The causal identification strategy should be developed separately, using historical transit routes, planned route instruments, geographic constraints, or policy shocks to zoning authority.
