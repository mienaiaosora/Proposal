# CLAUDE.md — Second Year Proposal

## Project

**Title:** Local Control and Metropolitan Inefficiency: The Interaction between Zoning and Transportation Investment

**Author:** Ke Jiang | PhD student, Economics | Advisor: WK

**Research question:** How does fragmented local zoning control distort metropolitan transportation investment, and what is the welfare cost of this coordination failure? The central mechanism: municipalities choose zoning to maximize incumbent-resident welfare, suppressing density near high-accessibility locations. The regional transportation authority responds to this constrained spatial pattern, finding transit investment less attractive and road investment relatively more so. The result is a path-dependent car-dependent equilibrium even when coordinated zoning + transit would dominate.

**Why transit is special:** Unlike roads (extensive-margin, benefits diffuse across space), transit is intensive-margin infrastructure: its return depends on the density of residents and jobs *at* station-area locations. Zoning restrictions directly suppress this density, lowering transit ridership and the marginal return to transit investment.

---

## Model Architecture

**Type:** quantitative spatial equilibrium model.

**Key agents:**
- **Municaplity** in each municipality `g`: chooses optimal zoning regulations(both resitential and commercial landuse) to maximize the local incumbents' welfare, in terms of congestion disutility.
- **Households** `ω`: Cobb-Douglas preferences over consumption and housing; idiosyncratic Fréchet taste shocks `υ_{ωij}`; choose residence `i`, workplace `j`.
-  **Firms** At each location j, competitive firms produce a freely tradable good using labor and commercial land, following CoD production function, with A_{j} be location-specific productivity.
- **Transportation authority**: maximizes aggregate household welfare subject to budget constraint `K`.

**Key structure:**
- Genuine network `(S,E)`: transportation investment `I_{kℓ}` is chosen per **edge** `(k,ℓ)∈E`, not per residence-workplace pair. Each OD pair `(i,j)` has an exogenously fixed route `r_{ij}⊆E` (GIS shortest path / observed transit line); commuting cost accumulates multiplicatively over the route: `τ_ij = ∏_{(k,ℓ)∈r_ij} d_{kℓ}(I_{kℓ}, n_{kℓ})`, with edge-level friction `d_{kℓ}=δ^τ_{kℓ} n_{kℓ}^ρ/I_{kℓ}^γ`. Edge traffic `n_{kℓ} = Σ_{(i,j):(k,ℓ)∈r_ij} Nπ_ij`. Endogenous multi-route choice (Allen-Arkolakis style) is a deferred extension, not built.
- Budget constraint `Σ_{(k,ℓ)∈E} δ_{kℓ} I_{kℓ} ≤ K`.
- Household budget: `c_{ij} + h_{ij} q_i ≤ w_j` (revised 2026-07-20 — congestion `φ(N_i,L_i)` moved into the amenity, see Notation Registry `B_i`/`φ` entries).
- Land is owned by absentee landlords who collect all rent and consume it outside the metro; no feedback into household budgets or municipal welfare (added 2026-07-20).

---

## Notation Registry

Do not introduce new symbols for existing concepts. All sessions must use this registry.

| Symbol | Meaning |
|--------|---------|
| `g ∈ G` | Municipality |
| `i, o` | Location (residence origin) |
| `j` | Workplace location |
| `m ∈ {R, T}` | Mode: R = road, T = transit |
| `h_{0,g}` | Zoning capacity chosen at t=0 by municipality g |
| `q_i` | Housing price at location i. Rent (`q_i^R H_i^R + q_i^F H_i^F`) accrues to absentee landlords who consume outside the metro (added 2026-07-20) — no feedback into household budgets or municipal welfare. |
| `w_j` | Wage at workplace j |
| `N_i` | Population at location i |
| `I_{kℓ}` | Transportation investment on network edge (k,ℓ)∈E (edge-level, not per OD pair) |
| `r_{ij}`, `n_{kℓ}` | Exogenous fixed route from i to j (⊆E); edge-level traffic flow aggregating all OD pairs whose route uses that edge |
| `K` | Total transportation budget |
| `d_{ij}(I,N)` | Commuting cost (generic) spatial friction; 
| `φ(N_i,L_i) = η N_i^a L_i^b` | Congestion/density disutility, Cobb-Douglas form: both local residents and local employment cause disutility. `η>0` overall scale; `a,b>0` relative weights; `a>1` needed for own-argument convexity (interior FOC). Generates a complementarity (`∂²φ/∂N_i∂L_i>0`) absent from an additive parametrization. **Revised 2026-07-20 (advisor's July_17th comment):** no longer subtracted from income; enters as a markdown on the amenity, `B_i(N_i,L_i)=B̄_i/φ(N_i,L_i)` — see `B_i` entry below. Functional form and convexity condition unchanged. |

| `ε` | Fréchet shape parameter (idiosyncratic taste shocks) |
| `α` | Cobb-Douglas consumption share |
| `B_i(N_i,L_i) = B̄_i/φ(N_i,L_i)` | Effective residential amenity at `i` (revised 2026-07-20, supersedes plain exogenous `B_i`): exogenous location level `B̄_i`, marked down by the congestion term `φ(N_i,L_i)`. Folding congestion into the amenity rather than income makes the partial `∂Ū_i/∂φ_i` exact and closed-form (`=-Ū_i/φ_i`, vs. a signed-only partial before) and removes the first-order log approximation previously needed in the gravity/quantification equations — the advisor's "more coherent to interpret and easier to calibrate" note. `B̄_i` (not `B_i`) is the object recovered as a residual in calibration, jointly with `T_i`, net of the `(a,b)` congestion terms identified from `N_i,L_i` regressors in the origin fixed effect. |
| `T_i, E_j` | Fréchet scale parameters at residence i and workplace j |
| `t_i^F ≥ 0` (defined via `q_i^R = q_i^F/(1+t_i^F)`) | **Primary municipal instrument, iceberg-cost framing (revised 2026-07-11 per advisor's July_6th comment; supersedes the additive-fee framing).** Regulatory burden — delay, discretionary review, litigation risk, compliance — melts away a fraction of commercial floor space's usable value; the melted portion is definitionally a real resource loss, not rebated, not a budget-constraint object. Land is competitively allocated between residential and commercial use; if both uses are active, competition equalizes effective (post-melt) returns, giving the no-arbitrage condition `q_i^R = q_i^F/(1+t_i^F)` (eq. `eq:arbitrage`). Combined with the land identity and the model's own rent functions `q_i^R(H_i^R)`, `q_i^F(H_i^F)` (each strictly decreasing in own argument), this pins down `H_i^R(t_i^F)` — strictly increasing — via the implicit function theorem (eq. `eq:landsplit`); no developer or supply-side agent, no assumed cost schedule. FOC derived by differentiating wrt `H_i^R` then translating back via chain rule (verified by hand: rescaling factor `[q_i^F/(1+t_i^F)^2]/(-g'(H_i^R)) > 0`, same interior solution as the additive case). `H_i^F` itself can be read as a *quota* (cap on commercial floor space). A symmetric residential-side iceberg cost `t_i^R` defined via `q_i^F = q_i^R/(1+t_i^R)` is an equivalent alternative parametrization, not used as primary. Empirically recovered as `t_i^F = q_i^F/q_i^R - 1` from rent data, no estimation — same Glaeser-Gyourko rent data as before, now read as a proportional rather than dollar gap. |

---

## Open Model Questions

Track which issues from SB's feedback are resolved vs. pending. **Read `comments from SB.md` before editing any model section.**

| # | Issue | Status | Note |
|---|-------|--------|------|
| 1 | Road vs. transit structural distinction | **OPEN** | Need mode-specific `τ_{ijm}` with asymmetric density complementarity. Not yet in model.tex. SB: road = extensive margin, transit = intensive margin. Put this distinction apart first, just consider in general the transportation|
| 2 | Municipal objective ω interpretation | **OPEN** | Must frame as reduced-form political-economy weights, not welfare weights. Discipline via housing supply elasticity calibration. Not yet in model.tex. |
| 3 | Nested-choice relocation friction | DEFERRED | Optional extension. User noted "think about later." |
| 4 | Timing: simultaneous vs. sequential | **RESOLVED** | 
Simultaneously decided, both municipality and transportation investment come in the form of Nash Equilibrium
| 5 | Quantification strategy | RESOLVED (plan) | Match equilibrium objects: commuting flows, mode shares, rents, employment. Data: NTD, LEHD/LODES, ACS, Baum-Snow & Han (2024) elasticity. Do NOT estimate all primitives directly. |
|6| Scale of decision | **OPEN** | There are several mismatch in terms of the scale of the decisions and if they are made by different agent. First, there can be mismatch where local municipality decide the zoning regulations wheras the transportation investment are decided at the metropolitian level. Second, it can be that the two decisions are made at the same level but by two different agent, or representative? refer to zoning_and_transportation_governance_us.md for informations.
| 7 | Municipal instrument: quantity vs. price/quota | **RESOLVED (revised 2026-07-11)** | SB (via `july_1st_comment.md`, 2026-07-01): municipality should not directly control land-supply quantity; think price/quota, subject to data availability. Resolved *without* adding a developer, endogenous supply side, or assumed cost schedule — total land `H̄_i` stays fixed. **Revised 2026-07-11** per the advisor's "July_6th comment" (also in `july_1st_comment.md`): `t_i^F` is not really a tax, it is better read as an **iceberg cost** on commercial land use. `§Municipal Zoning` in model.tex now leads with the no-arbitrage condition `q_i^R = q_i^F/(1+t_i^F)` (multiplicative, was additive `q_i^R = q_i^F - t_i^F`) — regulatory burden melts away a fraction of commercial floor space's usable value rather than adding a price wedge. Monotonicity of `H_i^R(t_i^F)` and the FOC-translation argument re-verified by hand under the new definition (see notation registry entry for `t_i^F`); qualitative comparative statics unchanged. `empirical facts.tex` and `main.tex`'s model subsection were left un-synced pending a separate resync pass.
| 9 | `I_{jk}` / network structure ambiguity | **RESOLVED (2026-07-11)** | Advisor's July_6th comment flagged that `model.tex` used `I_ij` (OD-pair-indexed) in the Environment section but `I_jk` (link-indexed) in the Transportation Authority section, with no actual network topology connecting the two. Read Fajgelbaum, Gaubert, Gorton, Morales & Schaal (2023/24, NBER w31438) and Bordeu (2025, "Commuting Infrastructure in Fragmented Cities") — confirmed the advisor's "lanes as investment" description actually refers to Fajgelbaum & Schaal (2020), already cited in model.tex, not w31438 (which has no continuous per-link investment variable — CHSR's design choice is discrete station placement along an exogenous route). Resolved by defining a genuine network `(S,E)` with edge-level investment `I_kℓ` and an exogenously fixed route `r_ij` per OD pair (GIS shortest path / observed transit line), following Bordeu's edge-level parametrization but without her endogenous multi-route choice (deferred, flagged as future extension in model.tex). |
| 10 | Investment spillovers | **RESOLVED (2026-07-11)** | Advisor's July_6th comment: commuting cost between `j` and `k` was only affected by `I_jk`, not by investment elsewhere on the path. Resolved as a corollary of Item 9's network structure: since `τ_ij = ∏_{(k,ℓ)∈r_ij} d_kℓ`, the transportation authority's FOC (`transit-foc` in model.tex) sums the marginal benefit of edge `(k,ℓ)`'s investment over *every* OD pair whose route uses that edge — spillovers fall out of the route-sum algebra, not an ad hoc added term. Full endogenous-routing spillovers (Allen-Arkolakis matrix-inverse propagation, as in Bordeu) remain a deferred extension.
| 11 | Closed-form solution to municipal zoning problem | **RESOLVED (2026-07-16)** | The FOC (`zoning-foc`/`zoning-foc-explicit`) previously left `∂N_i/∂H̄_i^R` etc. as unspecified GE objects, matching the "natural next step" flagged in §Quantification (line 261 pre-edit). Added the small-open-location approximation (`dlnΦ/dlnH̄_i^R≈0`, i-negligible-relative-to-metro) — a new model assumption, approved via plan before implementation — and derived a log-linear ("hat algebra") elasticity system (`eq:hat-system`, Cramer's-rule solution `eq:elasticities`) that collapses the FOC to a single explicit scalar equation in `φ_i` (`eq:zoning-closed-form`), plus a leading-order closed-form `φ_i^*` (`eq:phi-star-leading`) with an explicit interior-solution condition `b·ẽ_L < a·ε(1-α)/[1+ε(1-α)]` sharpening the existing `a>1` convexity requirement. §Quantification (line ~322) now references this result instead of describing it as unresolved. Full derivation lives in `§Municipal Zoning` in model.tex, after the "Translating back to the iceberg cost" paragraph.
---
| 8 | Zoning restriction: trade-off btw residential and commerical|**Open**| The way the municipal set zoning in the model is merely choosing between residential and commerical, wheras the total housing supply is fixed and fully utilized, for now the less residential use equals to more commerical land use, but in reality is not the case, with so many unutilized land.
| 12 | Congestion disutility placement (`φ` into `B_i`) | **RESOLVED (2026-07-20)** | Advisor's July_17th comment (`july_1st_comment.md`): putting `φ(N,L)` into `B_i` is "more coherent to interpret and potentially easier to calibrate." Rederived: `B_i(N_i,L_i)=B̄_i/φ(N_i,L_i)` replaces the income-side `w_j-φ(N_i,L_i)`; budget is now `Q_ij+q_i^Rh_ij^R≤w_j`. Makes `∂Ū_i/∂φ_i=-Ū_i/φ_i` and `∂Ū_i/∂w_i=π_{ii\|i}Ū_i/w_i` exact (no approximation), and removes the first-order log approximation from the commented Quantification gravity equation — `(a,b)` now identified directly from `N_i,L_i` regressors in the origin FE. §Households, §Municipal Zoning (Channels paragraph, `zoning-foc-explicit`), and the commented Quantification block in `model.tex` updated; see `B_i`/`φ` entries in the Notation Registry. |
| 13 | Landlord / land-rent destination | **RESOLVED (2026-07-20)** | Advisor's July_17th comment asked where land rent goes. Resolved with an absentee-landlord assumption: landlords collect `q_i^RH_i^R+q_i^FH_i^F` and consume it outside the metro, no feedback into household budgets or municipal welfare. Stated in §Environment, `model.tex`. The alternative (rebate to local residents) is left for the land-supplier extension the advisor flagged as a later step. |
| 14 | Bordeu (2025/26) land-value vs. `Ū` equivalence | **RESOLVED (2026-07-20, noted contrast, no model change)** | Advisor's July_17th comment: Bordeu models the local government's objective as maximizing land value, sometimes equivalent to maximizing `Ū`; be aware of this. Under this paper's absentee-landlord assumption (item 13), the equivalence does *not* hold — it requires residents to also be the landowners capturing their own parcel's rent. Documented as a footnote in §Municipal Zoning, `model.tex`, citing `Bordeu2026-df`. |
| 15 | Why zoning favors transportation investment (job access, agglomeration) | **RESOLVED (conceptual, no new model object)** | Advisor's July_17th comment listed two channels: better job access, productivity agglomeration. Both are already the mechanism behind `transit-foc` in `model.tex` — denser `N_i,L_i` raises `Ṽ_ij` (via the amenity/wage channels) and hence the marginal social benefit of edge investment summed over routed OD pairs. No separate model object needed. |
| 16 | Endogenize total budget `K` | DEFERRED | Advisor's July_17th comment flags `K` as a candidate for endogenizing in a future extension. Same status class as item 3 (nested-choice relocation friction) — not built. |

**Counterfactual framing (relates to item 6, scale of decision):** advisor's July_17th comment frames the counterfactual as two things changing at once — (1) the scale at which the decision is made, (2) the identity of the deciding agent (two agents → one). No model change; keep in mind when designing the counterfactual exercise in item 6.

**Next steps (advisor's July_17th comment, logged not actioned):** (1) fully characterize the equilibrium and solve the optimal policy problem; (2) revisit the data plan — after the equilibrium is characterized, decide which parameters need calibration/validation vs. which can be borrowed from existing papers.

## File Map

| File | Role |
|------|------|
| `main.tex` / `main.pdf` | Full proposal: intro, lit review, model, empirics, conclusion |
| `model.tex` / `model.pdf` | Standalone model document — primary development sandbox |
| `two-period-model.md` |Abolished|
| `comments from SB.md` | cohort feedback — **read before any model-section edit** |
| `motivation_draft.md` | Motivation section draft |
| `reference.bib` | BibLaTeX bibliography |
| `main_original.tex` | Snapshot before major revisions (do not edit) |
| `templates/model-section.tex` | Template for new model sections |
| `templates/proposition.tex` | Template for propositions and proofs |
|`zoning_and_transportation_governance_us.md`| informations about how the zoning regulations and transportation investment are decided in the context of United States|
---
|`july_1st_comment.md`|Advisor feedback — **read before any model-section edit** |
## Workflow Rules

**Plan-first:** All non-trivial tasks require an approved plan before implementation. "Trivial" = single-line fix, lookup, or rename.

**Contractor mode:** After plan approval, execute autonomously. Return to user only on genuine ambiguity, a decision requiring user judgment, or a blocker. Do not narrate progress unless something goes wrong.

**First sessions:** Check in slightly more often until the user signals the workflow is calibrated.

**Never change model assumptions or notation** without explicit user approval in a plan. If a model change is needed mid-task, surface it as a checkpoint, not a done deal.

**Commits:** Commit autonomously after each coherent unit of work. Descriptive messages, one per logical unit. User monitors via `git log`. Use `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`.

**Advisor feedback:** Before editing any section of model.tex or main.tex's model section, read `comments from SB.md` `july_1st_comment.md` and update the Open Model Questions table above if relevant.

---

## Quality Standards

**LaTeX:**
- All documents must compile cleanly: zero errors, no overfull hboxes in final output.
- Compile sequence: `latexmk -pdf -biber <file>` (handles pdflatex → biber → pdflatex × 2 automatically).
- Use `align` for multi-line equations; number only equations that are later referenced.
- Use `\text{}` for non-italic text inside math mode.
- Theorems/propositions/lemmas: use `amsthm` environments consistently (see `templates/proposition.tex`).
- Bibliography: `biblatex` + `biber` backend (declared in preamble). Never mix with `natbib` or plain `bibtex`.

**Figures:**
- Publication-ready always: proper axis labels, no inline titles (use captions in LaTeX), font sizes consistent with document body (10–11pt).
- Prefer vector formats: PDF output from TikZ/pgfplots, or PDF/EPS exports from external tools.
- No visual clutter: remove chartjunk, gridlines only if needed, minimal color palette.

---

## LaTeX Environment Setup

The project uses a standard TeX Live installation. Compile from the project root:

```bash
latexmk -pdf -interaction=nonstopmode model.tex      # standalone model
latexmk -pdf -interaction=nonstopmode main.tex       # full proposal
```

Note: `-biber` is not a valid latexmk CLI flag. Biber is invoked automatically when biblatex declares `backend=biber` in the preamble.

Custom commands available in Claude Code:
- `/compile` — compile a LaTeX file and report errors
- `/advisor-checklist` — audit model against SB's open feedback items
