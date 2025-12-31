# DemonWatchdog Overview

## Quick start
- Include DemonTime and DemonWatchdog, then run `examples/demo_selftest.ahk` to validate.
- Optional: include DemonLog and log inside callbacks if you want persisted diagnostics.

## Design goals
- Generic watchdog usable by any AutoHotkey v2 script.
- Detect timer stalls/hiccups using high-resolution QPC timing.
- Keep policy (how to respond) outside the library via callbacks.

## Architecture
- **Heartbeat timer**: `SetTimer` drives the watchdog at the configured `periodMs`.
- **Timing core**: Every tick calls `DemonTime.NowQpc()` to compute elapsed milliseconds.
- **Hiccup counter**: Each stall increments `hiccups`; healthy ticks decrement it until it reaches zero.
- **Degraded mode**: Entered when `hiccups >= degradedAfter`, exited when `recoverBelow >= 0` and `hiccups <= recoverBelow` (or via manual `ExitDegraded()`).
- **Callbacks**: `OnStall` and `OnDegradedChanged` let host scripts react (adjust UI, slow pipelines, etc.).
- **Optional logging**: Host scripts can log inside callbacks (e.g. via DemonLog).

## Typical workflow
1. Construct a watchdog with your desired period/tolerance.
2. Assign callbacks (and optionally configure DemonLog).
3. Call `Start()`; the watchdog runs in the background.
4. Use `Touch()` if your code manually confirms recent activity.
5. On shutdown, call `Stop()` to release timers.

## Notes
- Requires Windows (DemonTime is built on QueryPerformanceCounter).
- The library itself does not change timer resolutions, affinity, or process state.
- Works silently if DemonLog is absent, so it can be embedded in minimal scripts.

## Callback guidelines
- Callbacks should be non-blocking (avoid UI like `MsgBox` inside timer callbacks).
- Degraded mode is a signal, not an automatic “fix”.
- Typical host responses: widen timers, reduce HUD/overlay refresh, disable expensive features.
