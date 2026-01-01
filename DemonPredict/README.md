# DemonPredict (AHK v2)

Pure decision engine (ADS vs HPR) driven by motion context and feature signals (typically from DemonContextDetect). Uses Schmitt thresholds + TAU timers + cooldown to reduce flapping.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonPredict.ahk

pred := DemonPredict()

; `ctx` is typically a DemonContextDetect instance.
st := ctx.GetState()

r := pred.Update(
    st["context"], st["confidence"],
    st["vel"], st["avgSpeed"], st["hvRatio"], st["spike"],
    false, 8, A_TickCount
)

; r["desired"] is "ADS" or "HPR"
```

## Examples
- `examples/demo_selftest.ahk`
- `examples/demo_live_context_input.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`

## License
MIT (see `LICENSE`).
