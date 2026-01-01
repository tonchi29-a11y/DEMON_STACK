# DemonChaos (AHK v2)

Lorenz-inspired chaos score with trigger and bias.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
Call `Step()` at your cadence (you provide `dtMs`/`nowMs` for deterministic tests).

```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonChaos.ahk

c := DemonChaos(Map(
    "Threshold", 12.0,
    "CooldownMs", 200
))

nowMs := 1000
dtMs := 4
res := c.Step(0.25, dtMs, nowMs)
; res["score"], res["triggered"], res["bias"]
```

## Examples
- `examples/demo_selftest.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
