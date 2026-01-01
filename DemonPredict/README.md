# DemonPredict (AHK v2)

Pure profile decision engine (ADS vs HPR) driven by motion context and feature signals.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
Call `Update()` with context + features each tick. Pass explicit `dtMs`/`nowMs` for deterministic tests.

```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonPredict.ahk

p := DemonPredict()
res := p.Update(
    "ADS",  ; context
    0.9,    ; confidence
    2.0,    ; vel
    1.5,    ; avgSpeed
    1.0,    ; hvRatio
    false,  ; spike
    false,  ; rmbDown
    4,      ; dtMs
    1000    ; nowMs
)
; res["desired"], res["adsProb"], res["changed"]
```

## Examples
- `examples/demo_selftest.ahk`
- `examples/demo_live_context_input.ahk`

## Docs
- `docs/api.md`
- `docs/overview.md`
