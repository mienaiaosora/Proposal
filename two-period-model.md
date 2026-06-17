# Model

## 1. Motivation

The goal is to model how local zoning decisions affect the return to transportation investment. The central idea is that zoning restrictions limit the local housing response to improved accessibility. As a result, even a welfare-oriented transportation agency may underinvest when it takes local zoning as given.

The model builds on a two-period structure similar to Favilukis and Song (2025). At time $t=0$, local jurisdictions choose zoning restrictions, and the transportation agency chooses the optimal transit network. At time $t=1$, households make location choices, subject to moving, living, and working decisions. The model is a closed economy — no migration in or out — so welfare is shaped entirely by zoning and the transportation network.

## 2. Basic Environment

Consider a metropolitan area consisting of municipalities indexed by $g \in G$. Each municipality $g$ contains a set of locations $S^g$, and the full set of locations is $S = \bigcup_{g \in G} S^g$ with $S^g \cap S^{g'} = \emptyset$ for $g \neq g'$.

Each municipality has a representative landowner who controls local zoning. Zoning is represented by a housing capacity variable $h_{0,i}$ at location $i \in S^g$: a higher $h_{0,i}$ means looser zoning and greater housing capacity.

Transportation investment is denoted by $I_{jk}$ on link $(j,k)$. Investment reduces commuting costs or improves accessibility.

## 3. Timing

The model has two periods.

### Time $t=0$

Each municipality $g$ chooses zoning capacity $\{h_{0,i}\}_{i \in S^g}$, taking other municipalities' choices $h_{0,-g}$ as given (Nash equilibrium in zoning). The transportation agency then observes the full zoning vector $h_0$ and chooses the optimal network $I$.

### Time $t=1$

Given zoning $h_0 = \{h_{0,i}\}_{i \in S}$ and transportation investment $I$:

1. Households choose residence location $i$, workplace $j$, and commute route.
2. Housing markets clear; local housing prices $q_i$ are determined.
3. Labor markets clear; wages $w_j$ are determined.
4. Local population $N_i$ is determined.

## 4. Local Landowner Problem

A representative landowner in municipality $g$ chooses zoning capacity to maximize expected period-1 utility of incumbents net of construction cost:

$$u_{0,g} = \max_{\{h_{0,i}\}_{i \in S^g}} \sum_{i \in S^g} E\!\left\{u_{1,i}(h_{0,i};\,h_{0,-g},\,I)\right\} - \lambda \sum_{i \in S^g} h_{0,i}$$

where $\lambda > 0$ is the per-unit cost of expanding housing capacity. Each landowner takes other municipalities' zoning decisions and the transportation investment as given.

## 5. In Period 1

For a household $\omega$ who initially lives at origin $o$ and chooses residence $i$ and workplace $j$, the optimization problem is:

$$u_{1,\omega oij} = \max_{c_{ij},\,h_{ij}} \frac{B_i}{D_{oij}(I,N)} \left(\frac{c_{ij}}{\alpha}\right)^{\!\alpha} \left(\frac{h_{ij}}{1-\alpha}\right)^{\!1-\alpha} \upsilon_{\omega ij}$$

subject to

$$c_{ij} + h_{ij}\,q_i \leq w_j - \phi(N_i, h_{0,i}) + h_{0,o}\,q_o$$

where:
- $q_i$ is the local housing price at destination $i$,
- $h_{0,o}\,q_o$ is rental income from the origin housing that the incumbent owns,
- $\phi(N_i, h_{0,i})$ is a monetary congestion cost at the chosen destination — increasing in local population $N_i$ and decreasing in housing capacity $h_{0,i}$ (more capacity relieves density pressure): $\partial \phi/\partial N_i \geq 0$, $\partial \phi/\partial h_{0,i} \leq 0$.

The **spatial friction** is:

$$D_{oij}(I, N) = \varepsilon_{oij}\exp\!\bigl(\rho\, m_{oi} + \kappa\,\tau_{ij}(I, N)\bigr)$$

where $\varepsilon_{oij}$ is a deterministic bilateral component, $m_{oi}$ is the moving cost from $o$ to $i$, and $\tau_{ij}(I,N)$ is the commuting cost from residence $i$ to workplace $j$ (decreasing in investment $I$, increasing in congestion $N$).

The **idiosyncratic shock** $\upsilon_{\omega ij}$ is drawn independently across $(i,j)$ pairs with Fréchet CDF:

$$\Pr(\upsilon_{\omega ij} \leq z) = \exp\!\left(-T_i E_j\, z^{-\epsilon}\right), \quad z > 0,\quad \epsilon > 1$$

where $T_i > 0$ captures location $i$'s attractiveness as a residence, $E_j > 0$ captures location $j$'s attractiveness as a workplace, and $\epsilon$ is the dispersion parameter.

## 6. Solving the Household Problem

**Effective income.** Define the effective income for a household from $o$ choosing $(i, j)$:

$$Y_{oij} \equiv w_j + h_{0,o}\,q_o - \phi(N_i, h_{0,i})$$

This is wages plus rental income from origin housing minus the monetary congestion cost at the destination.

**Optimal demands.** The Cobb-Douglas normalization $(c/\alpha)^\alpha(h/(1-\alpha))^{1-\alpha}$ implies constant budget shares regardless of prices:

$$c_{ij}^* = \alpha\, Y_{oij}, \qquad h_{ij}^* = \frac{(1-\alpha)\,Y_{oij}}{q_i}$$

**Indirect utility.** Substituting the optimal demands, the normalization factors cancel:

$$\boxed{V_{oij,\omega} = \frac{B_i \cdot Y_{oij}}{D_{oij} \cdot q_i^{1-\alpha}} \cdot \upsilon_{\omega ij} \;\equiv\; \tilde{V}_{oij} \cdot \upsilon_{\omega ij}}$$

where $\tilde{V}_{oij}$ is the **deterministic indirect utility** — the systematic attractiveness of the $(o \to i, j)$ triple.

**Derivation check.** With $c^* = \alpha Y$ and $h^* q_i = (1-\alpha)Y$:
$$u^* = \frac{B_i}{D_{oij}}\bigl(\alpha Y/\alpha\bigr)^\alpha\bigl((1-\alpha)Y/q_i\,/\,(1-\alpha)\bigr)^{1-\alpha}\upsilon = \frac{B_i}{D_{oij}}\,Y^\alpha\,(Y/q_i)^{1-\alpha}\,\upsilon = \frac{B_i\,Y}{D_{oij}\,q_i^{1-\alpha}}\,\upsilon \quad \checkmark$$

**Mechanism check on $\tilde{V}_{oij}$:**

| Change | Effect on $\tilde{V}_{oij}$ | Intuition |
|--------|-----------------------------|-----------|
| $\uparrow w_j$ | $\uparrow$ (via $\uparrow Y_{oij}$) | Better wages at $j$ raise income |
| $\uparrow h_{0,o}\,q_o$ | $\uparrow$ (via $\uparrow Y_{oij}$) | More rental income from origin |
| $\uparrow \phi$ | $\downarrow$ (via $\downarrow Y_{oij}$) | More congestion at $i$ lowers net income |
| $\uparrow q_i$ | $\downarrow$ (housing expensive at $i$) | Deters in-movers |
| $\uparrow D_{oij}$ | $\downarrow$ (higher friction) | Harder/costlier to reach $(i,j)$ |
| $\uparrow B_i$ | $\uparrow$ (destination amenity) | Better amenities at $i$ |

All signs are directionally correct. ✓

## 7. Commuting Flows and Expected Utility

Each household from $o$ independently draws Fréchet shocks $\upsilon_{\omega ij}$ and chooses $(i,j)$ to maximize $V_{oij,\omega} = \tilde{V}_{oij} \cdot \upsilon_{\omega ij}$.

**Commuting probability.** By the Fréchet aggregation theorem (Eaton and Kortum, 2002), the probability that a household from $o$ chooses residence $i$ and workplace $j$ is:

$$\boxed{\pi_{oij} = \frac{T_i\,E_j\,\tilde{V}_{oij}^\epsilon}{\Phi_o}, \qquad \Phi_o \equiv \sum_{i'}\sum_{j'} T_{i'}\,E_{j'}\,\tilde{V}_{oi'j'}^\epsilon}$$

**Expected utility.** The expected maximum of $\{\tilde{V}_{oij}\,\upsilon_{\omega ij}\}$ is itself Fréchet with scale $\Phi_o^{1/\epsilon}$, giving:

$$\boxed{\bar{U}_o = \Gamma\!\left(1 - \tfrac{1}{\epsilon}\right)\,\Phi_o^{1/\epsilon}}$$

where $\Gamma(\cdot)$ is the gamma function. Expected welfare at $o$ is a power of the aggregate attractiveness index $\Phi_o$.

**Commuting flows and period-1 population.**

$$L_{oij} = N_o^0 \cdot \pi_{oij}, \qquad N_i^1 = \sum_o\sum_j L_{oij}$$

where $N_o^0$ is the initial (period-0) count at origin $o$.

**Mechanism checks on $\pi_{oij}$:**

| Change | Effect on $\pi_{oij}$ | Channel |
|--------|----------------------|---------|
| $\uparrow w_j$ | $\uparrow$ | $\uparrow \tilde{V}_{oij}$ via $\uparrow Y_{oij}$ |
| $\uparrow \tau_{ij}$ | $\downarrow$ | $\downarrow \tilde{V}_{oij}$ via $\uparrow D_{oij}$ |
| $\uparrow q_i$ | $\downarrow$ | $\downarrow \tilde{V}_{oij}$ directly |
| $\uparrow h_{0,i}$ | $\uparrow$ | $\downarrow q_i \Rightarrow \uparrow \tilde{V}_{oij}$ — **the core density channel** |
| $\uparrow \Phi_o$ | $\downarrow$ (for $(i,j)$ pair) | Other destinations become relatively more attractive |

The **core density channel** — looser zoning lowers housing prices, attracting more residents — is the mechanism through which zoning affects transit ridership and investment returns.

**Welfare index decomposition.** Writing $\Phi_o = \sum_{i',j'} T_{i'}E_{j'}\tilde{V}_{oi'j'}^\epsilon$, we can interpret $\pi_{oij} = T_i E_j \tilde{V}_{oij}^\epsilon / \Phi_o$ as the share of aggregate welfare contributed by destination $(i,j)$. This gravity-type expression shows that flows are driven by the relative product of bilateral attractiveness $\tilde{V}_{oij}^\epsilon$ and location fixed effects $T_i E_j$.

## 8. Market Clearing

**Housing market.** At each location $i$, total housing demand equals zoning-constrained supply:

$$\sum_o\sum_j L_{oij} \cdot h_{ij}^* = h_{0,i}$$

Substituting $h_{ij}^* = (1-\alpha)Y_{oij}/q_i$:

$$\boxed{q_i = \frac{(1-\alpha)\displaystyle\sum_o\sum_j L_{oij}\,Y_{oij}}{h_{0,i}}}$$

The housing price at $i$ equals the (income-weighted) total income flowing to location $i$, divided by housing capacity. Two implications:

1. **Zoning tightens prices**: $\partial q_i/\partial h_{0,i} < 0$ holding flows fixed — stricter zoning raises prices. ✓
2. **Demand raises prices**: more income at $i$ (more workers, higher wages) raises $q_i$. ✓

**Labor market.** Total employment at $j$: $L_j = \sum_o\sum_i L_{oij}$. From firm profit maximization with CRS production $y_j = A_j L_j^\beta (H_j^F)^{1-\beta}$:

$$w_j = \beta\,A_j\!\left(\frac{H_j^F}{L_j}\right)^{\!1-\beta}$$

More workers relative to commercial floor space drives down the marginal product and hence wages. ✓

**Fixed-point structure.** The equilibrium is a fixed point in $(\{q_i\}, \{w_j\})$: commuting probabilities $\pi_{oij}$ depend on prices, prices depend on flows, flows depend on probabilities. Standard contraction arguments establish existence under regularity conditions on $\phi$ and the Fréchet distribution.

## 9. Optimal Transportation Network

In period 0, the transportation agency chooses the optimal network conditional on the full zoning vector $h_0$:

$$\max_{\{I_{jk}\}} \sum_o N_o^0\,\bar{U}_o(I;\,h_0)$$

subject to

$$\sum_{j,k} \delta_{jk}\,I_{jk} \leq K, \qquad \underline{I}_{jk} \leq I_{jk} \leq \bar{I}_{jk}$$

Transportation investment enters the commuting cost function. Following Fajgelbaum et al. (2020):

$$\tau_{jk}(I, N) = \delta^\tau_{jk}\,\frac{N_{jk}^\rho}{I_{jk}^\gamma}$$

with $\partial\tau/\partial N \geq 0$ (congestion) and $\partial\tau/\partial I \leq 0$ (investment reduces cost).

## 10. Decentralized Equilibrium

**Definition.** A decentralized equilibrium (DE) is a profile $\bigl(\{h_{0,i}^*\},\,I^*,\,\{\pi_{oij}^*\},\,\{q_i^*,\,w_j^*\}\bigr)$ satisfying:

1. *Household optimality*: $\{\pi_{oij}^*\}$ follows the commuting flow formula given $(q_i^*, w_j^*, I^*)$.
2. *Market clearing*: housing and labor markets clear at $(q_i^*, w_j^*)$.
3. *Municipal Nash*: each $g$ chooses $\{h_{0,i}^*\}_{i \in S^g}$ to maximize $u_{0,g}$, taking $h_{0,-g}$ and $I$ as given.
4. *Transport optimality*: $I^*$ maximizes aggregate welfare taking $h_0^*$ as given.

**Municipal first-order condition.** The interior FOC for location $i \in S^g$:

$$\frac{\partial\,\bar{U}_i}{\partial h_{0,i}} = \lambda$$

Expanding with $\bar{U}_i = \Gamma(1-1/\epsilon)\,\Phi_i^{1/\epsilon}$:

$$\frac{\partial\,\bar{U}_i}{\partial h_{0,i}} = \frac{\bar{U}_i}{\Phi_i}\sum_{i',j'} T_{i'}\,E_{j'}\,\tilde{V}_{ii'j'}^\epsilon \cdot \frac{\partial\ln\tilde{V}_{ii'j'}}{\partial h_{0,i}}$$

Since $\ln\tilde{V}_{ii'j'} = \ln B_{i'} + \ln Y_{ii'j'} - \ln D_{ii'j'} - (1-\alpha)\ln q_{i'}$, the derivative runs through two channels:

$$\frac{\partial\ln\tilde{V}_{ii'j'}}{\partial h_{0,i}} = \underbrace{\frac{1}{Y_{ii'j'}}\frac{\partial Y_{ii'j'}}{\partial h_{0,i}}}_{\text{income channel}} \underbrace{-(1-\alpha)\frac{\partial\ln q_{i'}}{\partial h_{0,i}}}_{\substack{\text{housing price channel} \\ \text{(GE effect, }i'\text{ may}=i)}}$$

For the **income channel**, with the incumbent at $o = i$:

$$\frac{\partial Y_{ii'j'}}{\partial h_{0,i}} = \underbrace{q_i + h_{0,i}\frac{\partial q_i}{\partial h_{0,i}}}_{\substack{\text{marginal rental revenue} \\ \text{(sign ambiguous)}}} \underbrace{-\frac{\partial\phi}{\partial h_{0,i}}}_{\substack{\geq\,0\,:\,\text{direct} \\ \text{congestion relief}}} \underbrace{-\frac{\partial\phi}{\partial N_i}\cdot\frac{\partial N_i}{\partial h_{0,i}}\cdot\mathbf{1}[i'=i]}_{\substack{\leq\,0\,:\,\text{in-migration} \\ \text{raises congestion}}}$$

Three forces are at work:
1. **Rental revenue**: loosening zoning lowers $q_i$ but may attract enough residents to leave $h_{0,i}q_i$ unchanged or larger.
2. **Direct congestion relief**: more housing capacity directly reduces crowding ($-\partial\phi/\partial h_{0,i} \geq 0$).
3. **In-migration congestion**: more capacity attracts in-movers, raising $N_i$ and hence $\phi$ ($-\partial\phi/\partial N_i \cdot \partial N_i/\partial h_{0,i} \leq 0$).

The municipality stops expanding zoning when the net benefit equals $\lambda$.

**What the municipality's FOC omits.** The DE FOC only reflects the welfare of incumbents at $i \in S^g$. Two positive externalities are ignored:

1. **Cross-municipality welfare externality**: Households from $o \notin S^g$ who choose to live at $i$ benefit from lower $q_i$ when zoning is loosened. The municipality does not internalize $\partial\bar{U}_{o'}/\partial h_{0,i}$ for $o' \notin S^g$.

2. **Transit-zoning externality**: Looser zoning at $i$ raises local density, which increases transit ridership near $i$ and raises the marginal return to transit investment. The municipality does not account for how its zoning choice shifts the transport authority's optimal investment allocation.

**Transportation authority FOC.** The authority maximizes $\sum_o N_o^0\,\bar{U}_o$ subject to the budget. With multiplier $\mu$ on the constraint:

$$\sum_o N_o^0\,\frac{\partial\bar{U}_o}{\partial I_{jk}} = \mu\,\delta_{jk}, \qquad \forall\,(j,k)$$

Tracing the chain rule $\bar{U}_o \to \Phi_o \to \tilde{V}_{oij} \to D_{oij} \to \tau_{ij} \to I_{jk}$:

$$\sum_o N_o^0\frac{\partial\bar{U}_o}{\partial I_{jk}} = -\kappa\sum_o\frac{N_o^0\bar{U}_o}{\Phi_o}\sum_{i'} T_{i'}\,E_j\,\tilde{V}_{oi'j}^\epsilon \cdot \frac{1}{D_{oi'j}}\cdot\frac{\partial D_{oi'j}}{\partial\tau}\cdot\frac{\partial\tau_{i'j}}{\partial I_{jk}}$$

Since $\partial D/\partial\tau > 0$ (higher commuting cost raises friction) and $\partial\tau/\partial I \leq 0$ (investment reduces cost), the full expression is non-negative: investment on link $(j,k)$ raises aggregate welfare by reducing commuting costs. The authority sets the marginal benefit equal to the shadow cost of the budget.

## 11. Social Planner Problem

The social planner jointly chooses zoning and transportation investment to maximize aggregate welfare:

$$\max_{\{h_{0,i}\},\,\{I_{jk}\}} \sum_o N_o^0\,\bar{U}_o(h_0,\,I)$$

subject to $\displaystyle\sum_{j,k}\delta_{jk}\,I_{jk} \leq K$ and $h_{0,i} \geq 0$.

**Planner's FOC for investment.** Identical to the transport authority's FOC — the planner and the authority share the same objective over investment given a zoning vector.

**Planner's FOC for zoning at location $i$** (with $\mu^P$ the Lagrange multiplier on the investment budget):

$$\sum_o N_o^0\,\frac{\partial\bar{U}_o}{\partial h_{0,i}} + \mu^P\,\frac{\partial I^*}{\partial h_{0,i}} = \lambda$$

The second term $\mu^P\,\partial I^*/\partial h_{0,i}$ is the **induced investment effect**: when the planner loosens zoning at $i$, optimal transport investment adjusts, generating additional welfare.

**Decomposing the planner's FOC to expose the DE wedge:**

$$\underbrace{\frac{\partial\bar{U}_i}{\partial h_{0,i}}}_{\text{DE term}} + \underbrace{\sum_{o \,:\, o \notin S^g} N_o^0\,\frac{\partial\bar{U}_o}{\partial h_{0,i}}}_{\substack{\text{cross-municipality} \\ \text{externality} \;\geq\; 0}} + \underbrace{\mu^P\,\frac{\partial I^*}{\partial h_{0,i}}}_{\substack{\text{transit-zoning} \\ \text{externality} \;\geq\; 0}} = \lambda$$

Both omitted terms are non-negative:

- **Cross-municipality externality**: $\partial\bar{U}_{o'}/\partial h_{0,i} > 0$ for $o' \notin S^g$ because looser zoning at $i$ lowers $q_i$, making location $i$ more attractive for everyone — lower housing cost raises all households' $\tilde{V}_{oi j}$ for $(i,j)$ choices.
- **Transit-zoning externality**: $\partial I^*/\partial h_{0,i} > 0$ because more density at $i$ raises transit ridership and the marginal benefit of transit links serving $i$, inducing the planner to invest more — which in turn raises $\bar{U}_o$ for all $o$.

**Result: decentralized zoning is over-restrictive.**

Since the planner's LHS exceeds the municipality's LHS at the same $h_{0,i}$, the planner optimum requires higher zoning to bring the LHS back down to $\lambda$:

$$\boxed{h_{0,i}^{\,\mathrm{SP}} > h_{0,i}^{\,\mathrm{DE}} \quad \text{for all } i}$$

The decentralized equilibrium features **too little housing capacity**: municipalities internalize only a fraction of the social return to zoning. The gap arises entirely from the two externalities above, both of which are related to the transit-zoning complementarity.

## 12. Mechanism Check: Transit Returns and Zoning Capacity

**General mechanism from equilibrium.** The transit-zoning externality term $\mu^P\,\partial I^*/\partial h_{0,i}$ is positive precisely when transit and housing density are complements — i.e., when transit returns increase with local density. We verify this directly.

**Comparative static on transit ridership.** From the commuting flow formula, the number of households using the transit link from $i$ to $j$ (denoting it $L_{ij}^T = \sum_o L_{oij}^T$) depends on density at $i$:

$$\frac{\partial L_{ij}^T}{\partial h_{0,i}} = \sum_o N_o^0\,\frac{\partial\pi_{oij}^T}{\partial\tilde{V}_{oij}^T}\cdot\frac{\partial\tilde{V}_{oij}^T}{\partial q_i}\cdot\frac{\partial q_i}{\partial h_{0,i}}$$

Each factor:
- $\partial\pi_{oij}^T/\partial\tilde{V}_{oij}^T > 0$: higher indirect utility for $(i,j)^T$ raises its probability. ✓
- $\partial\tilde{V}_{oij}^T/\partial q_i < 0$: cheaper housing at $i$ raises attractiveness (for transit users, living near transit is essential). ✓
- $\partial q_i/\partial h_{0,i} < 0$: looser zoning lowers housing prices (holding flows fixed). ✓

The product of three negatives/positives is positive: **$\partial L_{ij}^T/\partial h_{0,i} > 0$.** Transit ridership increases when zoning is loosened. ✓

**Marginal benefit of transit investment.** The transport authority's marginal benefit of investing in transit link $(j,k)$ is:

$$MB^T_{jk} \propto \sum_{o,i} L_{oij}^T \cdot \left(-\frac{\partial\tau_{ij}^T}{\partial I_{jk}^T}\right) = \sum_{o,i} L_{oij}^T \cdot \Delta\tau_{jk}^T > 0$$

Since $\partial MB^T_{jk}/\partial h_{0,i} \propto \partial L_{ij}^T/\partial h_{0,i} > 0$, transit returns rise when zoning is loosened at the transit node. ✓

**Why road returns are less sensitive.** Road investment benefits accrue across all origin-destination pairs using the road network — they are spatially diffuse. A marginal increase in density at a single transit node $i^*$ raises road ridership $L_{i^*j}^R$ by bringing more households near $i^*$, but car commuters are not tied to $i^*$ the way transit users are. Road users can originate from any low-density location, whereas transit users must be near a station.

Formally, for a road link $(j,k)$ that does not pass through transit node $i^*$:

$$\frac{\partial MB^R_{jk}}{\partial h_{0,i^*}} \approx 0$$

Even for road links that do pass through $i^*$, the density effect is diluted across many alternative routes that substitute for transit.

**The asymmetry — key result:**

$$\frac{\partial MB^T_{jk}}{\partial h_{0,i^*}} > \frac{\partial MB^R_{jk}}{\partial h_{0,i^*}} \approx 0$$

Transit returns are **disproportionately sensitive** to zoning at transit-accessible nodes.

**Putting it together.** In the decentralized equilibrium:

> Municipalities set $h_{0,i}^{DE} < h_{0,i}^{SP}$ — too little zoning. This suppresses density near transit-accessible locations. The transport authority, observing sub-optimal spatial patterns, finds transit investment relatively less attractive. Road investment is comparatively unaffected. The equilibrium tilts toward roads and away from transit, even when the coordinated outcome (higher zoning + more transit) would deliver higher metropolitan welfare for all.

**Note on mode-specific extension.** A complete formal treatment of the transit vs. road asymmetry requires mode-specific commuting costs $\tau_{ijR}$ and $\tau_{ijT}$ with structurally different density complementarities (roads extensive-margin, transit intensive-margin) — see advisor feedback, Open Issue \#1 in CLAUDE.md. The mechanism established above holds for any model where transit ridership is more concentrated at fixed nodes than road ridership, which will be verified once mode-specific costs are incorporated.
