# DemonPredict API

## Class: DemonPredict

### Constructor
`p := DemonPredict(cfg := 0)`

- `cfg` (Map, optional): merged into defaults.

Default config keys:
- `RmbOverrides`: `true`
- `T_ON`: `0.55`
- `T_OFF`: `0.45`
- `TAU_ON_MS`: `40.0`
- `TAU_OFF_MS`: `75.0`
- `CooldownMs`: `250`

Normalization ranges:
- `SpikeMin`: `1.5`, `SpikeMax`: `3.0`
- `HvMin`: `1.0`, `HvMax`: `3.0`
- `SpeedMin`: `0.10`, `SpeedMax`: `1.20`

Weights:
- `W_CTX`: `0.40`
- `W_SPIKE`: `0.35`
- `W_HV`: `0.10`
- `W_SPEED`: `0.15`

### Update
`res := p.Update(context, confidence, vel, avgSpeed, hvRatio, spike, rmbDown := false, dtMs := 4, nowMs := A_TickCount)`

Returns Map:
- `adsProb` (0..1)
- `desired` ("ADS" | "HPR")
- `changed` (bool)
- `reason` ("rmb" | "tau_on" | "tau_off" | "")
- `onMs`, `offMs`
- `cooldownLeftMs`

### Other
- `p.GetState() -> Map`
- `p.Reset()`

### Optional callback
- `p.OnDecisionChanged := MyFn`
- `MyFn(p, desired, reason, adsProb)` must be non-blocking.
