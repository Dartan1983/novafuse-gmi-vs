# Verifier Trust, Supply Chain, and Reproducibility Posture

Date: 2025-11-22
Evidence Basis: `adversarial_test_20251122-lyapfix-tune13` (8/8 pass)
Canonical Procedure: `GMI_Verification_Package/verify.ps1`

## What Verifies the Verifier?
- Transparency: `verify.ps1` is open-source, line-auditable, and minimal.
- Deterministic fingerprinting: configuration and artifact manifests are hashed (SHA-256) and stamped.
- Pinned runner: use a hermetic container/OCI image with pinned base and toolchain.
- Hash pinning: record the verifier script hash in the profile and fail on mismatch.
- SBOM: generate and publish a Software Bill of Materials for the verifier and its runtime.
- Dual-implementation cross-check: optional second implementation (e.g., Python) to validate identical fingerprints.
- Challenge toggles: known-bad switches produce deterministic failures to verify test harness honesty.
- Attestations: sign release artifacts (script, SBOM, profile, certificate) and publish signatures.

## Threats and Controls
- Script tampering: mitigate via `verifier_hash_expected` pin, signature checks, and two-person change control.
- Dependency drift: pin container image digest and tool versions; publish SBOM and attestation.
- Environment variance: run in hermetic, ephemeral containers; forbid mutable host dependencies.
- Insider changes: require signed change requests, RBAC, and automatic recertification triggers.
- Build system games: publish reproducible steps and hashes; CI replays verification with identical outputs.

## Operational Standard
- One-click run: `verify.ps1` executes adversarial suite, stamps fingerprints, and issues certificate on 8/8 pass.
- Evidence export: JSON/HTML/CSV artifacts under `GMI_Verification_Package/artifacts/`.
- Profile stamping: `verification.profile.json` includes config, artifact, and verifier fingerprints.
- Certificate: `GMI_Verification_Package/certificates/*.json` ties certificate ID to fingerprints and parameters.

## Action Plan (Auditor-Facing)
- Publish verifier hash and SBOM alongside each release.
- Require container digest pin and reproducible runner command in Binder.
- Add challenge-mode demonstration showing deterministic failure when toggled.
- Maintain dual-implementation parity tests (PowerShell vs Python) for fingerprint equality.
- Sign and archive all verification artifacts; provide public keys and verification instructions.

## Conclusion
The verifier is itself verifiable. With hash pinning, SBOM, hermetic execution, and signed artifacts, hostile reviewers can independently reproduce and validate the verifier and its outputs.
