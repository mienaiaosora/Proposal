# Model

## 1. Motivation

The goal is to model how local zoning decisions affect the return to transportation investment. The central idea is that zoning restrictions limit the local housing response to improved accessibility. As a result, even a welfare-oriented transportation agency may underinvest when it takes local zoning as given.

The model builds on a two-period structure similar to Favilukis and Song (2025). At time $t=0$, local jurisdictions choose zoning restrictions. At time $t=1$, households make location choices, housing markets clear, and transportation investment affects accessibility.

## 2. Basic Environment

Consider a metropolitan area consisting of municipalities indexed by$g \in G.$

Each municipality has a representative landowner who controls local zoning. Zoning is represented by a housing capacity variable: $h_{0,g}.$


A higher $h_{0,g}$ means looser zoning and greater housing capacity. A lower $h_{0,g}$ means stricter zoning.

Transportation investment is denoted by $I$.


Investment reduces commuting costs or improves accessibility.

## 3. Timing

The model has two periods.

### Time $t=0$

Each municipality $g$ chooses zoning capacity:$h_{0,g}.$

The local landowner chooses $h_{0,g}$ taking other municipalities' zoning choices $h_{0,-g}$ as given.

And the transportation agency, taking $h_{0,g}$ as given, decide the optimal transit network.

### Time $t=1$

Given zoning $h_0 = \{h_{0,g}\}_{g \in G}$ and transportation investment $I$:

1. Households choose locations.
2. Housing markets clear.
3. Local housing prices $p_g$ are determined.
4. Local population $N_g$ is determined.
5. Accessibility and commuting costs are determined by $I$.

## 4. Local Landowner Problem 

A representative landowner in municipality $g$ chooses zoning capacity to maximize expected time-1 utility net of the cost of allowing housing capacity:

$u_{0,g}=\max_{h_{0,g}} \sum_{i \in g} u_{1,i}(h_{0,i};h_{0,-g},I)-\lambda \sum_{i\in g}h_{0,i}.$


In Preiod 1, the
subject to
$h_{1,i}q_{i}+c_{ij} \leq w_{ij} + q_{i}h_{0,i}-\phi(N_{i})$

where:

- $q_{i}$ is the local housing price,
- $h_{0,i}$ is the zoning rule controlled by the landowner,
- $w_{ij}$ is accessibility-adjusted income,
- $\phi(N_i)$ is local congestion or density disutility,
- $\lambda h_{0,i}$ is the cost of housing capacity.

## 5. In Period 1


## Optimal Transportation network
In period 0, the transportation agency will also make the optimal tranist network, given the zoning restrictions across municipalities:
$$
\begin{aligned}
\max_{I_{jk}} \sum_{}
\end{aligned}
$$
## 5. Decentralized Zoning Choice
The landowner internalizes local price effects and local congestion effects but does not internalize metro-wide benefits from additional housing capacity.

The omitted benefits may include:

1. welfare gains for potential entrants,
2. lower metro-wide housing costs,
3. greater labor-market access,
4. higher returns to transportation investment.

For this project, the key omitted term is the transportation-investment return.

## 6. Transportation Agency Problem

After zoning is fixed, the transportation agency chooses investment:

$
I^D
\in
\arg\max_I
W(I;h_0^D)-C(I),
$

where $h_0^D$ is the decentralized zoning vector and $C(I)$ is the cost of transportation investment.

The marginal benefit of investment depends on the number of households and firms that can respond to improved access. If zoning is restrictive, this response is limited.

## 7. Integrated Planner Problem

The integrated planner jointly chooses zoning and transportation investment:

$
(I^P,h_0^P)
\in
\arg\max_{I,h_0}
W(I,h_0)-C(I)-\lambda\sum_g h_{0,g}.
$

The planner internalizes the effect of zoning on the return to transportation investment.

## 8. Main Mechanism

The key complementarity is

$
W_{Ih}>0.
$

This condition means that transportation investment is more valuable when zoning allows greater housing capacity.

If local zoning is too restrictive,

$
h_0^D<h_0^P,
$

and if transportation investment and housing capacity are complements,

$
W_{Ih}>0,
$

then decentralized transportation investment is below the integrated-planner level:

$
I^D<I^P.
$

## 9. Core Proposition

**Proposition.** Suppose decentralized municipalities choose housing capacity without internalizing the effect of housing capacity on metro-wide transportation returns. If housing capacity and transportation investment are complements in welfare, then decentralized zoning leads to underinvestment in transportation relative to the integrated planner.

Formally, if

$
h_0^D<h_0^P
\quad \text{and} \quad
W_{Ih}>0,
$

then

$
I^D<I^P.
$

## 10. Interpretation

The mechanism is not simply that zoning restricts housing. The mechanism is that zoning restricts the demand response to transportation investment. When transportation improvements increase accessibility, the social value of that improvement depends on whether households and firms can locate in the improved-access areas. Restrictive zoning prevents this adjustment, lowering the measured return to investment.

Thus, even if the transportation agency is benevolent and maximizes welfare conditional on zoning, it may underinvest because it takes distorted local land-use policy as given.

## 11. Relation to Favilukis and Song (2025)

Favilukis and Song study why local zoning is too restrictive when zoning authority is fragmented across municipalities. Their key mechanism is that local homeowners internalize local congestion and price effects but do not internalize broader metro-wide affordability effects.

This project keeps the two-period local zoning structure but changes the omitted externality. Instead of focusing only on metro-wide affordability or agglomeration, the key externality is the effect of zoning on transportation-investment returns.

## 12. Next Modeling Step

The next step is to specify a simple spatial equilibrium at $t=1$. A minimal version should define:

1. household location choice,
2. housing market clearing,
3. local population $N_g(h_0,I)$,
4. housing price $p_g(h_0,I)$,
5. accessibility $Y_g(I)$,
6. welfare $W(I,h_0)$.

Once these objects are specified, the zoning FOC and transportation FOC can be compared formally.
