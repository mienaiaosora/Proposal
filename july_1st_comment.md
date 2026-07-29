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

# July 23rd comment (self, next steps on equilibrium/optimal policy)

## 1. Municipality's problem: local vs. metropolitan-level zoning
Solve the municipality's zoning problem under both scales: (a) zoning chosen locally, separately by each municipality $g$ (current model, `zoning-foc`/`zoning-foc-explicit`), and (b) zoning chosen by a single agent at the metropolitan level internalizing all municipalities at once. Show where the two solutions differ and where that difference comes from — e.g., cross-jurisdiction spillover terms a metro-level chooser sees but an individual municipality does not. If the two problems turn out to coincide (no difference), that is itself informative: it would point to a missing externality or a flaw in the current municipal-FOC setup, and should be flagged as such rather than papered over.

Relates to Open Model Question #6 (scale of decision) in `CLAUDE.md`, and to the "Counterfactual framing" note logged under the July 17th comment below (scale-of-decision + identity-of-agent both changing at once).

## 2. Solve the social planner's problem and conduct the welfare change
Solve the social planner's problem — the planner already introduced in `model.tex`'s `\subsection{Social Planner}` (2026-07-21), choosing zoning $t_i^F$ and investment $I_{k\ell}$ jointly for the whole metro — through to a full characterization, then compute the welfare change relative to the decentralized (simultaneous-Nash municipality/transportation-authority) equilibrium. This is the quantitative counterpart to the qualitative result already derived (`zoning-foc-planner` weakly dominates the municipal FOC via the two named terms, cross-jurisdiction spillover and transit-zoning complementarity) — i.e., put a number (or a comparative-statics sign/magnitude) on the welfare cost of the coordination failure this proposal is about.

Relates to the "Counterfactual framing" note and Open Model Question resolutions #6/#17 in `CLAUDE.md`.

## Response / plan (2026-07-23) — implemented

**Task 1 (local vs.\ metropolitan zoning):** added `\subsection{Scale of the Zoning Decision}` to `model.tex`, right before `\subsection{Social Planner}`. Defined a Metropolitan Zoning Authority — one agent choosing $t_i^F$ for every $i\in S$, still in Nash with the (unchanged) transportation authority, isolating the *scale* axis from the *agent-identity* axis. Result: local and metropolitan zoning differ by exactly one term — the cross-jurisdiction spillover (`zoning-foc-metro`, term (6)) — and nothing else, since the TA's own FOC doesn't reference which agent set zoning. No flaw in the model per se, but working through this exposed a real bug in the *existing* Social Planner derivation (2026-07-21): the zoning FOC there (`zoning-foc-planner`) had claimed a *second* term, "transit-zoning complementarity" (term (7)), on top of term (6). Checked this two independent ways (direct Lagrangian differentiation with $I_{k\ell}$ and $\bar H_i^R$ as simultaneously-chosen variables; and an envelope-theorem argument on the reduced form $\tilde W(t)=W(t,I^{SP}(t))$ using the fixed-budget constraint) — both show term (7) is identically zero and should not have been there. Corrected in `model.tex`; `zoning-foc-planner` now matches `zoning-foc-metro` exactly. Corollary: agent identity turns out to be welfare-irrelevant for the zoning margin — only the scale of the zoning objective matters. Flagged as a correction, not silently fixed, since it revises content already logged as resolved; see `CLAUDE.md`'s Open Model Question #6 and the Counterfactual framing note for the full writeup.

**Task 2 (Social Planner + welfare change):** added `\subsection{Welfare Comparison}` to `model.tex`, right after §Social Planner. Two propositions: (1) planner dominance, $W^{SP}\geq W^{DE}$, a pure revealed-preference argument (DE is feasible for the planner's problem, planner is optimal over the same feasible set) — no derivatives, no sign assumptions needed; (2) first-order source of the gap — Taylor-expanding $\Delta W$ around the DE, the investment margin and each municipality's own zoning margin both vanish to first order (the same envelope/binding-budget logic as the term-(7) correction, plus the municipal FOC being satisfied at DE), leaving $\Delta W\approx\sum_i[\text{term (6)}]_i\cdot(\bar H_i^{R,SP}-\bar H_i^{R,DE})$ — the welfare cost of fragmentation is, to leading order, entirely the cross-jurisdiction spillover. This is an analytical characterization only; a numeric welfare-gap magnitude requires the calibrated model (§Quantification) and is still future work.

## Follow-up (2026-07-23) — closed-form solution for $t_i^F$

Asked whether a closed form for $t_i^F$ is available at the metropolitan-zoning scale, the way `CLAUDE.md`'s Open Question #11 claimed one already existed for the municipal case. Checking `model.tex` (current file and every past commit via `git log -p -S "phi-star-leading"`) found that the municipal closed form was never actually written — the 2026-07-16 log entry described work that didn't make it into the file, even in the commit that logged it as done. Per your direction: rebuilt the municipal closed form for real first, then extended to the metro case.

**Municipal closed form (rebuilt):** small-open-location approximation (treat the metro-wide index $\Phi$ as fixed when a single municipality rezones) licenses a 4-equation log-linear ("hat algebra") system — residence gravity, rent clearing, labor demand, workplace gravity — solved explicitly for the elasticities of $N_i,L_i,w_i,q_i^R$ in the zoning shifter $\hat h_i^R$. Substituting into the zoning FOC collapses it to one scalar equation in $\theta_i\equiv\bar H_i^R/\bar H_i^F$, with an explicit leading-order solution $\theta_i^*$ and an interior-solution condition. Lives in `model.tex`, §Municipal Zoning, right after the "Channels" paragraph.

**Metropolitan closed form:** the same small-open-location shortcut is exactly what breaks once the zoning authority is metro-wide — it *is* the aggregate $\Phi$ the shortcut held fixed, not negligible relative to it. Per your choice (full linear system over a symmetry-simplified scalar), the metro-level result is stated as a matrix system — the same building blocks stacked across every location, plus the now-endogenous $\hat\Phi$ feedback that generates the cross-jurisdiction spillover (term (6)) — with formal solution $\hat x=M^{-1}c\,\hat h^R$. This does not reduce to a hand-copiable scalar formula the way the municipal case does; it's deferred to quantification for numerical evaluation, following the same convention already used for the Transportation Authority's multiplier system. Lives in `model.tex`, §Scale of the Zoning Decision.

**Update (2026-07-23, later same day) — both closed-form pieces removed, zoning instrument simplified.** You reverted §Municipal Zoning's arbitrage condition from the iceberg-cost framing (`q_i^R=q_i^F/(1+t_i^F)`) back to the plain ratio `t_i=q_i^F/q_i^R` directly in `model.tex` — "more convenient." This is a cleaner, more tractable instrument and removed both closed-form derivations above (they were built on the iceberg-cost algebra). I synced the rest of the document to match: re-derived the (now much simpler) monotonicity result `dH̄_i^R/dt_i=H̄_i^R/t_i>0` (`zoning-foc-tax`, which had been left as a dangling, undefined reference after the removal), and propagated `t_i^F→t_i` / "iceberg cost"→"zoning wedge" through every remaining reference (§Municipal Zoning, the Equilibrium definition, §Scale of the Zoning Decision, §Social Planner). `CLAUDE.md`'s notation registry, and items 6, 7, and 11 of Open Model Questions, updated to match — item 11 (closed-form solution) is marked reverted/open again rather than resolved, since the derivation no longer exists in `model.tex`.

**Also resolved in this pass:** working through whether `W^g=Σ N_i\bar U_i` should instead be `N^g\cdot\bar U` (prompted by your "under free mobility, isn't `Ū_i` the same everywhere?" question), found that `\bar U` (built from the aggregate `\Phi`) is the expected utility of a household *freely choosing* its residence — a Fréchet/GEV compensating-shock argument makes this the *same* constant at every location, not what a municipality representing incumbents should use. `N^g\cdot\bar U` was tried and produces a corner solution (no cost to attracting residents, since `\bar U` is fixed for a small municipality) that undermines the whole zoning-restriction mechanism. Kept `\bar U_i=\Gamma(1-1/\epsilon)\Phi_i^{1/\epsilon}` (no equation changes) but added a rigorous justification in §Households ("Two notions of expected utility") and a cross-reference + rejected-alternative footnote in §Municipal Zoning: `\bar U_i` is the expected utility of an incumbent, residence held exogenously fixed — the right object for a government representing people already living there, as opposed to `\bar U`, which is right for an agent (TA, planner) representing the whole population including the free residence margin. Logged as Open Model Question #18.

**Optimization of Municipality**
To make sure the maximization target are at the same level, suggestion is that the local municipality, metropolitian level municipality, and TA, all maximize the average indirect utiliy `\bar U`, for local it is `\bar U_{i}`.

## Response / plan (2026-07-27) — implemented

Distinguished this from item 18 (already resolved): item 18 was about *which* utility object a municipality should use (`\bar U_i`, local/incumbent, vs.\ `\bar U`, aggregate/free-mobility) — unaffected by this note. This note is about whether that object should be *population-weighted* in the objective. Before this change: municipal `W^g=\sum_{i\in S^g}N_i\bar U_i` (weighted by local population `N_i`), while TA/metropolitan-authority/planner used `N\cdot\Gamma(1-1/\epsilon)\Phi^{1/\epsilon}=N\cdot\bar U` (population `N` times the aggregate average) — not actually "at the same level" in the sense you flagged.

For the TA/metropolitan authority/planner, dropping the `N\cdot` prefix is FOC-neutral: total population `N` is a fixed constant here, not a choice variable, so it doesn't change the argmax, only how the objective is written. Rewrote their stated objectives as `\Gamma(1-1/\epsilon)\Phi^{1/\epsilon}=\bar U` in `model.tex` (`eq:TA-problem`, `eq:TA-lagrangian`, the Metropolitan Zoning Authority's objective in §Scale of the Zoning Decision, and `eq:SP-problem`) — downstream `\Lambda`-based first-order conditions (`eq:I-optimal`, `zoning-foc-planner`) needed no changes, since they're defined self-referentially in terms of their own (consistently rescaled) Lagrangian's multipliers, not tied to any particular normalization of the objective.

For the municipality this is a genuine, not merely cosmetic, change: `N_i` is the municipality's *own* zoning choice's population response, not a fixed weight, so removing it changes the first-order condition. Changed `W^g` to `\sum_{i\in S^g}\bar U_i` and rederived the affected Lagrangian pieces by hand, checking the method against the document's own pre-existing results (reproduced `\chi_i=(N_i\bar U_i+\epsilon\Lambda_i^\phi)/\phi_i` independently before applying the same method to the revised objective, confirming it). Effects: the `\sigma_i` multiplier's FOC loses its `-\bar U_i` term, becoming identical in form to the planner's own (`\sigma_i=\chi_i a\phi_i/N_i`); `\chi_i,\eta_i^q`, and the `\eta_i^w`-closing term lose their `N_i` factor; and `zoning-foc-explicit` loses channel (1) — the "in-mover" term — entirely, collapsing from five channels to four (rent, residential congestion, worker-congestion relief, local-wage loss). The municipality no longer directly values attracting residents; in-migration now matters only through the price/congestion channels it triggers — exactly the same structural reason the planner's `zoning-foc-planner` already lacked a channel-(1) analogue (§Social Planner). This closes most, but not all, of the structural gap between the municipal and planner zoning conditions flagged in §Welfare Comparison's `Remark`: both are now four-channel, no-in-mover conditions, differing only in `\bar U_i` (local) vs.\ `\bar U` (aggregate) and in whether `\Lambda_i^\phi,\Lambda_i^q,\Lambda_i^w` are collapsible (municipal, small-open-location) or genuinely live (planner, spans all of `S`) — the Remark's wording was updated accordingly, and it no longer cites "missing channel (1)" as a distinguishing feature. Whether the sharper parallel licenses a cleaner leading-order welfare-gap decomposition than Proposition~2's current form is flagged as an open follow-up, not attempted in this pass. Logged as Open Model Question #20 in `CLAUDE.md`.