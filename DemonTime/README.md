# DemonTime (AutoHotkey v2)

Small timing utilities for AutoHotkey v2, built around Windows QueryPerformanceCounter (QPC).

## Quick start
Run the self-test:

- `examples/demo_selftest.ahk`

## Usage
```ahk2
#Include ..\src\DemonTime.ahk

t0 := DemonTime.NowQpc()
; ... work ...
ms := DemonTime.MsSince(t0)
```

## API
- `DemonTime.Freq()`
- `DemonTime.NowQpc()`
- `DemonTime.MsSince(qpcStart)`
- `DemonTime.SecSince(qpcStart)`
- `DemonTime.Tick()`
- `DemonTime.MeasureSleep(ms)`

## Notes on Sleep accuracy
`Sleep(ms)` is scheduled by Windows and may overshoot or undershoot depending on system load and timer resolution. `DemonTime.MeasureSleep(ms)` reports the actual elapsed time so you can observe the difference, but it does not guarantee precise sleeping.

## Notes on QPC frequency
`DemonTime.Freq()` reflects the QPC frequency reported by your system (for example 10,000 on some hardware). Values vary by platform and that is expected.

---

## What to run
- Run `examples/demo_selftest.ahk` first
- Then `examples/demo_qpc_sleep.ahk`
- Then `examples/demo_qpc_loop.ahk`

See also: DemonWatchdog (uses DemonTime + DemonLog when available).
