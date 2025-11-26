# NovaFuse GMI Actuarial Risk Model — Underwriting & Pricing

Date: 2025-11-22
Reference Run: `adversarial_test_20251122-lyapfix-tune13` (8/8 pass)

## 1. Risk Class Definition
- Hazard: AI system misalignment leading to boundary breaches, runaway optimization, or catastrophic behavior.
- Control Class: GMI-enforced systems with `∂Ψ = 0`, Lyapunov descent, invariant projection, Byzantine aggregation, timing hardening.
- Evidence Basis: Deterministic invariants; adversarial harness; machine-checkable proofs; reproducible artifacts.

## 2. Frequency-Severity Framework
- Frequency (λ): Modeled as Poisson with control-dependent rate `λ = λ_0 · (1 - R_C)`.
  - `λ_0`: baseline incident rate absent controls.
  - `R_C`: control effectiveness factor derived from pass rate and margins.
  - With 100% pass rate across 8 adversarial categories, set `R_C ∈ [0.85, 0.95]` pending margin audits.
- Severity (S): Lognormal with upper cap enforced by invariant projection and clamps.
  - Cap basis: projection `[0, GMI_ceiling]`, actuator clamp `u_max`, bounded coupling/damping.
  - Tail dampening reflected via Lyapunov monotonicity and timing CV limits.

## 3. Control Effectiveness Scoring (CES)
- Components:
  - `CES_L`: Lyapunov descent strength (K_v, margin, monotonic traces).
  - `CES_B`: Byzantine resilience (aggregator, quorum `2f+1`, auth).
  - `CES_T`: Timing stability (jitter buffer, CV ≤ 0.05).
  - `CES_R`: Robustness filtering (median, LPF, z-score cap).
  - `CES_I`: Invariant enforcement (projection and boundary zero-flux).
- Rollup: `R_C = 1 - Π (1 - CES_i · w_i)`, weights `w_i` calibrated by class.

## 4. Rating Algorithm
- Exposure base: `N_models`, `N_deployments`, `Σ active_users`, `Σ processed_events`.
- Base rate: `BR = BR_0 · RiskClassMultiplier`.
- Risk modifiers:
  - Frequency: `F = exp(α_F · λ)`.
  - Severity: `G = exp(α_S · E[S])` with cap reductions.
  - Controls: `C = (1 - R_C)`.
- Premium indication: `P = BR · Exposure · F · G · C · L`, where `L` includes loadings (expense, profit, reinsurance, cat buffer).

## 5. Suggested Parameters (Initial)
- `R_C = 0.90` (with full 8/8 pass and documented margins).
- `α_F = 0.3`, `α_S = 0.2` pending empirical calibration.
- Cat buffer `L_cat = 1.10` for enterprise classes; `0.05` timing CV tolerance.
- Reinsurance: quota-share 30% + per-occ excess attach at `PML_95`.

## 6. Class Stratification
- Class A (Enterprise-critical): higher exposure; stricter audits; quarterly recert; `R_C_floor ≥ 0.85`.
- Class B (Consumer-scale): semi-annual recert; `R_C_floor ≥ 0.80`.
- Class C (Experimental): limited limits; sandbox; `R_C_floor ≥ 0.75`.

## 7. Certification Dependencies
- Profile integrity: changes to `config/tuning.json` trigger re-rating.
- Evidence retention: binder, checklist, artifacts stored with hashes.
- CI replay: pass must be reproducible under fixed seed with identical harness.

## 8. Pricing Example (Illustrative)
- Inputs: `Exposure=1,000,000 active users`, `BR_0=0.50`, `RiskClassMultiplier=1.2`, `R_C=0.90`.
- Assume `λ=0.02`, `E[S]=$1,000`.
- `F = exp(0.3 · 0.02) ≈ 1.006`, `G = exp(0.2 · 1000)` normalized with cap → use scaled severity index `0.001` → `G ≈ exp(0.2 · 0.001) ≈ 1.0002`.
- `C = 0.10`; `L = 1.20`.
- `P ≈ 0.50 · 1.2 · 1,000,000 · 1.006 · 1.0002 · 0.10 · 1.20 ≈ $72,432` annual.

## 9. Governance
- Actuarial review: quarterly parameter validation.
- Audit: cross-check CES components against current profile and artifacts.
- Documentation: update binder and RTS upon changes; reissue certificate IDs.

