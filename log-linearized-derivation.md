# Log-linearized estimating equations and comparative statics

Working notes toward a "Quantification" section. Covers: (1) a gravity-equation estimating system for the commuting/Fréchet block, (2) recovery of amenities/productivities as residuals, (3) an exact (non-approximate) identification of the zoning fee from rent data, (4) a regression to recover the congestion parameters, and (5) the general-equilibrium log-linearized system behind the municipal FOC's comparative statics, plus a tractable "small open location" special case.

---

## 1. The gravity equation

Indirect utility is
$$
\tilde V_{ij} = \frac{B_i (w_j - \phi_i)}{\tau_{ij} (q_i^R)^{1-\alpha}}, \qquad \phi_i \equiv \phi(N_i, L_i),
$$
where $\phi_i$ is purely a residence-side object (it does not vary with $j$). The subtraction $w_j - \phi_i$ breaks the usual multiplicative ARSW-style gravity structure. Writing $w_j - \phi_i = w_j(1-\phi_i/w_j)$ and taking a first-order log approximation for $\phi_i/w_j$ small:
$$
\ln(w_j - \phi_i) \approx \ln w_j - \frac{\phi_i}{w_j}.
$$

Substituting into $\ln\pi_{ij} = \ln T_i + \ln E_j + \varepsilon \ln \tilde V_{ij} - \ln\Phi$ and using $\tau_{ij} = \delta_{ij}^\tau n_{ij}^\rho / I_{ij}^\gamma$:

$$
\ln \pi_{ij} \;\approx\; \underbrace{\Bigl[\ln T_i + \varepsilon \ln B_i - \varepsilon(1-\alpha)\ln q_i^R\Bigr]}_{\text{origin FE}} \;+\; \underbrace{\Bigl[\ln E_j + \varepsilon \ln w_j\Bigr]}_{\text{destination FE}} \;-\; \varepsilon\,\frac{\phi_i}{w_j} \;-\; \varepsilon \ln \delta_{ij}^\tau \;-\; \varepsilon\rho \ln n_{ij} \;+\; \varepsilon\gamma \ln I_{ij} \;-\; \ln\Phi.
$$

This is directly estimable as a structural-gravity regression on observed commuting flows $N\pi_{ij}$ (e.g. LODES), with origin and destination fixed effects, $\ln n_{ij}$ and $\ln I_{ij}$ as regressors, and $\phi_i/w_j$ constructed once a candidate $\hat\phi_i$ is available (see §4):

| Coefficient on | Recovers |
|---|---|
| $\ln n_{ij}$ | $-\varepsilon\rho$ |
| $\ln I_{ij}$ | $\varepsilon\gamma$ |
| $\phi_i/w_j$ | $-\varepsilon$ |

The last row is what identifies $\varepsilon$ itself, separately from the commuting-cost decay parameters $\rho,\gamma$.

---

## 2. Recovering amenities and productivities as residuals

Once $\varepsilon$ is pinned down, the origin fixed effect equals $\ln T_i + \varepsilon\ln B_i - \varepsilon(1-\alpha)\ln q_i^R$. Since $q_i^R$ is observed (rent data) and $\alpha$ is calibrated from expenditure shares, $\ln T_i + \varepsilon \ln B_i$ is recovered as a residual — the standard "invert the model" step used in ARSW. $T_i$ and $B_i$ aren't separable without an extra normalization (e.g. $T_i \equiv 1$, or an independent amenity proxy), but the combination is exactly identified.

---

## 3. The zoning fee — exact, no approximation needed

This is the cleanest result in the set. The land-arbitrage condition is already exactly linear in levels:
$$
q_i^R = q_i^F - t_i^F \quad\Longrightarrow\quad t_i^F \equiv q_i^F - q_i^R.
$$
Given *any* data source with both commercial and residential rents at the tract level (CoStar, county appraisal rolls, commercial listing services), this gives a direct, non-parametric measure of the fee-equivalent zoning wedge at every location — no estimation required, just a subtraction. This is a sharper empirical object than the Baum-Snow–Han elasticity currently used as the zoning proxy in `empirical facts.tex`, since it is implied *exactly* by the model's own equilibrium condition rather than an external elasticity estimate.

---

## 4. Recovering the congestion parameters $(\eta, a, b)$

Given $\hat\phi_i$ (backed out from §2, up to the $T_i/B_i$ normalization), regress:
$$
\ln \hat\phi_i = \ln\eta + a\ln N_i + b \ln L_i + u_i.
$$
This is a clean log-linear regression on population and employment data, recovering $a$ and $b$ directly — with the convexity restriction $a>1$ testable as a hypothesis on the estimated coefficient.

---

## 5. What requires solving a system, and why

The municipal zoning FOC (`zoning-foc-explicit`) involves comparative statics like $\partial N_i/\partial \bar H_i^R$, $\partial q_i^R/\partial \bar H_i^R$. These are **not** a gap in the model's specification — the Fréchet block ($T_i, E_j, \varepsilon$) is fully specified — but they are genuine general-equilibrium objects: $N_i$, $q_i^R$, $w_i$, and $\phi_i$ are jointly determined by a fixed point, because a change in $\bar H_i^R$ moves the common denominator $\Phi = \sum_{i'}\Phi_{i'}$ (market access for *every* location, however slightly) and moves wages through the labor market. This is exactly why ARSW / Redding-Sturm don't report a scalar formula for such comparative statics either — they log-linearize the full system and solve it as a linear ("exact hat algebra") problem.

### 5.1 The full log-linearized system

Write $\hat x \equiv d\ln x$. From $\tilde V_{ij} = B_i(w_j-\phi_i)/(\tau_{ij}(q_i^R)^{1-\alpha})$, using the exact differential
$$
d\ln(w_j-\phi_i) = s_j^w \hat w_j - s_i^\phi \hat\phi_i, \qquad s_j^w \equiv \frac{w_j}{w_j-\phi_i}, \quad s_i^\phi \equiv \frac{\phi_i}{w_j-\phi_i} = s_j^w - 1,
$$
we get
$$
\hat{\tilde V}_{ij} = s_j^w \hat w_j - s_i^\phi \hat\phi_i - (1-\alpha)\hat q_i^R - \rho\, \hat n_{ij} + \gamma\, \hat I_{ij}.
$$

Share and aggregation equations:
$$
\hat\pi_{ij} = \varepsilon \hat{\tilde V}_{ij} - \hat\Phi, \qquad
\hat\Phi_i = \varepsilon \sum_j \pi_{j|i}\, \hat{\tilde V}_{ij}, \qquad
\hat\Phi = \sum_i \frac{N_i}{N}\,\hat\Phi_i, \qquad
\hat N_i = \hat\Phi_i - \hat\Phi,
$$
$$
\hat L_j = \sum_i \pi_{i|j}\, \hat\pi_{ij}, \qquad
\hat w_j = (1-\gamma)\bigl(\hat H_j^F - \hat L_j\bigr), \qquad
\hat\phi_i = a\hat N_i + b\hat L_i \quad (\text{exact, Cobb-Douglas}),
$$
$$
\hat q_i^R = \sum_j \omega_{ij}\Bigl[\hat\pi_{ij} + s_j^w \hat w_j - s_i^\phi \hat\phi_i\Bigr] - \hat{\bar H}_i^R, \qquad
\hat{\bar H}_i^F = -\frac{\bar H_i^R}{\bar H_i^F}\, \hat{\bar H}_i^R \quad (\text{land identity, exact}),
$$
where $\pi_{j|i}$, $\pi_{i|j}$ are conditional choice probabilities and $\omega_{ij}$ is the income-share weight in location $i$'s rent bill.

This is a linear system in $\{\hat N_i, \hat L_i, \hat q_i^R, \hat w_i, \hat\phi_i, \hat\pi_{ij}\}$ across every location, driven by the shock $\hat{\bar H}_i^R$ (or, via `zoning-foc-tax`, $dt_i^F$). Every equation is closed-form and exact to first order; the *solution* for $\hat N_i / \hat{\bar H}_i^R$ requires solving the system jointly, because a zoning change at $i$ moves market access for every other location, however slightly, and moves wages through the labor market.

### 5.2 A genuine closed form: the "small open location" case

If location $i$ is treated as one of many, so its own zoning change does not move the metro-wide $\Phi$ or wages elsewhere ($\hat\Phi \approx 0$, $\hat w_j \approx 0$ for $j\ne i$), the system above collapses from a metro-wide fixed point to a **local** fixed point in just $(\hat N_i, \hat L_i, \hat q_i^R, \hat w_i, \hat\phi_i)$: five equations, five unknowns, solvable by ordinary $5\times 5$ matrix inversion as a function of $(\varepsilon, \alpha, \gamma, a, b)$ and local shares $(\pi_{i|i}, s_i^w, s_i^\phi)$. That is the honest closed form — a small linear system with an explicit algebraic solution, not a single scalar elasticity, but fully tractable by hand or symbolically.

**Not yet done:** explicitly solving the $5\times5$ system for $d\ln N_i/d\ln \bar H_i^R$ in closed form. That's the natural next step if this local approximation is adopted.

---

## Open questions / next steps

1. Solve the reduced $5\times5$ "small open location" system explicitly for $d\ln N_i/d\ln \bar H_i^R$ (and hence $d\ln N_i/dt_i^F$ via `zoning-foc-tax`).
2. Decide whether the full metro-wide system (§5.1) or the small-open-location approximation (§5.2) is the right level of rigor for the proposal — the former is exact but requires numerical solution across all locations; the latter is closed-form but assumes away metro-wide market-access feedback from any single location's zoning.
3. If pursued, write §1–4 (and whichever of §5.1/§5.2 is adopted) into `model.tex` as a formal "Quantification" section.
