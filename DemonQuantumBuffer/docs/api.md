# DemonQuantumBuffer API

## Class: DemonQuantumBuffer
Probabilistic gate: accumulate → decay/noise → collapse.

### Constructor
`q := DemonQuantumBuffer(config?)`

### Update
`res := q.Update(magnitude, dtMs := 4, nowMs := A_TickCount)`

Returns:
- `collapsed` (bool), `allow` (bool), `q` (accumulator after update)

### Other
- `q.Reset()`
- `q.SetSeed(seed)`
- `q.GetState() -> Map`
