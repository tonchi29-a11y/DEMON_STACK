# DemonWatchdog API

## Dependencies
- AutoHotkey v2
- DemonTime (must be `#Include`d before using DemonWatchdog)
- DemonLog is optional for logging

## Constructor
`wd := DemonWatchdog(periodMs := 250, toleranceMs := 120, degradedAfter := 3, recoverBelow := 2)`
- `periodMs`: Expected heartbeat interval (ms) used for `SetTimer`.
- `toleranceMs`: Allowable extra latency before declaring a stall.
- `degradedAfter`: Stall count required to enter degraded mode.
- `recoverBelow`: Hiccup count threshold to auto-exit degraded mode.
	- If `recoverBelow` is `-1`, the watchdog will not auto-exit degraded mode.

## Methods
- `Start()`: Begins the heartbeat timer. Resets counters and records the initial QPC timestamp.
- `Stop()`: Stops the heartbeat timer. Safe to call multiple times.
- `Touch()`: Resets the internal baseline to "now"—useful when you intentionally blocked the script.
- `IsDegraded()`: Returns `true` if the watchdog is currently in degraded mode.
- `EnterDegraded(reason := "")`: Forces degraded mode and triggers callbacks (idempotent).
- `ExitDegraded(reason := "")`: Leaves degraded mode if active.

## Properties
- `periodMs`, `toleranceMs`, `degradedAfter`, `recoverBelow`
- `hiccups`: Current stall counter (increments on stalls, decreases on healthy ticks).
- `lastDeltaMs`: Last measured interval (float milliseconds).
- `OnStall`: Optional callback invoked as `OnStall(wd, deltaMs, thresholdMs)`.
- `OnDegradedChanged`: Optional callback invoked as `OnDegradedChanged(wd, isDegraded, reason := "")`.

## Stall detection
- Every heartbeat measures elapsed time using two QPC reads via DemonTime (`NowQpc()` delta converted to milliseconds).
- Stall condition: `deltaMs > periodMs + toleranceMs`.
- On stall: increment `hiccups`, invoke `OnStall`.
- On healthy tick: decrement `hiccups` down to zero.

## Degraded mode logic
- Enter: when `hiccups >= degradedAfter`.
- Exit: when `recoverBelow >= 0` and `hiccups <= recoverBelow` during healthy ticks, or after manual `ExitDegraded()`.
- `OnDegradedChanged` receives `(wd, true/false, reason)` when state toggles.

## Errors
- If DemonTime is not loaded, constructing the watchdog throws:
	`Error("DemonWatchdog requires DemonTime. Include DemonTime.ahk first.")`
- Callback exceptions are caught to avoid breaking the watchdog.
