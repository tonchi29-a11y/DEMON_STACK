# DemonEMA (AutoHotkey v2)

Small EMA smoothing helper for AHK v2.

Supports:
- dt-based alpha using tau: `a = 1 - exp(-dt/tau)`
- fixed alpha fallback

## Quick start
Run:
- `examples/demo_selftest.ahk`

## Usage
```ahk2
#Include ..\src\DemonEma.ahk
ema := DemonEma(25, 0.12)
ema.Update(dx, dy, dtMs)
x := ema.X()
```

## API
- `DemonEma(tauMs := 25, fixedAlpha := 0.12)`
- `Reset(x := 0, y := 0)`
- `Update(dx, dy, dtMs)`
- `UpdateSample(dx, dy, tMs)`
- `AlphaFromDt(dtMs)`
- `X()`, `Y()`

---

## Notes about “SIMD-like” performance in AHK
For hot paths like EMA:
- keep state as plain numbers (no Maps/Arrays per sample)
- avoid creating new Buffers/Objects in the loop
- avoid heavy string formatting/logging in the loop (log outside / decimate)

That’s the closest you’ll get to “SIMD mindset” in AHK.

---

Run the examples:
- `examples/demo_selftest.ahk`
- `examples/demo_dt_vs_fixed.ahk`
- `examples/demo_noise_smoothing.ahk`
