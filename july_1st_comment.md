# July_1st comment
## 1. municipality's choice
instead of controling directly the land supply, think about price/ quota, stuff like that for municipality to make zoning, also this highly depends on what kind of data I could have access to

## 2. Land supply
for now my land supply is fixed, there is no land supplier who has a maxmization problem in the model, but in reality this may not be the case
Suggestion: start with fixed total land supply, then extend to the margin of endogeneous land supply
check: DFW's unused land data,

## 3.empirical part
for the first one: syntheti control, show across cities
for the second one: one potential method after getting historical zoning data:transit decision is explained better by contemporary zoning but wek by later zoning. Again, be more clear about the measurement of zoning, what kind of data I can get.

## Response / plan (2026-07-05)

### 1. Municipality's choice: price/quota vs. quantity

The model currently has municipalities directly set floor-space caps $\bar H_i^R,\bar H_i^F$ — a quantity instrument. Real-world zoning is implemented through several different instruments, and it's worth separating *which one to model* from *which one I can measure*:

- **Quantity caps** (FAR limits, height limits, minimum lot size, unit caps) — this is what the current $\bar H_i^R$ formalization represents directly.
- **Price instruments** (impact fees, exactions, permit fees) — these act as a wedge between the developer's cost and the market rent, shrinking the profitable quantity of housing built.
- **Quota/permit-allocation systems** (growth-management caps like Boulder's or Petaluma's annual permit allocation, or DART-style withdrawal votes that gate infrastructure access) — these ration the *rate* of new supply rather than the stock.

Under certainty and a competitive land/housing market, a binding quantity cap and an equivalent price wedge are formally equivalent: the shadow price on the quantity constraint in the municipal FOC (eq. zoning-foc) *is* the implicit tax a price instrument would need to replicate the same allocation. So the baseline model probably doesn't need a structural change — the quantity formalization can be described as a reduced form nesting all three instruments, with $\bar H_i^R$ interpreted as "effective permitted floor space regardless of the legal instrument used to constrain it."

What *does* depend on data is which instrument I can credibly measure and calibrate to:
- Baum-Snow & Han's tract-level elasticity is itself instrument-agnostic (it's an estimated quantity response), so it's compatible with the current setup without picking a specific instrument.
- If I want to speak to a specific instrument (e.g., permit quotas), the Census **Building Permits Survey (BPS)** gives a place/county-level panel of permits issued since the 1980s — a real quantity outcome I could use as a robustness check or alternative proxy to B&H elasticity.
- I don't currently have good data on fee/exaction schedules by tract, so a genuine price-instrument version of the model is not well supported empirically right now.

**Correction (2026-07-05):** SB's actual position is stronger than "keep quantity, add a remark" — the ask is to *change* the municipal instrument from quantity to price/quota.

**Implemented (2026-07-05), revised same day:** first pass added a competitive-developer sector, but the user asked to keep land supply fully fixed with no developer/endogenous supply — the tax/quota framing should sit on top of the *existing* direct quantity choice, not require a new agent. Final version in `model.tex` and `empirical facts.tex`: $\bar H_i^R$ is unchanged (still the municipality's direct choice, same FOC eq. zoning-foc, total land $\bar H_i$ still fixed), with a short remark noting it can be read either as a **quota** (a permit/floor-space cap, which is literally what $\bar H_i^R$ already is) or as an equivalent **tax** $t_i^R \equiv q_i^R - c_i(\bar H_i^R)$, using an assumed exogenous marginal-cost-of-construction schedule $c_i(\cdot)$ with $c_i'>0$ (a technology/geography primitive, not an optimizing supplier). Since $c_i'>0$, this is a one-to-one relabeling — no new margin, no market-clearing supply response, no separate agent. $t_i^R$ matches the Glaeser-Gyourko empirical convention (price minus marginal construction cost) without requiring a developer's profit-maximization problem. `main.tex`'s model subsection was intentionally left un-synced (see `CLAUDE.md` Open Model Questions #7).

### 2. Land supply: fixed vs. endogenous

Agreed with the suggested sequencing — keep $\bar H_i$ (total land) fixed for the baseline model, and flag endogenous land supply (a competitive land/developer sector converting undeveloped into urban land, à la Capozza-Helsley) as a future extension. This matters most for the **extensive margin** story (road investment opening up peripheral land), which connects to the road/transit asymmetry SB flagged as open item #1 in `comments from SB.md` — if $\bar H_i$ is fixed everywhere including the fringe, the model can't fully capture "roads make more land developable."

Next step: look for DFW unused/vacant land data to (a) check how much of the extensive margin is actually still open in DFW (relevant for whether the fixed-land assumption is a reasonable approximation) and (b) potentially construct a proxy for the *convertible* land margin later. Candidate sources: NCTCOG regional land-use/parcel datasets, Texas Land Trends (Texas A&M Natural Resources Institute), county appraisal district (DCAD/TAD) parcel land-use codes, or NLCD land cover for undeveloped/agricultural classification near the urban fringe.

### 3. Empirical part

**First hypothesis (older pre-car-transit cities sustain larger/higher-return transit networks):** use a synthetic control design across cities. Treatment = early (pre-automobile) transit system presence; construct a synthetic control from cities without early transit but similar pre-period characteristics (population, density, geography); compare current transit network size/ridership/investment as the outcome. Data: NTD panel + historical transit-opening dates (already used for Prop. 1/2), APTA historical statistics, and possibly historical population density from NHGIS/ICPSR to build the pre-period matching variables.

**Second hypothesis (zoning explains transit investment causally, not vice versa):** this maps onto Problem 1/2 already flagged at the end of `empirical facts.tex`. The proposed test — transit investment explained better by *contemporaneous* zoning than by *later* zoning — is essentially a lead/lag horse race: regress transit investment (or the decision to invest) on zoning measured at $t$ and separately on zoning measured at $t+k$, controlling for the same covariates, and check which specification has more explanatory power / survives the other's inclusion. A large coefficient on future zoning after controlling for contemporaneous zoning would suggest reverse causality (transit investment triggers later upzoning) rather than the model's channel (zoning shapes transit's return).

This test needs real panel/historical zoning variation, which is the current bottleneck:
- **NHGIS** historical tract data can proxy pre-period population/density trends but is not zoning itself — useful as a control, not as the zoning measure.
- **Wharton Residential Land Use Regulatory Index (WRLURI)** has multiple survey waves (1975 Section of Local Government Law survey, 2006 Gyourko-Saiz-Summers, 2018 update) at the metro/place level — this is the most realistic source of an actual *panel* in zoning restrictiveness, even if coarser than tract level. Not yet in `reference.bib` — worth pulling in if this route is pursued.
- **Rollet & Weiwu (2025) / ZoneComics** — already flagged as Problem 2 in `empirical facts.tex`; still worth checking for DFW coverage and cost, since it's the most granular option if accessible.

**Recommendation for next steps, in priority order:**
1. Check WRLURI wave coverage for DFW-area jurisdictions — if there's a usable time gap between waves, that directly supports the contemporaneous-vs-later test at the metro/place level while still looking for tract-level historical data.
2. Follow up on ZoneComics/Rollet & Weiwu access and DFW coverage (Problem 2 in `empirical facts.tex`).
3. Pull Census BPS as a secondary quantity-of-supply panel, both for the price/quota question above and as a possible zoning-tightness proxy over time.
4. Scope the synthetic-control city sample (candidate early-transit cities: Boston, Chicago, Philadelphia, NYC, San Francisco) against candidate car-oriented comparisons, once the above data checks are done.

# July_6th comment

## Transportation agent's problem uncleared
What is I_{jk}, in Fajgelbaum and Schaal, they use lanes operated between each node as investment, does that applies to transit? and what is the network like in my setting? 


Read Fajgelbaum, Pablo, Cecile Gaubert, Nicole Gorton, Eduardo Morales, and Edouard Schaal. 2023. “Political Preferences and Transport Infrastructure: Evidence from California’s High-Speed Rail.” Cambridge, MA: National Bureau of Economic Research. https://doi.org/10.3386/w31438. to get intuition about the decision on transit investment.
and Bordeu, Olivia. 2026. “Commuting Infrastructure in Fragmented Cities.” https://www.oliviabordeu.com/papers/fragmented_cities_obordeu.pdf.to think about the spillover effect of such investment
carefully.

## Think about the investment spillover effect, in the commuting cost, the commuting between j and k is only affected by I_{jk} wheras in reality the investment can have spillover effects along or beyond the path.

## The municipality's decision is not really a tax, this can be interprete as an iceberg cost for commercial landuse.

# July_17th comment

**Disutility \phi(N,L)**
Putting them into B_{i}, will make it more coherent to interprete and potentially easier to calibrate, 

**Landlord Problem**
where does the land rent go? Several ways to go, 1) ommit this issue, assume a landlord who collects all these benefit and consume elsewhere, not in this city anyway, which leads to no difference in my setting 2)distributed equally to the local residents.

This can be more explored when including the extensino of land supplier

**Why zoning decisions will favor the transportation infrastructure**
1) better job access for residents
2) productivity agglomeration
   
**Counterfactual issue**
2 things change: 1) scale of decision change 2) the agent who make the decision change(from two different agents to one)

**In terms of the discussion of Bordeu(2025)**
She made the local government's problem as maximizing local land value, but sometimes it is equivalent to maximize \bar{U}, be aware of this and think about it.

**Extension: Endogenize K**
The total budget constraint for infrastructure can be endogeneous.

**Next step**
First characterize the equilibrium, solve the potimal policy problem.

Second, data issue. a lot of data needed, after getting the equilibrium think about what parameter I need to calibrate, validate and what parameter I can borrow from existing paper.

