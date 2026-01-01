# DemonChaos API

## Class: DemonChaos
Lorenz-inspired driveable chaos score with cooldown and bias.

### Constructor
`c := DemonChaos(cfg := 0)`

- If `cfg` is a `Map`, it overrides defaults.

Config keys (defaults):
- `Sigma` (10.0), `Rho` (28.0), `Beta` (8.0/3.0)
- `DriveGain` (0.5)
- `Threshold` (12.0)
- `CooldownMs` (200)
- `BiasGain` (0.25)
- `BiasFloorDuringCooldown` (0.10)

### Step
`res := c.Step(drive := 0.0, dtMs := 4, nowMs := A_TickCount)`

Returns:
- `score` (float): magnitude of the internal state
- `triggered` (bool): `true` when score crosses threshold and not in cooldown
- `bias` (float): normalized excess * gain, with optional floor during cooldown
- `cooldownLeftMs` (int): remaining cooldown based on wrap-safe tick math

### Other
- `c.Reset()`
- `c.GetState() -> Map`
