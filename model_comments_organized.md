# Model Review Memo

## 1. Executive Summary

This version of the model is substantially more coherent. The household, firm, municipal, transportation-authority, metropolitan-zoning, and planner problems now fit into a unified equilibrium system.

The strongest contribution is the comparison between decentralized municipal zoning and coordinated metropolitan zoning.

The central conceptual limitation is:

> The current model explains how fragmented municipalities distort the **residential–commercial allocation of a fixed amount of capacity**, and how this distortion changes the **allocation of a fixed transportation budget**. It does not yet explain overall zoning stringency, aggregate transportation underinvestment, or a systematic shift from transit toward roads.

This distinction should guide how the paper is framed.

---

## 2. Central Theoretical Result

The municipal first-order condition is

\[
\frac{1}{\bar U}\frac{d\bar U}{d\bar H_i^R}
=
-
\frac{
\omega_R\,dR_g/d\bar H_i^R+
\omega_F\,dJ_g/d\bar H_i^R
}{M_g}.
\]

Define

\[
A_{gi}
=
\omega_R\frac{dR_g}{d\bar H_i^R}
+
\omega_F\frac{dJ_g}{d\bar H_i^R}.
\]

Then the municipality chooses a zoning allocation satisfying

\[
\frac{d\bar U}{d\bar H_i^R}
=
-\frac{\bar U}{M_g}A_{gi},
\]

whereas the metropolitan planner requires

\[
\frac{d\bar U}{d\bar H_i^R}=0.
\]

### Interpretation

- If \(A_{gi}>0\), increasing residential capacity attracts the politically weighted resident–worker base. The municipality may accept a reduction in metropolitan welfare in order to attract that base.
- If \(A_{gi}<0\), the policy drives weighted political mass away. The municipality adopts it only when the metropolitan welfare gain is sufficiently large.
- If \(A_{gi}=0\), the local and metropolitan zoning conditions coincide on that margin.

This gives a clean definition of a **cross-jurisdictional zoning externality**.

The result

\[
\mathcal X_{gi}^{DE}
=
N\frac{d\bar U}{d\bar H_i^R}\bigg|_{DE}
\]

is especially useful. It shows that the welfare gradient ignored by the municipality is exactly the effect imposed on other jurisdictions.

### Recommended one-sentence characterization

> Municipal zoning is distorted because local governments value the metropolitan welfare consequences of zoning but also compete for residents and employment.

This is more precise than saying municipalities simply ignore general-equilibrium effects.

---

## 3. Main Economic Implications

### 3.1 Residential–Commercial Specialization

An increase in residential capacity \(\bar H_i^R\) mechanically reduces commercial capacity \(\bar H_i^F\).

Holding equilibrium flows fixed,

\[
q_i^R
=
\frac{(1-\alpha)\sum_j N\pi_{ij}w_j}{\bar H_i^R}
\]

falls when residential capacity increases.

At the same time, lower commercial capacity reduces local labor demand. Through

\[
L_i
=
\left[
\frac{\gamma\bar A_i(\bar H_i^F)^{1-\gamma}}{w_i}
\right]^{1/(1-\gamma-\zeta)},
\]

the employment response is amplified by the agglomeration externality.

A resident-oriented municipality should therefore tend toward:

- more residential capacity;
- lower residential rents, conditional on demand;
- less commercial capacity;
- fewer local jobs;
- a lower jobs-to-residents ratio;
- more outbound commuting.

A worker-oriented municipality should generate the opposite pattern.

This is currently the most direct empirical implication. It is a theory of **municipal specialization and jobs–housing imbalance**, not yet a theory of aggregate development restriction.

---

### 3.2 Agglomeration Amplifies Commercial-Zoning Effects

Because

\[
A_j=\bar A_jL_j^\zeta,
\]

a reduction in commercial capacity has more than a direct floor-space effect.

The mechanism is:

\[
\text{lower commercial capacity}
\rightarrow
\text{lower employment}
\rightarrow
\text{lower productivity}
\rightarrow
\text{further decline in employment demand}.
\]

The employment effect of commercial restrictions should therefore be larger:

- in initially dense employment centers;
- in industries or locations with stronger agglomeration forces;
- where alternative employment locations are close substitutes.

This gives a natural heterogeneous-effect prediction.

---

### 3.3 Zoning Changes the Spatial Allocation of Infrastructure

The investment rule is

\[
I_{k\ell}^{*}
=
K
\frac{W_{k\ell}^{1/(\beta+1)}}
{\sum_{e}c_eW_e^{1/(\beta+1)}},
\]

where

\[
W_{k\ell}
=
\frac{\delta_{k\ell}^1n_{k\ell}^{\rho}\Lambda_{k\ell}}
{c_{k\ell}}.
\]

The pairwise version is especially intuitive:

\[
\frac{I_e^*}{I_f^*}
=
\left(
\frac{W_e}{W_f}
\right)^{1/(\beta+1)}.
\]

Approximately,

\[
d\ln\frac{I_e}{I_f}
=
\frac{1}{\beta+1}
\left[
\rho\,d\ln\frac{n_e}{n_f}
+
d\ln\frac{\Lambda_e}{\Lambda_f}
-
d\ln\frac{c_e}{c_f}
+
d\ln\frac{\delta_e^1}{\delta_f^1}
\right].
\]

Zoning affects investment through two channels:

1. **Traffic channel:** zoning changes where residents and jobs locate, which changes \(n_e\).
2. **Market-access channel:** zoning changes the welfare value of the origin–destination pairs served by an edge, which changes \(\Lambda_e\).

The main interpretation is:

> The transportation authority is not necessarily making a mistake. It rationally directs investment toward the links that are valuable under the density and commuting pattern created by decentralized zoning.

This gives a useful theoretical result:

> Bad zoning can generate bad infrastructure even when the infrastructure agency is welfare maximizing.

---

### 3.4 The First-Order Distortion Is Zoning, Not Transportation

The first-order welfare-gap result implies that the direct contribution from changing investment is zero around the decentralized equilibrium, because the transportation authority already optimizes investment conditional on zoning.

The transportation authority should therefore not be described as underinvesting because it fails to maximize welfare.

A more accurate statement is:

> The transportation authority chooses the conditionally optimal network, but local zoning lowers or redirects the returns on which that choice is based.

This may be the cleanest theoretical contribution of the paper.

---

### 3.5 Fragmentation

From

\[
\frac{d\bar U}{d\bar H_i^R}
=
-\frac{\bar U}{M_g}A_{gi},
\]

smaller jurisdictions may exhibit larger distortions when the attraction effect \(A_{gi}\) does not decline proportionally with \(M_g\).

However, this is not yet an unconditional theorem because both \(A_{gi}\) and \(M_g\) are endogenous.

The defensible prediction is:

> Fragmentation should matter most when zoning changes generate substantial cross-boundary relocation of residents or jobs.

The model should not claim that the number of municipalities by itself necessarily causes sprawl.

---

## 4. Claims the Current Model Cannot Yet Support

### 4.1 The Model Does Not Yet Explain Overall Zoning Stringency

The model imposes

\[
\bar H_i^R+\bar H_i^F=\bar H_i.
\]

Total capacity \(\bar H_i\) is fixed. A municipality can convert commercial capacity into residential capacity, but it cannot reduce or increase total buildable floor space.

The model therefore cannot currently generate:

- downzoning of total capacity;
- minimum-lot-size restrictions;
- binding FAR or height restrictions;
- suppression of both residential and commercial development;
- an aggregate housing shortage.

The current model is a model of **land-use composition**, not total zoning restrictiveness.

### Recommended Extension

Introduce two municipal choices:

\[
z_i = \text{total permitted development intensity},
\]

and

\[
s_i = \text{residential share}.
\]

Define

\[
\bar H_i^R=s_i z_i\bar L_i,
\]

\[
\bar H_i^F=(1-s_i)z_i\bar L_i.
\]

Then:

- \(z_i\) captures overall zoning stringency or allowable FAR;
- \(s_i\) captures residential–commercial allocation;
- the current model becomes a special case in which \(z_i\) is fixed.

This is the most important structural extension.

---

### 4.2 The Model Cannot Generate Aggregate Transportation Underinvestment

The transportation budget is fixed:

\[
\sum_e c_eI_e=K.
\]

The authority spends the entire budget. Zoning can change where the money goes, but not how much infrastructure is built in aggregate.

The model therefore generates **investment misallocation**, not aggregate underinvestment.

### Recommended Extension

Replace the fixed budget with an investment-cost problem:

\[
\max_I \bar U(I,Z)-C(I),
\]

or allow the authority to choose the total budget \(K\) subject to a fiscal marginal cost.

Then restrictive zoning can lower the marginal benefit of infrastructure and reduce optimal aggregate investment.

---

### 4.3 The Model Does Not Distinguish Transit from Roads

All links use the same congestion-investment technology. Nothing currently makes transit more density dependent than roads.

The model therefore cannot yet imply:

- restrictive zoning lowers transit investment relative to roads;
- road-oriented development is self-reinforcing;
- rail has stronger scale economies;
- low density makes public transit unprofitable.

### Recommended Extension

Introduce modes \(m\in\{R,T\}\).

Road costs could depend primarily on:

- traffic congestion;
- roadway capacity;
- travel distance.

Transit costs should include:

- service frequency;
- waiting time;
- station access;
- crowding;
- fixed operating costs;
- station or line fixed costs.

Transit returns should depend more strongly on concentrated station-area demand.

Until this extension is added, use the term **transportation investment**, not **transit investment**.

---

### 4.4 The Model Is a Closed-City Model

Total metropolitan population \(N\) is fixed.

Transportation and zoning only relocate households and jobs within the metropolitan area.

The model therefore cannot currently explain:

- metropolitan population growth;
- migration toward cities receiving new transit;
- differential growth across metropolitan areas.

The closed-city assumption is acceptable for the initial model, but the empirical design should focus first on within-metropolitan outcomes.

An open-city extension would be necessary for metropolitan population growth.

---

### 4.5 The Municipal Objective Does Not Generate the Standard Homeowner Restriction Motive

Landlords are absentee, rental income does not enter municipal welfare, and the municipality values political mass times metropolitan utility.

Municipalities therefore compete to attract residents and workers. They do not restrict construction in order to raise incumbent property values.

This is internally consistent, but it differs from the conventional political economy of restrictive zoning.

### Possible Extension

Add incumbent property values:

\[
W_g
=
M_g\bar U
+
\chi_gV_g^{\text{incumbent property}},
\]

or add a local fiscal-revenue term.

Without such an extension, the paper should avoid attributing decentralized zoning outcomes to homeowner scarcity motives.

---

## 5. Technical Issues to Correct

### 5.1 Distinguish Land from Floor-Space Capacity(resolved)

The model initially refers to \(\bar H_i\) as land, but later defines \(\bar H_i^R\) and \(\bar H_i^F\) as floor-space capacity.

These are different objects.

Use **floor-space capacity** consistently, or explicitly introduce:

- physical land;
- structural capital;
- developer production;
- endogenous structural density.

---

### 5.2 The Relative Rent Is Not Automatically a Zoning Wedge(resolved)

The condition

\[
t_i=\frac{q_i^F}{q_i^R}
\]

is an equilibrium relative rent when quantities are fixed and both uses are fully utilized.

It is not automatically a regulatory wedge, because there is no marginal developer choosing between residential and commercial uses.

Either:

- call it the **implied relative scarcity price**, or
- introduce a regulatory conversion wedge and derive the associated arbitrage condition explicitly.

---

### 5.3 Route-Choice Formulations Conflict(resolved)

At the household level, routes come from a finite exogenous set \(R_{ij}\), such as the \(k\)-shortest paths.

Later,

\[
\tau=((I-A)^{-1})^{-1/\theta}
\]

aggregates all network walks generated by the adjacency matrix.

These are different route-choice models.

Choose one:

1. finite enumerated paths; or
2. recursive network paths based on the matrix inverse.

The statement that the authority takes route assignment as given also conflicts with the later endogenous route-choice constraints.

---

### 5.4 Use Densities Rather Than Masses in Local Congestion(dont change)
The model specifies

\[
\phi_i=\eta N_i^aL_i^b
\]

as a density externality, but \(N_i\) and \(L_i\) are population and employment masses.

This makes congestion depend on how finely locations are discretized.

A better specification is

\[
\phi_i
=
\eta
\left(\frac{N_i}{\text{area}_i}\right)^a
\left(\frac{L_i}{\text{area}_i}\right)^b.
\]

The functional form should also remain finite when either local population or employment is zero.

---

### 5.5 Remove the Reference to an Unimposed Restriction(dont change)

The firm section says the agglomeration restriction plays the same role as an “\(a>1\) convexity condition already imposed on \(\phi\).”

But the model assumes only \(a,b>0\).

This statement should be corrected or the intended restriction should be imposed explicitly.

---

### 5.6 Use the Agglomeration-Adjusted Labor Demand Consistently(resolved)

The transportation authority’s constraint uses

\[
L_j(w_j)
=
\left(\frac{\gamma A_j}{w_j}\right)^{1/(1-\gamma)}
\bar H_j^F,
\]

while the preceding section assumes

\[
A_j=\bar A_jL_j^\zeta.
\]

The transportation problem should use the solved agglomeration-adjusted labor-demand expression consistently.

---

### 5.7 Investment Corners Require KKT Conditions(dont change)

The budget-share formula assumes:

- \(\Lambda_{k\ell}\geq 0\);
- the investment budget binds;
- all relevant edges receive positive investment.

These conditions are not fully established.

In particular, when

\[
I_{k\ell}\rightarrow0,
\]

equilibrium traffic may also approach zero.

The complementary-slackness formulation should remain unless interiority and positivity are proven.

---

### 5.8 Move Most of the Multiplier Derivation to the Appendix(resolved)

The repeated discussion of following Bordeu “exactly” is longer than the main economic result.

The main text should retain only:

1. the transportation authority’s problem;
2. the edge-level first-order condition;
3. the budget-share rule;
4. the traffic and market-access interpretation.

The six-family multiplier system should be moved to an appendix.

The current presentation risks obscuring the distinctive zoning–infrastructure mechanism.

---

## 6. Empirical Facts to Test

### 6.1 Zoning Should Change the Quantity–Price Response to Transportation Access

Estimate

\[
\Delta Y_{ist}
=
\beta_1\Delta Access_{it}
+
\beta_2
\left(
\Delta Access_{it}\times Restrictiveness_i
\right)
+
\text{location fixed effects}
+
\text{time fixed effects}
+
\varepsilon_{ist}.
\]

Possible transportation shocks include:

- station openings;
- travel-time reductions;
- line extensions;
- network accessibility improvements.

#### Predictions

For:

- housing units;
- permitted floor area;
- population density;
- employment density;
- transit ridership,

the prediction is

\[
\beta_2<0.
\]

For residential rents or prices, the prediction is

\[
\beta_2>0,
\]

because constrained places absorb demand through prices rather than construction.

This should be the first empirical fact because it directly establishes the mechanism that zoning prevents accessibility improvements from becoming density and ridership.

---

### 6.2 Restrictive Close-In Zoning Should Displace Development Across Boundaries or Outward

Construct municipality-boundary pairs with similar:

- transportation access;
- geography;
- pre-period development;
- proximity to employment centers.

Compare locations on opposite sides of the boundary after a local demand or transportation shock.

#### Predictions

- less construction on the restrictive side;
- more construction immediately across the boundary;
- greater outward displacement when the restrictive municipality is close to high-access locations;
- longer residence–workplace distances.

This maps directly into the cross-jurisdictional externality in the model.

---

### 6.3 Residential–Commercial Zoning Should Predict Jobs–Housing Imbalance

For each municipality, construct:

\[
\frac{J_g}{R_g},
\]

as well as:

- outbound commuting share;
- inbound commuting share;
- mean commuting distance;
- local employment density;
- local population density.

Relate these outcomes to permitted residential versus commercial capacity.

#### Predictions

Residential-oriented zoning should be associated with:

- lower \(J_g/R_g\);
- greater outbound commuting;
- more cross-boundary traffic;
- higher use of corridors connecting bedroom municipalities to employment centers.

LODES is well suited for measuring:

- \(R_g\);
- \(J_g\);
- origin–destination flows;
- outbound commuting;
- inbound commuting.

---

### 6.4 Infrastructure Allocation Should Follow Traffic and Market Access

The investment equation implies

\[
\ln\frac{I_e}{I_f}
=
\frac{1}{\beta+1}
\left[
\rho\ln\frac{n_e}{n_f}
+
\ln\frac{\Lambda_e}{\Lambda_f}
-
\ln\frac{c_e}{c_f}
+
\ln\frac{\delta_e^1}{\delta_f^1}
\right].
\]

A reduced-form test can examine whether subsequent investment or service expansion is larger on corridors with:

- larger baseline commuting flows;
- more valuable origin–destination pairs;
- greater permitted capacity around served locations;
- stronger post-accessibility population and employment responses.

A useful specification is

\[
Investment_{e,t+h}
=
\beta_1InitialDemand_e
+
\beta_2PermittedCapacity_e
+
\beta_3
\left(
InitialDemand_e\times PermittedCapacity_e
\right)
+\cdots.
\]

The key prediction is

\[
\beta_3>0.
\]

High demand should translate into later infrastructure more strongly when zoning allows density to respond.

---

### 6.5 Fragmentation Should Matter Through Zoning Spillovers

Estimate

\[
TransitResponse
=
\beta_1Zoning
+
\beta_2Fragmentation
+
\beta_3
\left(
Zoning\times Fragmentation
\right)
+\cdots.
\]

The key coefficient is \(\beta_3\), not necessarily \(\beta_2\).

Fragmentation alone need not generate sprawl or weak transit. It becomes important when jurisdictions can displace development and commuting costs onto neighboring municipalities.

---

### 6.6 Dynamic Low-Density Infrastructure Trap

A compelling empirical mechanism is

\[
\text{restrictive zoning}
\rightarrow
\text{weak construction response}
\rightarrow
\text{weak ridership growth}
\rightarrow
\text{lower subsequent transit expansion}.
\]

An event study around transit openings or zoning reforms can estimate each stage separately:

1. change in accessibility;
2. permits and completions;
3. population and employment;
4. ridership;
5. later service frequency or capital investment.

This is more informative than a simple cross-sectional regression of transit infrastructure on zoning stringency because it documents the mechanism represented by \(n_{k\ell}\) and \(\Lambda_{k\ell}\).

---

## 7. Recommended Framing of the Contribution

### Contribution Supported by the Current Model

> Fragmented municipal zoning distorts the spatial allocation of residential and commercial capacity. These distortions alter commuting flows and the market-access value of transportation links, causing a welfare-oriented metropolitan transportation authority to choose a network that is optimal conditional on zoning but inefficient relative to coordinated zoning and infrastructure policy.

### Stronger Contribution After Model Extensions

After adding:

- total development intensity;
- mode-specific transportation technologies;
- an endogenous infrastructure budget,

the paper could make the stronger claim:

> Restrictive local zoning suppresses density and ridership around high-access locations, lowers the social return to public transit, and rationally shifts metropolitan investment away from transit-intensive development.

---

## 8. Revision Priorities

### Highest Priority

Separate:

1. **total zoning intensity**, and
2. **residential–commercial allocation**.

Introduce \(z_i\) and \(s_i\):

\[
\bar H_i^R=s_i z_i\bar L_i,
\]

\[
\bar H_i^F=(1-s_i)z_i\bar L_i.
\]

This modification aligns the mathematical zoning choice with the empirical question.

### Second Priority

Clarify the transportation mechanism:

- fixed budget implies allocation, not underinvestment;
- current technology applies to generic transportation, not specifically transit;
- the authority is conditionally optimal, not behaviorally distorted.

### Third Priority

Simplify the exposition:

- move multiplier derivations to the appendix;
- retain the economic first-order conditions in the main text;
- emphasize the zoning externality and conditional infrastructure response.

### Fourth Priority

Align the empirical section with what the current model predicts:

- jobs–housing imbalance;
- cross-boundary displacement;
- heterogeneous density and ridership responses;
- infrastructure reallocation.

---

## 9. Bottom Line

The current version has a coherent and potentially useful core:

> Local zoning creates cross-jurisdictional distortions in the allocation of residents and jobs, and these distortions change the network selected by a welfare-oriented transportation authority.

The current model is strongest as a theory of:

- municipal specialization;
- jobs–housing imbalance;
- cross-boundary zoning externalities;
- endogenous infrastructure misallocation.

It is not yet a theory of:

- aggregate zoning stringency;
- total transportation underinvestment;
- transit versus road investment;
- metropolitan population growth.

The next revision should focus on separating total development intensity from land-use composition rather than further expanding the transportation Lagrangian.
