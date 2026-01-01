# DemonChaos Overview

Integrates a Lorenz-like system with an external `drive`. Produces:
- `score`: magnitude of the state vector
- `triggered`: threshold crossing (with cooldown)
- `bias`: normalized excess and a cooldown floor

Use bias as an additive knob for prediction; use triggered to request short boosts.

## Pipeline position
Usually sits near (or inside) a prediction stage as an optional “extra feature”:
Input/Features → (optional) Chaos → Decision/Predict.

## Operational notes
- Pure logic: no timers, no file I/O, no OS side effects.
- Determinism: pass explicit `dtMs` and `nowMs` (instead of relying on `A_TickCount`).
- Cooldown uses 32-bit wrap-safe comparisons (AHK’s `A_TickCount` wraps); `cooldownLeftMs` is derived from masked math.

## Integration notes
- `drive` is caller-defined (e.g. speed, confidence, recent spike count).
- `bias` is intended as a small additive knob (bounded by your chosen gains).
