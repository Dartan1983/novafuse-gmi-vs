# GMI Genesis Verification Checklist

Purpose: Reproduce failing scenarios with corrected parameters, collect diagnostics, and confirm pass criteria.

## Preconditions
- Harness loads `GMI_Verification_Package/config/verification.profile.json`.
- Artifacts directory exists: `GMI_Verification_Package/artifacts/`.
- Verbosity set to `max`; fixed seed `42`.

## Run Instructions
1. Configure harness to use `verification.profile.json`.
2. Enable trace mode and fixed seed from profile.
3. Execute the full adversarial test suite.
4. Confirm artifacts are emitted:
   - `V_trace.csv`
   - `Node_logs/`
   - `Scheduler_stats.json`
   - `Byzantine_map.json`
   - JSON/CSV/HTML test reports

## Immediate Checks (Numerical Invariants)
- Lyapunov descent:
  - Compute `ΔV_k = V_{k+1} - V_k`; verify `ΔV_k < 0` except within numerical tolerance.
  - Verify margin condition `dV/dt <= -c · ||x||^2` holds; `c` derived from `min_eig(WK)` as per profile.
- Invariant projection:
  - Confirm componentwise projection onto `[0, GMI_ceiling]` at each step.
- Coupling matrix `L`:
  - Symmetry (`L == L^T`) and row-sum-zero to numerical tolerance.

## Robustness & Byzantine Checks
- Perturbation filters:
  - LPF enabled; cutoff set per step (`relative_cutoff_per_step`).
  - Median filter window = 3; spikes reduced.
- Noise envelope:
  - `noise_max <= 0.05`; `stability_margin_sigma = 3`.
- Aggregation and quorum:
  - Aggregator `trimmed_mean` active with `trim_ratio = 0.2`.
  - Quorum threshold uses `2f+1`; validate `n` and `f` mapping in `Byzantine_map.json`.
- Outlier handling:
  - z-score cap = 3.0 and winsorization enabled.

## Timing & Scheduler Checks
- Monotonic clock enabled; jitter buffer = 10 ms.
- Compute latency CV from `Scheduler_stats.json`: `CV = stddev/mean`.
- Target: `CV <= 0.05` (acceptable: 0.05–0.10 during tuning).

## Pass Criteria
- Previously failing tests (`Convergence Disruption`, `Lyapunov Destabilization`, `Perturbation Robustness`, `Byzantine Fault Tolerance`, `Timing Attack Resistance`) pass.
- Lyapunov and invariants checks hold across traces.
- Aggregator/quorum logic matches the `n, f` scenario.
- Timing CV within target range.

## Artifacts to Save
- `V_trace.csv` with time, `V`, max error per-component, coupling energy.
- `Node_logs/` per-node outputs and receive timestamps.
- `Byzantine_map.json` mapping steps to Byzantine nodes.
- `Scheduler_stats.json` (latencies, jitter, CV).
- Updated test reports (JSON/CSV/HTML).

## Run Log — 2025-11-22
- Command: `node scripts/test/adversarial_suite.js --out GMI_Verification_Package/artifacts/adversarial_test_20251121-180120 --formats json,html,csv`.
- Produced artifacts:
  - `adversarial_test_20251121-180120_2025-11-22T00-53-15-179Z.json`
  - `adversarial_test_20251121-180120_2025-11-22T00-53-15-179Z.csv`
  - `adversarial_test_20251121-180120_2025-11-22T00-53-15-179Z.html`.
- Summary: `Total=8`, `Passed=3`, `Failed=5`, `PassRate=37.5%`.
- Failures: Convergence Disruption, Lyapunov Destabilization, Perturbation Robustness, Byzantine Fault Tolerance, Timing Attack Resistance.
- Next: align harness to `verification.profile.json` (aggregator/quorum, noise filters, jitter controls) and re-run.

### Iteration Logs
- Command: `node scripts/test/adversarial_suite.js --out GMI_Verification_Package/artifacts/adversarial_test_20251122-lyapfix --formats json,html,csv` → PassRate 62.5%.
- Command: `node scripts/test/adversarial_suite.js --out GMI_Verification_Package/artifacts/adversarial_test_20251122-lyapfix-tune6 --formats json,html,csv` → PassRate 75.0%.
- Command: `node scripts/test/adversarial_suite.js --out GMI_Verification_Package/artifacts/adversarial_test_20251122-lyapfix-tune9 --formats json,html,csv` → PassRate 87.5% (Timing green via jitter buffer).
- Command: `node scripts/test/adversarial_suite.js --out GMI_Verification_Package/artifacts/adversarial_test_20251122-lyapfix-tune10 --formats json,html,csv` → 7/8 passed (Convergence pending).
- Command: `node scripts/test/adversarial_suite.js --out GMI_Verification_Package/artifacts/adversarial_test_20251122-lyapfix-tune13 --formats json,html,csv` → 8/8 passed (100% pass rate; Convergence fixed via substeps + line search).
