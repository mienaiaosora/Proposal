# CLAUDE.md — Second Year Proposal

## Project

**Title:** Local Control and Metropolitan Inefficiency: The Interaction between Zoning and Transportation Investment

**Author:** Ke Jiang | PhD student, Economics | Advisor: SB

**Research question:** How does fragmented local zoning control distort metropolitan transportation investment, and what is the welfare cost of this coordination failure? The central mechanism: municipalities choose zoning to maximize incumbent-resident welfare, suppressing density near high-accessibility locations. The regional transportation authority responds to this constrained spatial pattern, finding transit investment less attractive and road investment relatively more so. The result is a path-dependent car-dependent equilibrium even when coordinated zoning + transit would dominate.

**Why transit is special:** Unlike roads (extensive-margin, benefits diffuse across space), transit is intensive-margin infrastructure: its return depends on the density of residents and jobs *at* station-area locations. Zoning restrictions directly suppress this density, lowering transit ridership and the marginal return to transit investment.

---

## Model Architecture

**Type:** Two-period quantitative spatial equilibrium model.

**Timing (sequential — this is the resolved baseline):**
1. t=0: Municipalities simultaneously and independently choose zoning capacity `h_{0,g}` (atomistic — each takes others' zoning and the transport investment as given).
2. t=0: Transportation authority observes the full zoning vector and chooses network investment `I_{jk}`.
3. t=1: Households solve location/commuting problem; housing markets clear; prices `q_i` and populations `N_i` are determined.

**Key agents:**
- **Representative landowner** in each municipality `g`: chooses `h_{0,g}` to maximize period-1 utility net of construction cost `λ`.
- **Households** `ω`: Cobb-Douglas preferences over consumption and housing; idiosyncratic Fréchet taste shocks `υ_{ωij}`; choose residence `i`, workplace `j`, and commute mode.
- **Transportation authority**: maximizes aggregate household welfare subject to budget constraint `K`.

**Key structure:**
- Spatial friction `D_{oij}(I,N) = ε_{oij} exp(ρ m_{oi} + κ τ_{ij}(I,N))`.
- Budget constraint `Σ_{j,k} δ_{jk} I_{jk} ≤ K`.
- Household budget: `c_{ij} + h_{ij} q_i ≤ w_j - φ(N_i, h_{0,i}) + h_{0,o} q_o`.

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
| `q_i` | Housing price at location i |
| `w_j` | Wage at workplace j |
| `N_i` | Population at location i |
| `I_{jk}` | Transportation investment on link j→k |
| `K` | Total transportation budget |
| `τ_{ij}(I,N)` | Commuting cost (generic); use `τ_{ijm}` for mode-specific |
| `τ_{ijR}` | Road commuting cost: `d_{ijR} / s_R(I^R, n_R)` |
| `τ_{ijT}` | Transit cost: `φ_i^T(I^T) + t_{ijT}(I^T) + φ_j^T(I^T)` |
| `D_{oij}` | Spatial friction term |
| `φ(N_i, h_{0,i})` | Congestion/density disutility: increasing in N_i, decreasing in h_{0,i} |
| `λ` | Construction/zoning cost parameter |
| `ω_1, ω_2, ω_3` | Municipal political weights (see below) |
| `ε` | Fréchet shape parameter (idiosyncratic taste shocks) |
| `α` | Cobb-Douglas consumption share |
| `B_i` | Location amenity |
| `T_i, E_j` | Fréchet scale parameters at residence i and workplace j |

---

## Open Model Questions

Track which issues from SB's feedback are resolved vs. pending. **Read `comments from SB.md` before editing any model section.**

| # | Issue | Status | Note |
|---|-------|--------|------|
| 1 | Road vs. transit structural distinction | **OPEN** | Need mode-specific `τ_{ijm}` with asymmetric density complementarity. Not yet in model.tex. SB: road = extensive margin, transit = intensive margin. |
| 2 | Municipal objective ω interpretation | **OPEN** | Must frame as reduced-form political-economy weights, not welfare weights. Discipline via housing supply elasticity calibration. Not yet in model.tex. |
| 3 | Nested-choice relocation friction | DEFERRED | Optional extension. User noted "think about later." |
| 4 | Timing: simultaneous vs. sequential | **RESOLVED** | Sequential: zoning first, transport responds. Municipalities atomistic (don't internalize effect on I). Robustness: also compare simultaneous Nash and full planner. |
| 5 | Quantification strategy | RESOLVED (plan) | Match equilibrium objects: commuting flows, mode shares, rents, employment. Data: NTD, LEHD/LODES, ACS, Baum-Snow & Han (2024) elasticity. Do NOT estimate all primitives directly. |

---

## File Map

| File | Role |
|------|------|
| `main.tex` / `main.pdf` | Full proposal: intro, lit review, model, empirics, conclusion |
| `model.tex` / `model.pdf` | Standalone model document — primary development sandbox |
| `two-period-model.md` | Informal model notes — living document, tracks evolving ideas |
| `comments from SB.md` | Advisor feedback — **read before any model-section edit** |
| `motivation_draft.md` | Motivation section draft |
| `reference.bib` | BibLaTeX bibliography |
| `main_original.tex` | Snapshot before major revisions (do not edit) |
| `templates/model-section.tex` | Template for new model sections |
| `templates/proposition.tex` | Template for propositions and proofs |

---

## Workflow Rules

**Plan-first:** All non-trivial tasks require an approved plan before implementation. "Trivial" = single-line fix, lookup, or rename.

**Contractor mode:** After plan approval, execute autonomously. Return to user only on genuine ambiguity, a decision requiring user judgment, or a blocker. Do not narrate progress unless something goes wrong.

**First sessions:** Check in slightly more often until the user signals the workflow is calibrated.

**Never change model assumptions or notation** without explicit user approval in a plan. If a model change is needed mid-task, surface it as a checkpoint, not a done deal.

**Commits:** Commit autonomously after each coherent unit of work. Descriptive messages, one per logical unit. User monitors via `git log`. Use `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`.

**Advisor feedback:** Before editing any section of model.tex or main.tex's model section, read `comments from SB.md` and update the Open Model Questions table above if relevant.

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
