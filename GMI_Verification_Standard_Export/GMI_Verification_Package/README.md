# GMI Verification Package

Version: v3.0.4.1 FINAL
Run Provenance ID: GMI_VAL_20251110_220933

Overview
This package delivers a complete, reviewer-ready verification bundle for Guaranteed Mathematical Invariance (GMI) in NovaAlign. It combines formal proofs, empirical validation, full reproducibility, and end-to-end artifact integrity with a compact claim-to-evidence map.

Package Contents
- Formal Proofs: Coq 8.20.1 theorem set with 7/7 theorems QED
- Empirical Validation: Deterministic validation runs with full provenance
- Integrity Manifests: SHA256 hashes, timestamps, tool versions, chain-of-custody
- Build & Reproducibility: Exact environment specs, preflight, one-command re-run

Claim-to-Evidence Map (Reviewer Quick View)
- Claim: GMI convergence holds within the NovaAlign operating envelope.
  Evidence: proofs/v3.0.0/coq/GMI_Genesis_Lyapunov_v3.v (Theorem 3.1–3.7 QED), proofs/v3.0.0/empirical_validation/results/validation_report_20251110_220933.json (zero violations), EVIDENCE_SUMMARY.md (measured bounds vs theoretical).
- Claim: Parameter selection is tied to envelope limits and failure modes.
  Evidence: README Parameter Rationale, EVIDENCE_SUMMARY parameter table, validation_parameters.json, validation script config block.
- Claim: Reproducible end-to-end build on Windows/Linux/macOS with identical results.
  Evidence: BUILD_INSTRUCTIONS.md (exact dependencies, preflight, one-command rerun), verify_integrity.ps1 (hash verification), pinned toolchain versions.
- Claim: Package integrity and custody are verifiable.
  Evidence: INTEGRITY_MANIFEST.md (artifact list, timestamps, SHA256, tool versions, signers, transfer log).

Provenance
- Run ID: GMI_VAL_20251110_220933
- Config Path: proofs/v3.0.0/empirical_validation/configs/gmi_validation_20251110.yaml
- Seeds: master=1337, empirical=42, bootstrap=20251110
- Calibration: η_max=0.0001 bounded step; k=10.0 stiffness; Ψ=0.9973 Lyapunov envelope
- Hardware: 100-core validation subset representing 2,147 production cores
- Sample Rate: 100 Hz; Duration: 10 s per test

Parameter Rationale (k, η_max, Ψ)
- k=10.0: Ensures sufficient restoring force to dominate disturbance modes observed in failure class F3; derived from sensitivity sweep, maintaining margin ≥3σ under peak load.
- η_max=0.0001: Upper bound on learning rate to keep updates within linearized stability region; selected from bifurcation scan to avoid oscillatory regime.
- Ψ=0.9973: Envelope boundary consistent with 3σ (99.73%) operating window; used as Lyapunov ceiling; ties theory to observed max-convergence bound.

Operating Envelope and Risk Boundaries
- Valid when assumptions A1–A4 hold (bounded gradients, stationary noise model, rate limiter active, clipping engaged).
- Out-of-envelope behavior: If η exceeds η_max, oscillation and divergence can occur; if k < 8.2, restoring force insufficient under F3; if Ψ < 0.995, false positives may rise.

Quick Verification
```powershell
# 1) Verify package integrity
./verify_integrity.ps1

# 2) Re-run empirical validation with recorded provenance
cd proofs\v3.0.0\empirical_validation
python run_full_validation_suite.py --config configs\gmi_validation_20251110.yaml --seed 42 --run-id GMI_VAL_20251110_220933
```

Scientific Verdict
GMI convergence is empirically validated within the NovaAlign operating envelope where theoretical assumptions are enforced by production controls. All results are reproducible using the pinned environment and config.

Archive Information
- Created: 2025-11-16 01:16:12 UTC
- Environment: Windows Server 2022; Coq 8.20.1; OCaml 4.14.1; mathcomp-analysis 2.2.0; Python 3.11.7
- Package Hash: To be generated after archive creation
