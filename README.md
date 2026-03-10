# GMI-VS (Genesis Machine Intelligence - Verification Suite)

## Overview

GMI-VS is a comprehensive verification and certification suite for NovaFuse Genesis Machine Intelligence systems. This repository provides automated testing, verification, and certificate generation for GMI implementations.

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
- **Repository**: https://github.com/Dartan1983/novafuse-gmi-vs

## License

This project is part of the NovaFuse ecosystem and is licensed under the NovaFuse License Agreement.

---

*Generated automatically by GMI-VS verification workflow*
