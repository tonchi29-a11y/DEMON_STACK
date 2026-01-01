# DemonNeuromorphic Overview

Simplified spiking neuron layer to augment confidence or thresholds.
- Inputs: per-neuron intensities (e.g., velocity * confidence).
- Outputs: spike events and a bounded `boost` suitable for context/predict.

Pure AHK v2, no timers or I/O. Caller controls cadence (dtMs/nowMs).

## Pipeline position
Typically used as an optional augmentation:
Features → Neuromorphic spikes → (boost/bias) → Context/Predict/Decision.

## Operational notes
- Pure logic: safe to call from timer/message contexts as long as your callback usage is non-blocking.
- Determinism: pass explicit `dtMs` and `nowMs` in tests (don’t rely on `A_TickCount`).
- Refractory uses wrap-safe comparisons against `nowMs` masked to 32-bit tick math.

## Integration notes
- Use `boost` as a small additive modifier (e.g., raise confidence, lower thresholds, or bias desired profile).
- If you only have fewer intensity channels than `Count`, pass a shorter array; missing channels are treated as 0.
