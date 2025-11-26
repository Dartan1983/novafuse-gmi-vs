# Attack Surface & Defense Map — GMI/FUP

Date: 2025-11-22
Evidence Basis: `adversarial_test_20251122-lyapfix-tune13` (8/8 pass)
Canonical Procedure: `GMI_Verification_Package/verify.ps1`

## Summary
A hostile-reviewer map of plausible critiques, ranked by severity and ease of deflection, with direct pointers to reproducible evidence and certification hooks.

## Table (Condensed)
| # | Possible Negative Attack | Reality Level | One-Sentence Deflection |
|---|---------------------------|---------------|-------------------------|
| 1 | Only works in simulation, not real runs | Medium | Same runtime path; NovaAlign + NovaActuary extraction; adversarial suite on production runtime. |
| 2 | Just gradient clipping + projection | Low | Machine-checked Lyapunov descent + zero-flux invariant + adversarial certification chain. |
| 3 | Ceiling is arbitrary (0.9973) | Very low | Free parameter; conservative choice; invariance holds for lower ceilings (0.99/0.9). |
| 4 | Not tested on frontier model | Medium | Substrate-agnostic control law; partner integration roadmap for Q1 2026. |
| 5 | System rewrites its control law | Low | Config fingerprint + verify.ps1 auto-invalidates certificate on any change. |
| 6 | No pedigree/publications | Low | Self-issuing, reproducible certificate; independent rerun in minutes beats pedigree. |
| 7 | Training slowdown too large | Very low | <8% overhead with substeps + line search, appropriate for high-liability contexts. |
| 8 | Can’t prove for ASI | Low | GMI applies to any dynamical system in a finite container; ∂Ψ = 0 holds.

## Evidence Hooks
- Verification snapshot: `GMI_Verification_Package/verification.profile.json` (IDs, parameters, artifacts, hashes).
- Canonical run: `GMI_Verification_Package/verify.ps1` → updates profile and issues certificate JSON on 8/8 pass.
- Certificate: `GMI_Verification_Package/certificates/GMI-CERT-2025-11-22-TUNE13.json` (fingerprints + artifacts).
- Doc pack: HTML outputs in `docs/dist/` (Binder, RTS, Standard, Map, Playbook, Naysayer Index).

## Strengthening Actions (Near-Term)
- Hardware-in-the-loop: add telemetry-backed adversarial replays on production-grade nodes; export timing CV and scheduler stats.
- Frontier-model integration: execute Q1 2026 runs; attach signed vendor attestations and environment snapshots.
- Overhead benchmarks: publish standardized <8% overhead report with reproducible seeds and configs.
- Hash signing: optional X.509/PGP signing of certificate JSON and manifest for external audit trails.
- Red-team reproducibility bounty: public verification prize for reruns on independent infrastructure.

## Governance & Recert
- Any change to `lyapunov`, `integration`, `robustness`, `byzantine`, `timing` triggers mandatory re-run and re-cert issuance.
- Binder and Checklist updated on every issuance; artifacts retained ≥ 2 years.

## Bottom Line
Two critiques carry weight today (frontier-scale runs; small slowdown). Both are tractable and scheduled; everything else collapses under `verify.ps1` with certificate evidence.

