# Regulatory Technical Specification (RTS) — NovaFuse GMI Compliance

RTS ID: RTS-GMI-2025-11-22-TUNE13
Date: 2025-11-22

## 1. Purpose
Defines technical requirements, test procedures, evidence artifacts, and change controls necessary to maintain GMI-compliant classification.

## 2. System Constraints (Hard Invariants)
- Boundary: `∂Ψ = 0` enforced; zero-flux boundaries; projection `[0, GMI_ceiling]` each step.
- Lyapunov: `V̇ <= -margin` at initialization; monotonic descent enforced via integration safeguards.
- Timing: monotonic clock; jitter buffer; latency CV `≤ max_timing_cv`.
- Byzantine: quorum `2f+1`; trimmed mean aggregation; authentication enabled.

## 3. Configuration Profile (Authoritative)
- Source: `config/tuning.json`.
- lyapunov: `K_v=20.0`, `u_max=20.0`, `enforce_Vdot_ineq=true`, `Vdot_margin=1e-4`.
- integration: `alpha=1.5`, `beta_damping=0.20`, `K_couple=4.0`, `projection_on_step=true`, `line_search_max_tries=4`, `substeps=5`.
- robustness: `median_window=3`, `lpf_relative_cutoff=0.2`, `zscore_cap_sigma=3.0`.
- byzantine: `aggregator=trimmed_mean`, `trim_ratio=0.2`, `quorum_rule=2f+1`, `auth_enabled=true`.
- timing: `use_monotonic=true`, `jitter_buffer_ms=10`, `max_timing_cv=0.05`.

## 4. Test Procedures
- Harness: `scripts/test/adversarial_suite.js`.
- Required scenarios: boundary containment; flux attack; convergence disruption; Lyapunov destabilization; perturbation robustness; Byzantine fault tolerance; timing attack resistance; FUP bypass.
- Execution: fixed seed, max verbosity; artifacts MUST be exported JSON/CSV/HTML to `GMI_Verification_Package/artifacts/`.
- Pass condition: 8/8 scenarios pass.

## 5. Evidence Artifacts & Retention
- Reports: JSON/CSV/HTML pass/fail breakdown.
- Diagnostics: `V_trace.csv`, `Byzantine_map.json`, `Scheduler_stats.json`, `Node_logs/`.
- Retention: minimum 2 years or per regulator directive; include hashes and signature metadata.

## 6. Change Management & Recertification
- Material change (any change to `lyapunov`, `integration`, `robustness`, `byzantine`, `timing`) triggers mandatory re-run and re-cert issuance.
- Versioning: increment Certificate and RTS IDs; update Binder and Checklist.
- Audit trail: commit refs, artifact IDs, and run commands logged in Checklist.

## 7. Compliance Statement
- With `adversarial_test_20251122-lyapfix-tune13`, the system meets GMI under RTS conditions.
- Ongoing compliance requires adherence to sections 2–6 and evidence retention.

