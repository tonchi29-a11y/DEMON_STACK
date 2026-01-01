# DemonQuantumBuffer API

## Class: DemonQuantumBuffer
Probabilistic gate: accumulate → decay/noise → collapse.

### Constructor
`q := DemonQuantumBuffer(cfg := 0)`

- If `cfg` is a `Map`, it overrides defaults.

Config keys (defaults):
- `BaseDtMs` (4.0)
- `Decay` (0.92)
- `Gain` (0.10)
- `Threshold` (2.0)
- `Uncertainty` (1.0)
- `NoiseAmp` (0.10)

### Update
`res := q.Update(magnitude, dtMs := 4, nowMs := A_TickCount)`

Returns:
- `collapsed` (bool): true if `q` crossed threshold this call.
- `allow` (bool): true on collapse (typical “pass sample” signal).
- `q` (float): accumulator after update (and after reset on collapse).

### Other
- `q.Reset()`
- `q.SetSeed(seed)`
- `q.GetState() -> Map`
