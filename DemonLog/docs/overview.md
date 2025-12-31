# DemonLog Overview

## Quick Start
- Follow the [README.md in this repo](../README.md#quick-start) to include the library and initialize it once.
- Keep configuration objects nearby so you can reuse them across scripts that share logging conventions.
- Run `examples/demo_selftest.ahk` first if you are testing from a protected directory.

## Design Goals
- Provide a single-file AutoHotkey v2 logger that works without external dependencies.
- Offer consistent formatting, rotation, and rate limiting without tying into project-specific globals.
- Fail safely: errors during disk writes are swallowed after best-effort retries so callers stay responsive.

## Design Constraints
DemonLog is a user-mode logger that appends to files on a best-effort basis. It is designed so logging failures do not crash the main script; file I/O errors are caught and ignored, except where you may intentionally surface them during development by adding your own checks around return values.

## Architecture
- **Static class**: `DemonLog` stores configuration and buffers in static members so any script file can log after `#Include`.
- **Buffered writer**: `Log()` adds formatted lines to an in-memory string. `__MaybeFlush()` pushes data to disk based on buffer size or elapsed time.
- **Rotation helper**: `__RotateIfNeeded()` compares the active file against `MaxBytes`. When the limit is reached the file is moved to `*.bak`, and logging resumes in a fresh file.
- **Rate limiting**: `SmartLog()` associates a timestamp with each `(level,key)` pair using a `Map()`. Calls made before the interval expires are ignored.
- **Auto-flush timer**: `StartAutoFlush()` registers a bound method with `SetTimer`, ensuring periodic flushes even when no new events are emitted.

## Typical Workflow
1. Call `DemonLog.Init()` once with your preferred defaults.
2. Emit structured text through `Log()` for normal events and `SmartLog()` for noisy ones.
3. Use `SafeLog()` in exception handlers when the buffered logger might not have flushed yet.
4. During shutdown, either rely on auto-flush or call `DemonLog.Shutdown()` explicitly to stop timers and push remaining bytes.

## Safety
- Directory creation and rotation steps remain inside the configured `LogPath` tree and catch failures individually.
- Auto-flush timers are always cleared by `StopAutoFlush()` and `Shutdown()` so no orphaned callbacks keep the script alive.
- `SmartLog()` defaults to deterministic keys (`level:message`) to avoid unbounded cache growth when callers do not provide a custom key.

## Benchmarks methodology
DemonLog does not ship timing data. When comparing settings:
1. Note your buffer size, flush interval, rotation threshold, and AutoHotkey version.
2. Surround the code you want to observe with `A_TickCount` snapshots.
3. Capture the number of log lines written so results can be repeated.
