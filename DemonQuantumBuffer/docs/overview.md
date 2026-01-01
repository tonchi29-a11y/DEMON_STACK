# DemonQuantumBuffer Overview

Implements a simple “superposition → collapse” gate:
- Accumulate: `q = q * decay^factor + gain * magnitude + noise`
- Collapse: if `q ≥ threshold` → `allow := true` and reset `q`

Pure math; no timers and no I/O. Caller controls cadence and time inputs.

## Pipeline position
Useful as a stochastic gate anywhere you need “occasionally let a sample through” behavior:
Input/Feature → QuantumBuffer gate → downstream filter / context / predictor / telemetry.

## Operational notes
- Determinism: in selftests and simulations, pass explicit `dtMs` and `nowMs` (avoid depending on `A_TickCount`).
- Noise: randomness is an internal LCG; you can make runs reproducible with `SetSeed()`.
- Range: accumulator `q` is clamped to `≥ 0` after update.

## Integration notes
- Treat `allow` as “pass this sample now”; if `allow` is false, you typically drop/hold the sample.
- `magnitude` should be scaled so that typical values reach `Threshold` at the cadence you want (tune `Gain`, `Decay`, and `Threshold`).
- `Uncertainty` and `NoiseAmp` control how often borderline magnitudes still occasionally collapse.
