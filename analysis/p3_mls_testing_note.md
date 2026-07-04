# Proposition 3 Test Using MLS/MLA Evidence

This note adapts Proposition 3 to the Song minimum-lot-area (MLA) data in `data/song_mls_estimator/231447-V1`. The goal is to move beyond the cross-metro WRLURI regression in `preliminary_results.tex`, which has the wrong sign, and test the mechanism more directly.

## Starting Point

The current Proposition 3 slide tests:

$$
\log(\text{TransitKm}_m)
=
\alpha
+ \beta_1 \text{WRLURI}_m
+ \beta_2 \log(\text{tracts}_m)
+ \beta_3 \text{FracUnavail}_m
+ \varepsilon_m.
$$

The model predicts $\beta_1<0$, but the preliminary results show $\beta_1>0$ and significant. The slides correctly interpret this as cross-metro demand/history confounding: economically dynamic metros both invest more in transit and face stronger zoning pressure.

## Why MLS/MLA Helps

Song's data estimate local minimum lot area. Higher `MLA` means lower allowed residential density and therefore tighter land use. This is closer to the model object than metro WRLURI:

$$
\bar H_i^R \downarrow
\quad \Longleftrightarrow \quad
\text{MLA}_i \uparrow.
$$

The included Song outputs already document the first step of Proposition 3:

- Higher MLA raises sale prices and rental prices.
- Higher MLA raises lot sizes.
- Higher MLA is associated with larger single-family parcels and lower feasible density.

That means the MLS/MLA data can support the channel:

$$
\text{MLA}_i \uparrow
\Rightarrow
\text{housing density near transit} \downarrow
\Rightarrow
\text{ridership base} \downarrow
\Rightarrow
\text{marginal return to transit} \downarrow.
$$

## Preferred Within-Metro Test

Use CBG-level MLA and DART station access:

$$
\log(\text{density}_{b})
=
\alpha
+ \beta_1 \log(\text{MLA}_{b})
+ \beta_2 \mathbf 1[\text{near DART}]_b
+ \beta_3 \log(\text{MLA}_{b}) \times \mathbf 1[\text{near DART}]_b
+ X_b'\gamma
+ \varepsilon_b.
$$

Expected signs:

$$
\beta_1 < 0,\qquad \beta_3 < 0.
$$

Interpretation:

- $\beta_1<0$: stricter minimum lot sizes reduce neighborhood density.
- $\beta_3<0$: the density-suppressing effect is especially relevant around transit, exactly where density should raise ridership and transit ROI.

Recommended outcomes:

- `log(pop_dens)`: population per land area.
- `log(unit_dens)`: housing units per land area.
- `log(n_units)`: housing units, controlling for land area.
- Optional: station-buffer tract or CBG population as a proxy for local ridership base.

Recommended controls:

- Distance to CBD, ideally `dist_to_cbg`.
- Income, race shares, education.
- County or CBSA fixed effects if expanding beyond Dallas.
- Station line or corridor fixed effects if using a multi-metro station-area sample.

## Dallas Implementation

For Dallas, define:

- `near_dart = 1` if the CBG centroid is within 0.5 miles of an existing DART station.
- `near_dart_025` and `near_dart_1mi` for robustness.
- `log_mla = log(mla_est)`.

Baseline:

```r
lm(
  log(pop_dens) ~ log_mla * near_dart + dist_to_cbg +
    log(med_hh_inc) + p_white + p_black + p_asian,
  data = dallas_cbg
)
```

Robustness:

```r
lm(log(unit_dens) ~ log_mla * near_dart + controls, data = dallas_cbg)
lm(log(pop_dens)  ~ log_mla * near_dart_025 + controls, data = dallas_cbg)
lm(log(pop_dens)  ~ log_mla * near_dart_1mi  + controls, data = dallas_cbg)
```

## How to Use the Result in the Proposal

Do not claim this identifies the causal effect of zoning on transit investment. Frame it as a mechanism test that addresses the failure of cross-metro P3:

> The cross-metro WRLURI specification does not recover the model-predicted sign, likely because metro-level land-use regulation is endogenous to demand and historical transit investment. I therefore test the mechanism directly using local minimum-lot-area estimates from Song's MLS-based zoning estimator. If restrictive minimum lot sizes suppress density specifically around transit stations, then zoning mechanically lowers the station-area ridership base that enters the transportation authority's marginal-benefit condition.

If the estimates show $\beta_1<0$ and $\beta_3<0$, report this as support for the density/ridership channel, not as a final estimate of the effect of zoning on investment.

If $\beta_3$ is insignificant, the result is still useful: it says the current data support the general density-suppression channel, but do not yet prove that the suppression is stronger around transit nodes.

## Current Data Limitation

The replication package excludes the intermediate CBG-level MLA file:

`data/song_mls_estimator/231447-V1/INT/mla_est/by_geo/mla_stats_cbg_muni.csv`

Without that file, the full station-area regression cannot be run locally. The included output tables can still be used to summarize the existing evidence that MLA raises prices/rents and lot sizes.
