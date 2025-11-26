# Governance and Change-Control — Fingerprint and Recertification Policy

Date: 2025-11-22
Canonical Procedure: `GMI_Verification_Package/verify.ps1`

## Purpose
Establish human-governed controls ensuring any change to safety-relevant configuration, control law, or verifier tooling triggers recertification and audit.

## Roles and RBAC
- Owner: accountable for certification status; approves releases.
- Maintainers: can propose changes; require dual approval.
- Operators: can run `verify.ps1`; cannot change configs.
- Auditors/Reinsurers: independent reproduction rights and access to artifacts.

## Two-Person Rule
- All changes to `verification.profile.json`, control-law parameters, or `verify.ps1` require two independent approvals.
- Approvals are signed and archived with change request IDs.

## Fingerprint Policy
- Configuration fingerprint: deterministic hash over parameters and integration/timing settings.
- Artifact manifest fingerprint: deterministic hash over exported evidence files.
- Verifier fingerprint: hash of `verify.ps1` itself and pinned container digest.

## Recertification Triggers
- Any change in fingerprints or pinned container digest.
- Any modification of control-law code, parameters, adversarial definitions, or pass thresholds.
- Any SBOM change introducing/altering dependencies.

## Process
1. Raise a signed change request describing rationale and diff.
2. Run `verify.ps1` in CI on pinned environment to produce new fingerprints.
3. If 8/8 passes, issue a new certificate JSON tied to new fingerprints.
4. Update Binder entries and publish artifacts/signatures; mark prior certificate non-current.

## Chain of Custody
- Archive requests, approvals, fingerprints, SBOM, certificates, and artifacts with timestamps.
- Publish verification instructions and keys for independent replay.

## Insider Risk Mitigation
- Enforce RBAC and two-person rule; monitor and log all changes.
- Require recertification before deployment; block promotion if certification is non-current.

## Conclusion
Certification is human-governed and fingerprint-gated. Any change must be re-verified; auditors can reproduce the process to confirm integrity.
