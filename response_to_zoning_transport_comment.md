# Response to Comment: Do the Results Document Relations Between Zoning Policies and Transportation?

## Comment

> Document relations between zoning policies and transportation; show facts that they are responding to each other.

## Short Answer

The current model directly speaks to this comment: zoning and transportation are jointly determined in a decentralized equilibrium. Municipalities choose local residential and commercial capacity while taking transportation investment as given, and the transportation authority chooses network investment while taking the zoning vector as given. In the model, each side best-responds to the other.

The current empirical evidence, however, should be described more carefully. With the data currently available, I can document **spatial equilibrium relationships** between transit access, employment concentration, and effective land-use constraints. These facts are consistent with zoning and transportation being mutually related, but they do not yet prove dynamic policy response in both directions.

The correct framing is therefore:

> The preliminary evidence documents that transit access, employment concentration, and effective land-use constraints are systematically related in DFW. These facts are consistent with the model's zoning-transportation feedback mechanism, but the current data do not yet establish direct causal policy responses. The next empirical step is to add historical zoning/TOD changes and station-area census panels to test dynamic response directly.

## How the Model Answers the Comment

The model has two policy makers:

1. **Municipal governments** choose local zoning:

   \[
   \{\bar H_i^R,\bar H_i^F\}_{i\in S^g}
   \]

   where \(\bar H_i^R\) is residential capacity and \(\bar H_i^F\) is commercial capacity.

2. **The transportation authority** chooses transportation investment:

   \[
   \{I_{jk}\}_{j,k\in S}.
   \]

The key theoretical point is that these decisions are interdependent.

Municipal zoning affects transportation returns because land-use capacity changes where people live, where firms locate, and therefore how many riders use a transit link:

\[
\bar H_i^R,\bar H_i^F
\rightarrow
N_i,L_i
\rightarrow
n_{ij}
\rightarrow
\frac{\partial \Phi}{\partial I_{jk}}.
\]

Transportation investment affects zoning incentives because lower commuting costs raise the attractiveness of connected locations:

\[
I_{jk}
\uparrow
\rightarrow
\tau_{ij}
\downarrow
\rightarrow
\tilde V_{ij}
\uparrow
\rightarrow
N_i
\uparrow
\rightarrow
\text{municipal congestion pressure}
\uparrow.
\]

Thus, the model does not treat zoning and transportation as independent policies. It treats them as simultaneous best responses:

> Municipalities choose zoning given the transportation network, and the transportation authority chooses investment given the zoning vector.

This is the theoretical sense in which zoning policies and transportation "respond to each other."

## What the Current Data Can Show

The current empirical work uses three main data sources:

- Baum-Snow and Han tract-level housing supply elasticity for Dallas, where lower elasticity proxies for tighter effective land-use constraints.
- LODES employment inflows by tract.
- DART station locations and transit access indicators.

With these data, I can document three facts.

### Fact 1: Employment Centers Are More Supply Constrained

In the current P1 regression, tracts with more employment inflows have lower housing supply elasticity:

\[
\hat\gamma_i
=
\alpha
+\beta_1\log(1+L_i)
+\beta_2 pctdis_i
+\epsilon_i,
\]

with \(\hat\beta_1<0\) across specifications.

Interpretation:

> High-employment locations are also more constrained on the residential supply margin. This is consistent with the model's municipal tradeoff: places with large employment concentration face stronger local congestion or worker-influx concerns when allowing additional residential development.

Important limitation:

> This does not prove that employment caused restrictive zoning. It documents an equilibrium relationship between employment concentration and effective land-use constraints.

### Fact 2: DART-Adjacent Tracts Are More Supply Constrained

In the current P2 regression, tracts near DART stations have lower housing supply elasticity, even after controlling for distance to the CBD and employment:

\[
\hat\gamma_i
=
\alpha
+\beta_1 \mathbf{1}[\text{near DART}]_i
+\beta_2 pctdis_i
+\beta_3\log(1+L_i)
+\epsilon_i.
\]

The estimate is negative: DART-adjacent tracts are less elastic, meaning more constrained.

Interpretation:

> Transit access and restrictive effective land-use conditions coexist in the locations where transit returns depend most on density. This is consistent with the model's mechanism: transit raises location attractiveness, but local land-use constraints can suppress the residential response.

Important limitation:

> This does not prove that municipalities tightened zoning after DART arrived. DART may have been routed through places that were already dense, central, built out, or politically constrained.

### Fact 3: Existing NHGIS Data Are Not Yet Enough for the Preferred Dynamic Test

The project instructions identify the ideal empirical test:

\[
Y_{g,t}
=
\alpha_g
+\lambda_t
+\beta_1 PostTransit_{g,t}
+\beta_2(PostTransit_{g,t}\times TightZoning_g)
+X_{g,t}'\Gamma
+\epsilon_{g,t}.
\]

This specification would test whether transit-served areas with tighter land-use constraints have weaker post-opening density, housing, ridership, or commuting responses.

The current NHGIS data in `/Volumes/ORICO/Proposal for SYP` include tract-level nominal time-series CSV files with population and housing units, but they are not sufficient for this preferred panel because they lack:

- NHGIS GIS boundary shapefiles for 1990, 2000, 2010, and 2020;
- harmonized tract or block-group geographies;
- income, tenure, vacancy, race/ethnicity, and commute-mode variables;
- a station-buffer panel around DART/TRE/TEXRail openings.

Therefore, the current evidence can motivate the feedback mechanism, but the direct event-study test remains a next step.

## What the Current Evidence Does Not Yet Show

The comment asks whether zoning policies and transportation are "responding to each other." That requires evidence of policy timing or mutual adjustment.

The current data do **not yet** show:

1. **Zoning response to transportation**

   For example:

   \[
   Transit_{i,t}
   \rightarrow
   Zoning_{i,t+1}.
   \]

   To show this directly, I would need zoning amendment dates, TOD overlay adoption dates, station-area plan dates, or changes in allowed density around stations before and after opening.

2. **Transportation response to zoning**

   For example:

   \[
   Zoning_{i,t}
   \rightarrow
   TransitInvestment_{i,t+1}.
   \]

   To show this directly, I would need planned routes, proposed-but-unbuilt lines, station siting decisions, cost/ridership projections, or evidence that transit agencies avoided or favored places based on land-use capacity.

3. **Causal response**

   The current P1 and P2 estimates are cross-sectional. They should not be described as causal proof that employment or transit caused zoning changes.

## How I Should Modify the Presentation

The current slides should avoid saying that P1 and P2 "show" zoning and transportation respond to one another. A safer and more accurate language is:

> P1 and P2 document equilibrium relationships between employment concentration, transit access, and effective land-use constraints. These facts are consistent with the model's zoning-transportation feedback mechanism, but they are not causal estimates of policy response.

### Suggested Revision for P1

Current framing:

> High employment concentration \(\Rightarrow\) tighter residential zoning.

Recommended framing:

> High-employment tracts are more supply constrained.

Suggested interpretation:

> This pattern is consistent with the municipal side of the model: locations with greater employment concentration face stronger local congestion or worker-influx concerns. However, the estimate is an equilibrium correlation, not proof that employment caused zoning restrictions.

### Suggested Revision for P2

Current framing:

> Transit access raises population pressure \(\Rightarrow\) tighter zoning response.

Recommended framing:

> DART-adjacent tracts are more supply constrained.

Suggested interpretation:

> This pattern is consistent with the idea that transit access and land-use constraints interact in equilibrium. But it may also reflect station siting into already dense or constrained corridors. I therefore interpret it as evidence of co-location, not direct evidence of post-transit zoning tightening.

### Suggested Revision for P3

P3 should be the main bridge from the current facts to the comment. The revised framing should be:

> To directly test whether zoning and transportation respond to each other, I need a station-area panel with transit opening dates, local density outcomes, and land-use capacity measures. The preferred test is whether post-transit density or ridership responses are weaker in places with tighter zoning or lower pre-opening capacity.

## Data Needed to Answer the Comment Directly

To turn the current suggestive evidence into a direct answer, I need two additional data modules.

### 1. Zoning Response to Transit

Data needed:

- station opening years for DART, TRE, and TEXRail;
- municipal zoning amendment dates;
- TOD overlay adoption dates;
- changes in allowed FAR, height, multifamily permission, minimum lot size, parking requirements, or single-family-only zoning;
- station-area plans and comprehensive-plan amendments.

Preferred specification:

\[
ZoningCapacity_{s,t}
=
\alpha_s
+\lambda_t
+\beta PostTransit_{s,t}
+X_{s,t}'\Gamma
+\epsilon_{s,t}.
\]

This would test whether zoning capacity changes after transit arrives.

### 2. Transportation Return Response to Zoning

Data needed:

- NHGIS or Census tract/block-group panels for 1990, 2000, 2010, and 2020;
- GIS boundaries or crosswalks to harmonize geography;
- station buffers around all DART/TRE/TEXRail stations;
- outcomes such as population density, housing-unit density, transit commute share, and ridership;
- pre-opening land-use capacity or zoning restrictiveness.

Preferred specification:

\[
Y_{s,t}
=
\alpha_s
+\lambda_t
+\beta_1 PostTransit_{s,t}
+\beta_2(PostTransit_{s,t}\times TightZoning_s)
+X_{s,t}'\Gamma
+\epsilon_{s,t}.
\]

The key prediction is:

\[
\beta_2<0.
\]

This would test whether transit produces weaker local development or ridership responses where land-use constraints are tighter.

## Final Answer to the Comment

My current answer to the comment should be:

> The model explicitly formalizes a two-way relationship between zoning and transportation. Municipalities choose zoning while taking transportation access as given, and the transportation authority chooses investment while taking the zoning vector as given. The preliminary facts document that employment concentration, transit access, and effective land-use constraints are systematically related in DFW. These facts are consistent with the model's feedback mechanism, but they do not yet prove dynamic policy response. To directly show that zoning policies and transportation respond to each other, the next step is to construct a station-area panel with transit opening dates, zoning/TOD changes, and Census/NHGIS outcomes.

## One-Sentence Slide Version

> The current evidence shows equilibrium co-location of transit, employment, and land-use constraints; the model interprets this as a zoning-transportation feedback mechanism, while the next empirical step is to test the timing of policy responses directly.

