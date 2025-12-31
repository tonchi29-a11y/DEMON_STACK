# DemonTimerRes — Overview

DemonTimerRes provides a small, ref-counted wrapper around Windows Multimedia Timer Resolution requests (`timeBeginPeriod` / `timeEndPeriod`).

## Why
Some pipelines (high-frequency timers, watchdog sampling, or “degraded mode” timer widening) behave more consistently when the system timer resolution request is held (commonly 1ms).

## Key properties
- **Ref-counted**: multiple components can call `Acquire()` and only the last `Release()` ends the request.
- **Safe failure**: returns `false` if the API is unavailable or the call fails; never throws from `Acquire/Release`.
- **No admin required**: these APIs do not require elevation.
- **System-wide request**: `timeBeginPeriod` affects system timer resolution while active.

## Notes
- This is a *request*, not a guarantee. Windows scheduling and power management still apply.
- Keep the hold window minimal; call `Release()` when you’re done.

## References
- Microsoft docs: https://learn.microsoft.com/windows/win32/api/timeapi/nf-timeapi-timebeginperiod
