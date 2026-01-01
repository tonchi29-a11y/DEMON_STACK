# DemonChaos API

## Class: DemonChaos
Lorenz-inspired driveable chaos score with cooldown and bias.

### Constructor
`c := DemonChaos(config?)`

### Step
`res := c.Step(drive := 0.0, dtMs := 4, nowMs := A_TickCount)`

Returns:
- `score` (float), `triggered` (bool), `bias` (0..1), `cooldownLeftMs` (int)

### Other
- `c.Reset()`
- `c.GetState() -> Map`
