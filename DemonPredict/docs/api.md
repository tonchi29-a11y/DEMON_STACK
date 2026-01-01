# DemonPredict API

## Class: DemonPredict

### Constructor
`p := DemonPredict(config?)`

### Update
`result := p.Update(context, confidence, vel, avgSpeed, hvRatio, spike, rmbDown := false, dtMs := 4, nowMs := A_TickCount)`

Returns Map:
- `adsProb` (0..1)
- `desired` ("ADS"|"HPR")
- `changed` (bool)
- `reason` (string)
- `onMs`, `offMs`
- `cooldownLeftMs`

### Other
- `p.GetState() -> Map`
- `p.Reset()`

### Optional callback
- `p.OnDecisionChanged := MyFn`
- `MyFn(p, desired, reason, adsProb)` (must be non-blocking)
