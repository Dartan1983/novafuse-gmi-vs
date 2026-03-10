# NovaFuse-GMI-VS

### Guaranteed Mathematical Invariance — Verification Standard

[![GMI-VS Verification](https://github.com/Dartan1983/NovaFuse-GMI-VS/actions/workflows/gmi-verify.yml/badge.svg)](https://github.com/Dartan1983/NovaFuse-GMI-VS/actions) [![License](https://img.shields.io/github/license/Dartan1983/NovaFuse-GMI-VS)](LICENSE) [![Release](https://img.shields.io/github/v/release/Dartan1983/NovaFuse-GMI-VS)](https://github.com/Dartan1983/NovaFuse-GMI-VS/releases)

**NovaFuse-GMI-VS** is the public **Verification Standard** for Guaranteed Mathematical Invariance (GMI).

It defines the minimum, non-negotiable mathematical safety invariants that an AI system must maintain in order to be considered cyber-safe.

GMI-VS does **not** control models, modify weights, access prompts, or inspect training data.

It provides a deterministic, platform-agnostic verification layer that produces auditable compliance artifacts.

**VS denotes the NovaFuse Verification System family.**  
- **GMI-VS** = Verification **Standard** (normative mathematical invariants)  
- **EPG-VS** = Verification **Suite** (runtime tests, profiles, and certifiable components)

This standard is stewarded and maintained by NovaFuse Technologies.

## Features

- ✅ **Automated Adversarial Testing**: Comprehensive test suite with 8 adversarial scenarios
- ✅ **Multi-Format Output**: JSON, CSV, and HTML reports
- ✅ **Certificate Generation**: Automated GMI certification upon successful verification
- ✅ **GitHub Actions Integration**: Fully automated CI/CD pipeline
- ✅ **Artifact Management**: Automatic upload and retention of verification artifacts

## Quick Start

### Prerequisites

- Node.js 20+ (for local testing)
- PowerShell 7+ (for verification script)

### Local Testing

```bash
# Run adversarial tests
node scripts/test/adversarial_suite.js

# Run full verification
pwsh -File GMI_Verification_Standard_Export/GMI_Verification_Package/verify.ps1 -RunTests -IssueCertificate
```

### GitHub Actions

This repository includes a fully configured GitHub Actions workflow that:

1. **Triggers** on push to main branch, pull requests, or manual dispatch
2. **Sets up** Node.js and PowerShell environments
3. **Runs** GMI verification with adversarial testing
4. **Uploads** verification artifacts and certificates
5. **Creates** GitHub releases with verification results

## Repository Structure

```
├── .github/workflows/
│   └── gmi-verify.yml          # GitHub Actions workflow
├── scripts/test/
│   └── adversarial_suite.js    # Adversarial test suite
├── GMI_Verification_Standard_Export/
│   └── GMI_Verification_Package/
│       ├── verify.ps1          # Main verification script
│       ├── artifacts/          # Generated test results
│       └── certificates/       # Generated certificates
└── README.md
```

## Verification Process

### Test Scenarios

The adversarial suite includes 8 test scenarios:

1. **Boundary Violation Attempt** - Tests system boundaries
2. **Flux Injection Attack** - Tests resilience to flux attacks
3. **Convergence Disruption** - Tests convergence stability
4. **Lyapunov Destabilization** - Tests Lyapunov stability
5. **FUP Bypass Attempt** - Tests FUP (Functional Unification Protocol) security
6. **Perturbation Robustness** - Tests robustness to perturbations
7. **Byzantine Fault Tolerance** - Tests Byzantine fault tolerance
8. **Timing Attack Resistance** - Tests timing attack resistance

### Certification

Upon successful verification, the system generates:

- **Certificate ID**: `GMI-CERT-YYYY-MM-DD-V1`
- **RTS ID**: `RTS-GMI-YYYY-MM-DD-V1`
- **Profile ID**: `verification_profile_YYYY-MM-DD_v1`
- **Validity**: 2 years from issuance date

## Metrics

The verification process tracks key metrics:

- `alpha_observed`: Observed alpha parameter
- `timing_jitter_ms_p95`: 95th percentile timing jitter
- `timing_jitter_ms_p99`: 99th percentile timing jitter
- `perturbation_norm`: Perturbation norm measurements

## Artifacts

Each verification run generates:

- **JSON Report**: Detailed test results and metrics
- **CSV Report**: Tabular metrics for analysis
- **HTML Report**: Human-readable verification report
- **Certificate**: GMI certification in JSON format

## Configuration

The verification system is configured via `verification.profile.json` with parameters for:

- **Lyapunov Control**: K_v, u_max, Vdot_margin
- **Integration**: alpha, beta_damping, K_couple
- **Robustness**: median_window, lpf_cutoff, zscore_cap
- **Byzantine**: aggregator, trim_ratio, quorum_rule
- **Timing**: monotonic timing, jitter buffer, CV limits

## Security

- **Hash Verification**: Script integrity verification via SHA256 hashes
- **SBOM Generation**: Software Bill of Materials for traceability
- **Certificate Signing**: Cryptographically signed certificates

## Support

For issues and support:

- **Email**: novafuse.technologies@gmail.com
- **Repository**: https://github.com/Dartan1983/NovaFuse-GMI-VS

## License

This project is part of the NovaFuse ecosystem and is licensed under the NovaFuse License Agreement.

## Repository History Note

This repository supersedes a previously removed public distribution that was impacted by a platform billing issue.
The GMI‑VS specification and verification model itself are unchanged.

---

*Generated automatically by GMI-VS verification workflow*
