Title: GMI‑VS Public Release — v1.0.1‑thanksgiving

Summary
- Public‑safe release of the GMI‑VS verification standard.
- Documentation and governance updates only; marketplace code not included.

Changes
- README.md: Legal & Operational Disclaimers; Threat Model; Integrity Model; Security Review Note; chain‑of‑custody.
- LICENSE: NOTICE for IP reservation, export control, non‑production/no‑warranty (Apache‑2.0 compatible).
- docs/COMPLIANCE.md: Export control; chain‑of‑custody; write boundaries (no admin; no writes outside canonical paths).
- GMI‑VS_SAFETY.md: Consolidated legal/safety/integrity statements.
- Verification engine: GMI_Verification_Standard_Export/GMI_Verification_Package/** and scripts/test/**.

Artifacts (on tag)
- sbom‑v1.0.1‑thanksgiving.spdx.json
- certificate‑v1.0.1‑thanksgiving.json (published when verification succeeds)

Verification
- CI runs PowerShell verifier: `verify.ps1 -RunTests:$true -IssueCertificate:$true`.
- Certificate uploads only on successful issuance; SBOM is always published.

Security Recap
- No admin rights; no privilege escalation.
- No kernel/registry/config writes; writes restricted to repo canonical paths.
- No agents, no network scans, no model‑weight access.
- HTTP‑bound, non‑privileged interactions only.

Impact
- Documentation‑only packaging of the verification standard; marketplace/integrations remain private.

Repo
- https://github.com/Dartan1983/novafuse-gmi-vs
- Default branch: main; Tag: v1.0.1‑thanksgiving
# GMI‑VS — The Verification Standard for Guaranteed Mathematical Invariance

GMI — Guaranteed Mathematical Invariance — is a foundational principle:

> Systems that claim to be aligned, safe, or trustworthy must first demonstrate mathematically that key invariants do not drift, degrade, or mutate as the system evolves.

Safety must be provable, not assumed.

## What GMI‑VS Actually Does
GMI‑VS is a verification and compliance standard built on the GMI principle. It does not tune, influence, or run models.

It outputs:
- Mathematically checkable invariants
- Compliance evidence
- Schema‑validated certificates
- Runtime safety signal validation
- Chain‑of‑custody fingerprints (SHA‑256)
- Independently auditable reports

All without touching:
- Model weights
- Policies
- Prompts
- Production logic
- Training data
- System internals

## Who GMI‑VS Is For
- Researchers verifying claims
- Developers certifying releases
- Regulators enforcing minimum standards
- Enterprises procuring safe AI
- Anyone building cyber‑safety at scale

Run one command. Watch the certificate appear — or watch it refuse, with clear reasons.

GMI‑VS v1.0.1‑thanksgiving — November 26, 2025
