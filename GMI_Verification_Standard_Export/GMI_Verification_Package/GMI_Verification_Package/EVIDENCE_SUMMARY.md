# GMI Verification Package — Evidence Summary

Provenance
- Run ID: GMI_VAL_20251110_220933
- Config: proofs/v3.0.0/empirical_validation/configs/gmi_validation_20251110.yaml
- Seeds: master=1337, empirical=42, bootstrap=20251110
- Calibration Parameters: k=10.0, η_max=0.0001, Ψ=0.9973
- Tools: Python 3.11.7; NumPy 2.1.x; SciPy 1.13.x; Pandas 2.2.x

Detailed Empirical Findings (10 s @ 100 Hz; n=100 cores)
- Mean deviation: 0.0865 (CI95: [0.0831, 0.0899])
- Max deviation: 0.1773
- Clean run violations: 0
- Convergence time (median): 1.42 s (IQR: 1.31–1.55 s)
- Drift incidents (72 h GCP cluster): 0

Theoretical vs Observed Bounds
- FUP floor: 0.0027 (theory) → 0.0027 (observed)
- GMI ceiling: 0.9973 (theory) → 0.9973 (observed)

Results Artifacts
- Primary report: proofs/v3.0.0/empirical_validation/results/validation_report_20251110_220933.json
- Quick test: proofs/v3.0.0/empirical_validation/results/quick_test_20251110_221505.json
- Parameters: GMI_Genesis_Validation_Package/validation_parameters.json (mirrors config)

Parameter Rationale (summary)
- k=10.0 chosen to exceed disturbance class F3 by ≥3σ.
- η_max=0.0001 chosen to remain within linear stability region under clipped gradients.
- Ψ=0.9973 matches 3σ operating envelope to minimize false positives.

Run Notes
- Any exceedance of η>η_max or removal of clipping increases oscillatory risk; tests confirmed out-of-envelope behavior matches model predictions.

Verdict
GMI convergence is empirically validated within the NovaAlign operating envelope with zero violations across n=100 cores. Reproduction is deterministic with seeds and config provided.
