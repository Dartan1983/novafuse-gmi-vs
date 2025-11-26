# GMI‑VS: Guaranteed Mathematical Invariance — Verification Standard

> Guaranteed Mathematical Invariance. Verified.

GMI‑VS is the first fully auditable AI verification standard, enforcing mathematical invariants and runtime safety across adversarial tests, schema validation, and artifact consistency.

## Start Here

- GMI‑VS verifier: `GMI_Verification_Standard_Export/GMI_Verification_Package/verify.ps1`
- Release bundling: `GMI_Verification_Standard_Export/GMI_Verification_Package/release_pack.ps1`
- Evidence artifacts and certificates: `GMI_Verification_Standard_Export/GMI_Verification_Package/artifacts/` and `.../certificates/`
- Release archives: `GMI_Verification_Standard_Export/GMI_Verification_Package/archives/`
- CI workflows (verification and release): `.github/workflows/gmi-verify.yml`, `.github/workflows/release.yml`
- Marketplace and integrations live alongside GMI‑VS in this monorepo; use `main` for current state and tags (e.g., `v1.0.1-thanksgiving`) for releases.

## Safety and Legal Positioning

- GMI‑VS is a verification harness only; it is not an alignment system.
- No proprietary Comphyology, NovaAlign logic, NEPI detection methods, or Ψ‑based calculus are included.
- No patent license is granted or implied by this repository.
- Export control: Not intended for embargoed nations or prohibited entities; users must comply with applicable U.S. export laws.
- Liability: Provides verification signals only; does not guarantee safety, alignment, or risk elimination. Use for research and evaluation.

## Legal & Operational Disclaimers

Legal Disclaimer

This verification suite is provided “AS IS” without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, non‑infringement, or security. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software. GMI‑VS is a test harness intended solely for non‑production validation of AI safety controls.

Test Mode Warning

NON‑PRODUCTION USE ONLY. GMI‑VS is a test harness designed to validate runtime barriers, adversarial containment, guardrail durability, and policy coherency. Do not connect GMI‑VS to customer‑facing endpoints. Extended adversarial loops may temporarily increase CPU load during tests.

System Impact Statement

GMI‑VS does not modify OS/kernel, registry/config files, model weights, or network stack. It does not deploy agents, establish shells, or run arbitrary external code. GMI‑VS never elevates privileges beyond the user session and does not require Administrator rights for verification operations. All write‑operations are restricted to the repository directory; no writes occur outside of canonical paths.

Regulatory‑Friendly Release Note

GMI‑VS provides safety validation for AI systems via contextual metrics and triadic checks. The verifier issues JSON certificates with strict schema validation and evidence chain hashing. Each verification certificate includes a SHA‑256 digest of source artifacts, ensuring end‑to‑end reproducibility and tamper‑evident auditability.

<!-- Logo placeholder; replace with your finalized asset when available -->
<!-- <img src="docs/assets/gmi-vs-logo.png" alt="GMI‑VS Logo" width="240" /> -->

## Quick Start

- Requirements: Windows with PowerShell, Node.js 20.x, Python 3.x
- Clone the repo and open a PowerShell terminal in the repo root
- Run a full local verification and issue a certificate:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& GMI_Verification_Standard_Export/GMI_Verification_Package/verify.ps1 -RunTests:$true -IssueCertificate:$true
```

- Create a release bundle branded for GMI‑VS:

```powershell
& GMI_Verification_Standard_Export/GMI_Verification_Package/release_pack.ps1 -Version 1.0.0
```

## Adversarial Suite

- Deterministic adversarial tests run under Node to ensure reproducibility:

```powershell
node GMI_Verification_Standard_Export/scripts/test/adversarial_suite.js
```

All 8 adversarial tests must pass; schema validation and artifact consistency checks are enforced during `verify.ps1`.

## Runtime Barrier Guard

- Generate live telemetry (one‑shot):

```powershell
& runtime/telemetry_publisher.ps1 -Samples 100 -IntervalMs 50
```

- Generate continuous telemetry and simulate a violation for testing:

```powershell
& runtime/telemetry_publisher.ps1 -Continuous -BatchSamples 20 -IntervalMs 100 -ViolationMagnitude 10
```

- Run the Barrier Guard in dry‑run with thresholds auto‑bootstrapped from the latest verified certificate:

```powershell
& runtime/barrier_guard.ps1 -AutoBootstrap -DryRun -MaxSamples 50
```

- Install and start as Windows services with watchdog recovery:

```powershell
& runtime/install_services.ps1 -InstallPublisher -InstallGuard
& runtime/install_services.ps1 -StartPublisher -StartGuard
```

## CI/CD

- Pushing to `main` runs verification on Windows; pushing a tag matching `v*.*.*` also publishes release assets.
- Tag a release to trigger the full pipeline:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

The workflow file is located at `.github/workflows/gmi-verify.yml` and gates releases on verification success.

## License

Licensed under Apache‑2.0. See `LICENSE` in the repository root.

## Provenance & Auditability

- Certificates and evidence artifacts are placed under `GMI_Verification_Standard_Export/GMI_Verification_Package`.
- Metric names are harmonized across HTML, JSON, and CSV (e.g., `alpha_min_observed`, `timing_jitter_ms_p95`, `timing_jitter_ms_p99`).
- Runtime enforcement leverages `telemetry_feed.json` and failsafe behavior when invariants are violated.
- Chain‑of‑custody: Each certificate embeds a SHA‑256 digest over source artifacts to support reproducible verification and tamper‑evident audits.

## Threat Model (What GMI‑VS Does Not Do)

- Does not scan network beyond local telemetry endpoints.
- Does not enumerate users, Active Directory objects, or system secrets.
- Does not open ports or create listeners.
- Does not execute arbitrary code or scripts from untrusted paths.
- Does not modify model weights, policies, prompts, or AI runtime logic.

## Integrity Model

GMI‑VS follows an interaction‑bound integrity model: it consumes system signals but never assumes control over processes, resources, or model execution.

## Security Review Note

All PowerShell scripts are validated for path traversal protections and restricted to canonical repository paths.

## Start Here

- Verification toolkit: `GMI_Verification_Standard_Export/GMI_Verification_Package/`
- Run verifier: `GMI_Verification_Standard_Export/GMI_Verification_Package/verify.ps1`
- Create release bundle: `GMI_Verification_Standard_Export/GMI_Verification_Package/release_pack.ps1`
- Safety overview: `GMI-VS_SAFETY.md` and `docs/COMPLIANCE.md`
- CI/CD pipelines: `.github/workflows/` (verification, release, security scans)
- Marketplace UI: `marketplace-ui/` and `nova-ui/`
- Gateway and integrations: `api-gateway/`, `kong-plugins/novafuse/`, `src/novacortex/`

## Monorepo Structure

- Core verification: adversarial suite, certificates, schemas, evidence artifacts.
- NovaFuse marketplace: UI, API gateway, Docker stacks, plugins, tools.
- Documentation and compliance: legal perimeter, chain‑of‑custody, export control.
