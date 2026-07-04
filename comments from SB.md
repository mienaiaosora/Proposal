Ke proposal questions and suggestions

## 1. Quantification: how to do it?

### SB's question

How will the model be quantified?

### Response / plan

The quantification should be organized around a small set of equilibrium objects rather than trying to estimate every primitive directly. A reasonable plan is:

1. Use observed commuting flows, mode shares, wages, rents, and employment by location to discipline household location and commuting choices.
2. Use observed road and transit infrastructure, together with travel times and congestion, to discipline the commuting-cost functions.
3. Use housing supply elasticity or zoning restrictiveness measures to discipline the land-use constraint \(Z_i\).
4. Choose transportation cost and investment cost parameters so the model matches observed differences in transit investment, road investment, ridership, and city form across metropolitan areas.
5. Use the calibrated model for counterfactuals: coordinated zoning and transportation, relaxed zoning near transit, transit-only investment, road-only investment, and a planner benchmark.

The empirical implementation could start with a cross-city or metro-level version before moving to a full spatial model. At the metro level, I can test whether older cities with pre-car transit systems have higher observed transit returns and whether zoning restrictiveness predicts lower subsequent transit investment. The full quantitative model would then explain these patterns through the mechanism: zoning reduces density near high-access locations, which lowers transit ridership and the marginal return to transit investment.

Data sources:

- Transportation: National Transit Database (NTD), Transit Explorer, GTFS where available, road network data, commuting times, and mode shares.
- Spatial equilibrium moments: LEHD/LODES commuting flows, ACS population and commuting mode shares, employment by location, rents or housing prices.
- Zoning / housing supply: housing supply elasticity from Baum-Snow and Han (2024), zoning indices if available, or local land-use regulation measures.
- Investment outcomes: transit openings, system length, capital spending, operating expenses, ridership, and road lane-mile/capacity measures.

The key quantitative moments to target are:

- population and employment gradients;
- commute flows and mode shares;
- transit ridership per mile or per station;
- housing density around transit-accessible locations;
- observed transit and road investment;
- sensitivity of development to accessibility in more versus less restrictive places.

## 2. Timing: simultaneous or sequential?

### SB's comment

It is not clear whether municipalities and the transportation authority move simultaneously (Nash equilibrium) or sequentially (municipalities choose zoning first, then the authority chooses transportation taking zoning as given). The timing should be explicitly specified, since it affects how municipalities internalize the impact of zoning on transportation decisions.

THIS IS VERY IMPORTANT because changes in transportation investment will generally affect the best response of municipalities. The key question is whether municipalities internalize this effect when choosing zoning, which depends on the timing of the game.

### Response / plan

I should make the baseline timing explicit. The cleanest baseline is a sequential timing with zoning treated as a slow-moving institutional state:

1. Municipalities choose zoning policies, motivated by incumbent-resident interests.
2. The metropolitan transportation authority observes the zoning regime and chooses road and transit investment.
3. Households and firms choose locations, commute modes, and land demand; markets clear.

This timing matches the institutional story: zoning is durable and locally controlled, while transportation agencies evaluate projects conditional on existing land-use rules. Under this interpretation, restrictive zoning lowers the marginal return to transit investment because the transportation authority correctly anticipates a weak density and ridership response.

The delicate issue is whether municipalities anticipate the transportation authority's response when choosing zoning. I think the baseline should assume they do not fully internalize this metropolitan response. The justification is that each municipality is local and politically accountable to incumbent residents, while the transportation authority operates at the regional scale. A single municipality may understand that zoning affects development locally, but it does not internalize the aggregate effect of fragmented zoning on the regional transit-investment decision.

To make this precise, I can describe municipal zoning as either:

- a reduced-form local political objective that excludes the derivative of regional transportation investment with respect to local zoning; or
- an atomistic/local-choice approximation in which each municipality treats \(I^R\) and \(I^T\) as given when choosing \(Z^g\).

Then the transportation authority chooses \(I^R\) and \(I^T\) taking the full zoning vector \(Z\) as given. This preserves the core mechanism: zoning is locally chosen, but transportation returns are regional.

A useful extension or robustness exercise would be to compare three timing assumptions:

1. **Baseline predetermined zoning:** zoning is chosen first and transportation responds.
2. **Simultaneous Nash:** municipalities and the transportation authority choose policies taking each other's choices as given.
3. **Fully coordinated planner:** one planner chooses both zoning and transportation.

The welfare gap between the baseline and the planner captures the cost of fragmented governance. The simultaneous case can show whether the result depends on timing.

## 3. Distinguishing road and transit mechanisms

### SB's comment

需要区分 road 和 transit 的机制，不然两个投资只是符号不同。否则在模型里可能只是两个 commuting-cost shifter，没有真正体现不同交通模式对 urban form 的不同含义。

Translation: I need to distinguish the mechanisms for road and transit. Otherwise the two investments are just different symbols and both simply shift commuting costs, without capturing how different transportation modes imply different urban forms.

### Response / plan

This is a very important point. The proposal should make road and transit structurally different, not just label them as \(I^R\) and \(I^T\). The sharper distinction is that road investment mainly expands the feasible urban footprint, while transit investment mainly raises the value of density in already accessible locations.

The key economic asymmetry should be:

- **Roads are extensive-margin infrastructure.** They make farther locations developable by lowering the cost of longer car commutes. Their benefits are spread over space and can be valuable even when development is low density. In fact, when zoning restricts density near the center or near transit corridors, road investment may become more attractive because growth is pushed outward.
- **Transit is intensive-margin infrastructure.** It is valuable when many residents and jobs can concentrate near stations or corridors. Transit has high fixed costs, limited spatial coverage, and ridership economies, so its return depends strongly on local density and land-use flexibility.

This gives a stronger mechanism than simply saying roads and transit both reduce commuting costs:

> Restrictive zoning does not just lower all transportation returns. It changes the relative return of transportation modes. By preventing density near high-access locations, zoning disproportionately lowers the return to transit. At the same time, the displaced population and employment must locate somewhere, often farther out, which can increase demand for road-oriented commuting. Thus zoning can tilt the transportation equilibrium away from transit and toward roads.

The model can distinguish roads and transit in at least five structural ways:

1. **Network geometry.** Road investment improves a dense, spatially diffuse network. Transit investment improves a sparse network of corridors and nodes. Therefore road benefits are less tied to any one location, while transit benefits are capitalized around stations.
2. **Development margin.** Roads mainly affect the extensive margin of urban expansion by making peripheral land accessible. Transit mainly affects the intensive margin of development by increasing the value of density near stations.
3. **Scale economies.** Transit has stronger increasing returns to local density because frequency, ridership, and access all become more valuable when many people live and work near the network. Roads have congestion diseconomies that become worse with traffic volume.
4. **Land-use complementarity.** Transit and density are complements: the marginal product of transit investment is higher when zoning allows more residential and commercial floor space near stations. Roads and low-density development are closer substitutes for compact transit-oriented development.
5. **Distributional incidence.** Road investment mainly benefits car owners and households able to live farther from employment centers. Transit investment is more valuable for households without cars and for dense employment/residential centers.

A better commuting-cost structure would be mode-specific:

\[
\tau_{ijm} =
\tau_{ijm}(I^m, n_{ijm}, a_i^m, a_j^m),
\qquad m \in \{R,T\},
\]

where \(a_i^m\) and \(a_j^m\) measure access to mode \(m\) at the residence and workplace locations. The two modes should then have different technologies:

- For roads:

\[
\tau_{ijR}
=
d_{ijR}/s_R(I^R,n_R),
\]

where road investment increases speed or capacity, but congestion lowers speed as vehicle traffic \(n_R\) rises. Road access can be positive for almost all locations connected to the road network.

- For transit:

\[
\tau_{ijT}
=
\phi_i^T(I^T) + t_{ijT}(I^T) + \phi_j^T(I^T),
\]

where \(\phi_i^T\) and \(\phi_j^T\) are access/egress costs and \(t_{ijT}\) is in-vehicle or waiting time. Transit is attractive only when both the residence and workplace have sufficiently good access to the network. Its benefit is therefore concentrated around stations and corridors.

The transportation authority's return to each mode could also be written differently:

\[
MB^R
=
\sum_{i,j} n_{ijR}\Delta \tau_{ijR}
- \text{congestion and maintenance costs},
\]

\[
MB^T
=
\sum_{i,j} n_{ijT}\Delta \tau_{ijT}
+ \text{agglomeration / accessibility gains near stations}
- \text{fixed and operating costs}.
\]

The important term is that \(n_{ijT}\) is endogenous to zoning because station-area population and employment are constrained by \(Z\). If zoning prevents density near transit, then even a technically good transit line has low ridership and low welfare return.

In contrast, restrictive zoning may increase the relative return to roads through displacement:

1. Zoning restricts density in central or high-access locations.
2. Households and firms are pushed to lower-cost peripheral locations.
3. Peripheral locations are more car-dependent and harder to serve by fixed-route transit.
4. The transportation authority observes this spatial pattern and finds road investment relatively more attractive.
5. The resulting road investment further supports decentralized urban form.

The proposal should also state the key asymmetry in words:

Restrictive zoning is especially damaging for transit because it blocks the density response that transit needs in order to generate ridership and accessibility benefits. Road investment is less dependent on concentrated density and may become relatively more attractive precisely because restrictive zoning pushes development outward. This is the channel through which local land-use restrictions can create a road-oriented equilibrium even if transit would be more efficient under coordinated zoning.

## 4. Municipal objective and interpretation of \(\omega\)

### SB's comment

The municipal objective needs more structure or justification. It currently includes property values, local amenities, and congestion costs, but it is unclear whether these weights represent homeowner voting power, incumbent-resident welfare, or reduced-form political economy. The proposal could clarify how the \(\omega\) parameters are interpreted and how they would be disciplined quantitatively.

### Response / plan

I should clarify that the municipal objective is a reduced-form political-economy object, not a full welfare function. It represents the objective of local governments that are disproportionately responsive to incumbent residents and homeowners.

The current objective is:

\[
W^g
=
\sum_{i\in S^g}
\left[
\omega_1 P_i
+\omega_2 B_i^{\text{loc}}
-\omega_3 N_i
\right].
\]

A clearer interpretation is:

- \(\omega_1\): political weight on incumbent property values, especially homeowners.
- \(\omega_2\): political weight on neighborhood amenities, environmental quality, school quality, or local character.
- \(\omega_3\): political weight on local congestion, crowding, or fiscal/public-service costs from additional development.

These are not necessarily social welfare weights. They capture the political overrepresentation of incumbent residents relative to renters, future residents, commuters from other municipalities, and the metropolitan transportation authority.

To discipline these parameters quantitatively, I can use one of two approaches:

1. **Calibration to observed zoning restrictiveness.** Choose \(\omega\) so that the model matches observed housing supply elasticities or zoning constraints by location/metro.
2. **Political-economy moments.** Use moments from the literature on zoning and local control, such as the effect of homeownership, income, or ward-based representation on permits and density restrictions.

The first approach is simpler and probably better for the proposal. I can say that \(\omega\) will be chosen so that model-implied development constraints match observed housing supply elasticity or zoning restrictiveness. Then counterfactuals can vary \(\omega\) to represent more or less restrictive local political environments.

The proposal should also distinguish between:

- **private/local benefits of zoning:** higher property values, lower local congestion, preserved amenities;
- **external costs of zoning:** higher regional housing prices, more sprawl, longer commuting, and lower returns to transit investment.

That distinction is exactly why the planner benchmark differs from decentralized municipal zoning.

## Proposed revision to the proposal

I should revise the model section in three places:

1. Add an explicit "Timing" paragraph before the equilibrium definition.
2. Replace the generic commuting-cost function with a mode-specific road/transit structure.
3. Expand the municipal objective paragraph to define the \(\omega\) parameters as reduced-form political weights and explain how they will be disciplined.

Possible short text to add:

> The baseline model treats zoning as a slow-moving local policy chosen before regional transportation investment. Municipalities choose zoning to maximize a reduced-form incumbent-resident objective and do not internalize the effect of their zoning choices on the metropolitan transportation authority's investment returns. The transportation authority then chooses road and transit investment taking the vector of zoning policies as given. This timing captures the institutional mismatch between local land-use control and regional transportation planning.

Possible text for road versus transit:

> Road and transit investment enter the model through different technologies. Road investment lowers auto travel costs over a broad network but is subject to congestion from vehicle traffic. Transit investment lowers public-commuting costs only for routes connected to the transit network and has returns that depend on the density of residents and jobs near transit-accessible locations. Therefore restrictive zoning has an asymmetric effect: it lowers the return to transit more strongly than the return to road investment by limiting the density and ridership response around stations.

Stronger version:

> Road and transit investment affect different margins of urban form. Road investment expands the feasible commuting radius and supports lower-density peripheral development. Transit investment raises accessibility along fixed corridors and is valuable only when residents and jobs can concentrate near stations. Zoning therefore changes the relative return to the two modes: restrictive zoning weakens transit by suppressing station-area density and ridership, while the displaced growth increases demand for car-oriented peripheral commuting. This asymmetry is central to the mechanism: fragmented zoning can make road investment privately or institutionally attractive even when coordinated zoning and transit investment would generate higher metropolitan welfare.

Possible text for municipal objective:

> The weights in the municipal objective are reduced-form political-economy weights. They capture the fact that local governments are disproportionately responsive to incumbent residents and homeowners, who value property prices, neighborhood amenities, and low local congestion. These weights are not social welfare weights; they exclude benefits to potential residents, commuters from other municipalities, and the regional transportation system. Quantitatively, I will discipline these parameters using observed housing supply elasticities or zoning restrictiveness measures.
