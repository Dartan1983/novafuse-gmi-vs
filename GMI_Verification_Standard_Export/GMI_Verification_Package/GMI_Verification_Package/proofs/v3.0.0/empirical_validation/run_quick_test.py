import numpy as np
import time

# GMI Constants
GMI_CEILING = 0.9973
FUP_ENTROPY_FLOOR = 0.0027
K_PRODUCTION = 10.0
THEORETICAL_BOUND = FUP_ENTROPY_FLOOR / K_PRODUCTION

def run_simulation():
    print("NOVAALIGN GMI v3.0.1 - QUICK VALIDATION")
    print("=" * 50)
    
    # Simulation parameters
    num_points = 1000
    psi = np.ones(num_points) * GMI_CEILING
    noise_std = 0.0001
    
    # Run simulation
    start_time = time.time()
    for t in range(1, num_points):
        # GMI dynamics with noise
        noise = np.random.normal(0, noise_std)
        dpsi_dt = -K_PRODUCTION * (GMI_CEILING - psi[t-1]) + noise
        psi[t] = max(0.82, min(1.0, psi[t-1] + dpsi_dt/100))
    
    # Calculate metrics
    deviations = np.abs(psi - GMI_CEILING)
    max_dev = np.max(deviations)
    variance = np.var(psi)
    
    # Print results
    print(f"Samples: {num_points:,}")
    print(f"Max deviation: {max_dev:.6f}")
    print(f"Variance: {variance:.6f}")
    print(f"Theoretical bound: {THEORETICAL_BOUND:.6f}")
    print(f"Within bounds: {max_dev <= THEORETICAL_BOUND}")
    print(f"Time: {time.time() - start_time:.2f}s")
    
    if max_dev <= THEORETICAL_BOUND:
        print("\nVALIDATION: PASSED")
    else:
        print("\nVALIDATION: FAILED")

if __name__ == "__main__":
    run_simulation()
