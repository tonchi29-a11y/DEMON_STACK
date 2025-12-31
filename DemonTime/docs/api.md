# DemonTime API

## Quick start
- Run `examples/demo_selftest.ahk`.

## Class: DemonTime

### `DemonTime.Freq()`
Returns the QPC frequency (ticks per second) as an `int64`. Cached after the first call.

### `DemonTime.NowQpc()`
Returns the current QPC counter value as an `int64`.

### `DemonTime.MsSince(qpcStart)`
Returns elapsed milliseconds since `qpcStart` as a floating-point value.

### `DemonTime.SecSince(qpcStart)`
Returns elapsed seconds since `qpcStart` as a floating-point value.

### `DemonTime.Tick()`
Returns `A_TickCount` (milliseconds, 32-bit wrap). Useful for coarse timing; wraps roughly every 49.7 days (~2^32 milliseconds).

### `DemonTime.MeasureSleep(ms)`
Sleeps for `ms` milliseconds and returns the measured elapsed time in milliseconds using QPC.

## Errors
If QPC APIs fail, `Freq()` / `NowQpc()` throw an `Error`:
- `QueryPerformanceFrequency failed`
- `QueryPerformanceCounter failed`
