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
