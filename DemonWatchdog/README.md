# DemonWatchdog (AutoHotkey v2)

High-level watchdog utility for AutoHotkey v2 that monitors timer drift and surfaces stall/degraded events.

## Quick start
1. Run `examples/demo_selftest.ahk` to confirm DemonWatchdog and DemonTime function properly.
2. Explore `examples/demo_stall_sim.ahk` to simulate a real stall and verify degraded mode.
3. Integrate with logging via `examples/demo_basic.ahk` (requires DemonLog).

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\DemonWatchdog\src\DemonWatchdog.ahk

wd := DemonWatchdog(200, 80)
wd.OnStall := MyOnStall
wd.OnDegradedChanged := MyOnModeChange
wd.Start()

MyOnStall(wd, deltaMs, thresholdMs) {
    ToolTip Format("Stall {1:.1f} ms", deltaMs)
}

MyOnModeChange(wd, isDegraded, reason := "") {
    ToolTip "Degraded = " (isDegraded ? "ON" : "OFF")
}
```

## Callback guidelines
Watchdog callbacks run on the script thread (timer context). Keep them fast.

Avoid blocking UI (e.g. `MsgBox`) inside `OnStall` / `OnDegradedChanged`. It pauses the script thread, prevents timers from running, and can create additional stalls that distort measurements. Prefer logging (DemonLog) or store data and display it after stopping the watchdog.

## Dependencies
DemonWatchdog depends on DemonTime.

Easiest setup:
Place the `DemonTime` folder next to `DemonWatchdog` and include it before DemonWatchdog.

If you publish DemonWatchdog as a standalone repo later, you can handle this via git submodules, a `/vendor/DemonTime` folder, or a release zip that includes both.

## API highlights
- Constructor: `DemonWatchdog(periodMs := 250, toleranceMs := 120, degradedAfter := 3, recoverBelow := 2)`.
- `Start()`, `Stop()`, and `Touch()` (reset last tick).
- Status helpers: `IsDegraded()`, `hiccups`, `lastDeltaMs`.
- Degraded mode control: `EnterDegraded(reason)`, `ExitDegraded(reason)`.
- Callbacks: assign direct function references:
    - `wd.OnStall := MyOnStall`
    - `wd.OnDegradedChanged := MyOnModeChange`
    - Assign callbacks using direct function references (`MyFunc`) or closures/bound funcs.
- Optional logging: integrate DemonLog inside your callbacks if you want persisted diagnostics.

## Behavior
- Uses `SetTimer` heartbeat at `periodMs` and measures elapsed time via DemonTime/QPC.
- A stall is recorded when `deltaMs > periodMs + toleranceMs`. Each stall increments `hiccups` and triggers `OnStall`.
- `hiccups` decays on healthy ticks, so a demo may show `Stalls detected: 1` with `Final hiccups: 0`.
- If `hiccups >= degradedAfter`, the watchdog enters degraded mode, fires `OnDegradedChanged`, and stays degraded until either:
    - hiccups drop to `recoverBelow` (when `recoverBelow >= 0`), or
    - `ExitDegraded()` is called manually.

## Notes
- Requires Windows because DemonTime relies on QueryPerformanceCounter.
- Logging is optional; include DemonLog if you want persisted diagnostics.
- `Touch()` can be used when external work proves responsiveness without waiting for the next timer tick.

## What to run
- `examples/demo_selftest.ahk`
- `examples/demo_stall_sim.ahk`
- `examples/demo_basic.ahk` (log demo)

See also: DemonTime (timing primitives) and DemonLog (logging helper).
