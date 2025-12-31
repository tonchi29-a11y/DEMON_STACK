# API

## Constructor

`ctx := DemonContextDetect(config?)`

`config` is an optional `Map` overriding defaults.

### Config keys (v1)
- `TauAvgMs`, `FixedAvgAlpha`
- `HoldMs`
- `HvEps`, `SpikeEps`
- `IdleOn`, `IdleOff`
- `LongOn`, `LongOff`
- `CloseOn`, `CloseOff`

## Update

`ctx.Update(dx, dy, dtMs, nowMs := A_TickCount) -> Map`

Returns a `Map` with stable keys:
- `context` (string)
- `confidence` (0..1)
- `vel`, `avgSpeed`, `hvRatio`, `spike`
- `changed` (bool)
- `reason` (short string)
- `holdLeftMs`

Notes:
- `vel` units are `counts per ms` because it is computed as `magnitude / dtMs`.

## Reset

`ctx.Reset()`

Resets context and rolling features.

## GetState

`ctx.GetState() -> Map`

Returns the current context and feature snapshot.
