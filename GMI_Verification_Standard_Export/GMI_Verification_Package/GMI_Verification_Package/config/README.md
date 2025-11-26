# GMI Verification Config Profiles

This directory contains JSON profiles for tuning the GMI Genesis verification harness.

Files:
- `verification.profile.json` — parameters for convergence, Lyapunov enforcement, perturbation robustness, Byzantine aggregation, and timing hardening, plus diagnostic outputs.

Usage guidance:
- The harness should load `verification.profile.json` and map keys into its parameter sets.
- `convergence.invariant_projection.bound_key` refers to a named ceiling bound (e.g., `GMI_ceiling`) defined by the harness.
- `lyapunov.c_source` communicates that the design margin `c` should be derived from `min_eig(WK)`. Ensure `W` and `K` are defined in your simulator.
- Timing variance target is specified as `latency_target_cv` (coefficient of variation = std/mean).
- Diagnostics paths point to `GMI_Verification_Package/artifacts/`. Ensure the harness writes the additional traces.

