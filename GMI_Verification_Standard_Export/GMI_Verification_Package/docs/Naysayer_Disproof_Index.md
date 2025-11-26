# Naysayer Disproof Index — Technical Counters

## Claim: “GMI is unprovable.”
- Counter: Coq-compiled artifacts (`.vo`, `.vos`, `.vok`) validate a Lyapunov function with monotonic descent and invariant region properties.

## Claim: “Lyapunov function doesn’t exist for the stated dynamics.”
- Counter: Formal model establishes existence; harness demonstrates empirical adherence with `dV/dt <= -c · ||x||^2`.

## Claim: “Byzantine resilience is hand-wavy.”
- Counter: Aggregator set to trimmed-mean with `trim_ratio=0.2`; quorum follows `2f+1`; outlier handling via z-score and winsorization; diagnostics saved in `Byzantine_map.json`.

## Claim: “Timing jitter undermines guarantees.”
- Counter: Monotonic clock, jitter buffer, deadline scheduling, and rate smoothing; latency CV measured and targeted ≤ 0.05–0.10.

## Claim: “Noise breaks stability.”
- Counter: LPF and median filtering with bounded `noise_max`; robust gain applied; `V_trace` shows sustained descent.

## Claim: “Simulator artifacts don’t reflect real systems.”
- Counter: Binder includes methodology, parameter derivations (eigenvalues of `WK`), and NovaAlign integration tests showing invariant projection in practice.

