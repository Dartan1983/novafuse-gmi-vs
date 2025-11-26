# External Compliance and Runtime Integrity

## SLSA Provenance (Supply Chain Integrity)

This repository integrates SLSA v3 provenance generation via GitHub Actions to attest the build process.

- Workflow: `.github/workflows/verify.yml`
- What it does:
  - Runs the full GMI verification cycle.
  - Bundles the certificate and artifacts into `gmi-verification-bundle.zip`.
  - Generates SLSA v3 provenance using the official `slsa-github-generator`.
- Triggers: manual (`workflow_dispatch`) and tags (`v*.*.*`).
- Permissions: includes `id-token: write` to enable OIDC signing.
- Outputs: `gmi-verification-bundle.zip` and `*.intoto.jsonl` provenance files uploaded as workflow artifacts.

## Runtime Barrier Guard (Failsafe Closure)

The `runtime/barrier_guard.ps1` script enforces the runtime invariant `∂Ψ=0` by continuously monitoring:

- `alpha_min_observed`
- `timing_jitter_ms_p95`
- `timing_jitter_ms_p99`
- `perturbation_norm`

On repeated violations, the guard trips a failsafe by stopping a Windows service or running a custom shutdown command.

Example:

```
powershell -File runtime/barrier_guard.ps1 \
  -MetricsUrl "http://localhost:8080/metrics.json" \
  -CheckIntervalSec 15 \
  -MinAlpha 0.1 \
  -MaxJitterP95Ms 50 \
  -MaxJitterP99Ms 100 \
  -MaxPerturbationNorm 1.0 \
  -ConsecutiveViolationsToTrip 3 \
  -ServiceName "NovaFuseService"
```

## Validation Process

Issuance is blocked unless validation succeeds:

- Local checks in `verify.ps1` compute `robustness_margin` and enforce structural sanity.
- Strict JSON Schema validation is performed by `GMI_Verification_Standard_Export/GMI_Verification_Package/schemas/validate-certificate.ps1` using Python `jsonschema`.
- Cross-format agreement can be demonstrated with `GMI_Verification_Standard_Export/GMI_Verification_Package/scripts/consistency_check.py`.

## Export Control Notice

This software is not intended for use in embargoed nations or by prohibited entities. Compliance with U.S. export laws (including EAR and OFAC) remains the responsibility of the user.

## Chain‑of‑Custody and Auditability

Each verification certificate includes a SHA‑256 digest of source artifacts to ensure end‑to‑end reproducibility and tamper‑evident auditability.

## Security Model and Write Boundaries

All PowerShell scripts are validated for path traversal protections and restricted to canonical repository paths. All write‑operations are confined to repository directories; no writes occur outside canonical paths. Verification operations do not require Administrator privileges.
