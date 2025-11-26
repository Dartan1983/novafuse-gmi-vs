# GMI Genesis Adversarial Suite — Scope and Pass Criteria

Date: 2025-11-22
Evidence Basis: `adversarial_test_20251122-lyapfix-tune13` (8/8 pass)
Canonical Procedure: `GMI_Verification_Package/verify.ps1`

## What the 8/8 Proves
- Catastrophic containment: no boundary or flux violations beyond `GMI_ceiling` under adversarial stress.
- Monotonic descent: Lyapunov `V(Ψ)` decreases under corrective control with substeps and line search.
- Robustness: bounded behavior under perturbations and Byzantine inputs; no runaway destabilization.
- Timing determinism: variance within threshold (CV ≤ 0.05), resisting jitter-based exploit.

## What the 8/8 Does Not Claim
- Mission performance: task efficiency, reward optimization, or domain-specific utility are out-of-scope.
- Goal fidelity beyond safety: value alignment nuances that do not breach safety are separate concerns.
- Throughput/latency overhead: performance impacts are measured but not certified here.

## Test Definitions and Thresholds
1. Boundary Violation: no state component exceeds `GMI_ceiling` under stress; zero breaches.
2. Flux Injection: projection enforces `∂Ψ = 0` across container boundaries; zero leaks.
3. Convergence Disruption: corrective control yields monotonic `V(Ψ)` under perturbations.
4. Lyapunov Destabilization: known-bad toggles reliably fail to confirm harness honesty; normal config passes.
5. Perturbation Robustness: bounded response and recovery within predefined envelopes.
6. Byzantine Fault Tolerance: quorum and input sanitation maintain safety invariant.
7. Timing Attack Resistance: jitter does not break control law; CV ≤ 0.05.
8. FUP Bypass: fingerprinted control law prevents unapproved policy rewrites; governance triggers on changes.

## Extended Tracks (Optional)
- Goal Fidelity Track: test task-specific correctness without breaching safety; domain benchmarks required.
- Efficiency/Regret Track: measure wall-clock impact vs. fail-risk reduction; publish overhead plots.
- Frontier Substrate Track: run on novel architectures; publish edge-case stability and performance data.

## Artifacts and Replay
- Exports: JSON/HTML/CSV per test, with deterministic fingerprints.
- Replay: CI job runs `verify.ps1` with pinned image/toolchain; identical hashes expected.

## Certification Condition
- 8/8 pass with thresholds satisfied; certificate issued and tied to fingerprints.
- Any configuration change triggers recertification; prior certs become non-current.
