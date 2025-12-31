# DemonTimerRes (AHK v2)

Ref-counted Windows timer resolution requests via `timeBeginPeriod` / `timeEndPeriod`.

## What it does
- Requests a better timer resolution (commonly 1ms)
- Ref-counted acquire/release to prevent mismatched calls
- Safe failure: returns status and won’t crash if API is unavailable

## Quick start
```ahk
#Requires AutoHotkey v2.0
#Include ..\src\DemonTimerRes.ahk

ok := DemonTimerRes.Acquire(1)
; ... do high-frequency timers / watchdog sampling ...
DemonTimerRes.Release()
```

## Docs
- Overview: docs/overview.md
- API: docs/api.md

## Example
- examples/demo_selftest.ahk

## Notes
- This is a system-wide request while held; keep holds short.
- This does not guarantee perfect 1ms sleeps; Windows scheduling still applies.

## References
- Microsoft docs: https://learn.microsoft.com/windows/win32/api/timeapi/nf-timeapi-timebeginperiod
