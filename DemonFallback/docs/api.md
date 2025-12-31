# DemonFallback API

## Class: DemonFallback

### Constructor
`fb := DemonFallback(config?)`

`config` can be a Map or object. Any missing keys fall back to defaults.

#### Defaults
Threshold inputs:
- `JitterP95_ThresholdMs` = `0.60`
- `JitterTripLimit` = `2`
- `BridgeFailTripLimit` = `3`
- `WatchdogHiccupTripLimit` = `1`

Decay + cooldown:
- `TripDecayOnOk` = `1`
- `CooldownMs` = `1500`
- `MinHoldMs` = `800`

Knob presets (returned to caller):
- `NormalKnobs` = `{ workMs: 8,  hudMs: 100, bridgeMs: 20,  predictorDecimate: 2, timerRes: false }`
- `DegradedKnobs` = `{ workMs: 20, hudMs: 250, bridgeMs: 100, predictorDecimate: 3, timerRes: true }`
- `FallbackKnobs` = `{ workMs: 30, hudMs: 500, bridgeMs: 250, predictorDecimate: 4, timerRes: true }`

### Update
`result := fb.Update(signals, nowMs := A_TickCount)`

`signals` is a Map/object. All keys are optional; missing values are treated as `0`/false.

Input keys:
- `jitterP95Ms` (float)
- `watchdogHiccups` (int)
- `bridgeFail` (int)
- `forceMode` (string: `NORMAL|DEGRADED|FALLBACK` or `""`)
- `disableFallback` (bool)

Returns Map keys:
- `mode` (string)
- `changed` (bool)
- `reason` (string)
- `knobs` (Map)
- `trips` (Map)
- `cooldownLeftMs` (int, >= 0)
- `holdLeftMs` (int, >= 0)

### GetState
`fb.GetState() -> Map`

Returns:
- `mode`, `lastChangeMs`, `cooldownLeftMs`, `lastReason`
- `trips` map for debugging

### ForceMode
`fb.ForceMode(mode, reason := "manual", nowMs := A_TickCount)`

Requests an immediate override to `mode` (bypasses cooldown/hold).

Assign callbacks using direct function references (`MyFunc`) or closures/bound funcs:
- `fb.OnModeChanged := MyModeChanged`

Signature:
`MyModeChanged(fb, oldMode, newMode, reason, knobs)`

### Reset
`fb.Reset()`

Clears trips, returns to `NORMAL`, clears timers/counters.

## Notes
- Timing is based on `A_TickCount` (u32). Elapsed time is computed wrap-safe:
	`ageMs := (nowMs - thenMs) & 0xFFFFFFFF`
- `knobs` is returned as a fresh Map copy so callers can mutate safely.
