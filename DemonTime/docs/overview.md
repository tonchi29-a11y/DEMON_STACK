# DemonTime Overview

## Quick start
- Run `examples/demo_selftest.ahk` to confirm QPC access works on your machine.

## What it is
DemonTime is a tiny AutoHotkey v2 utility that wraps Windows QueryPerformanceCounter (QPC) and provides a few helpers for measuring elapsed time.

## Typical usage
- Capture a start counter with `NowQpc()`.
- Convert elapsed time using `MsSince()` or `SecSince()`.
- Use `Tick()` when you only need coarse elapsed time and can tolerate wraparound.

## Notes
- QPC is provided by Windows; if the QPC APIs fail, DemonTime throws an error.
- DemonTime is user-mode only and does not perform any environment checks beyond calling the Windows timer APIs.
- Requires Windows (uses QueryPerformanceCounter).
