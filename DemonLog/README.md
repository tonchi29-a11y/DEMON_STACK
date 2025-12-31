# DemonLog

## Quick Start
1. Copy the `DemonLog` folder anywhere in your AutoHotkey v2 workspace.
2. Include the library in your script using a relative path: `#Include <path-to>/DemonLog/src/DemonLog.ahk`.
3. Call `DemonLog.Init({ LogPath: A_ScriptDir "\\app.log" })` once during startup.
4. Use `DemonLog.Log()` or `DemonLog.SmartLog()` throughout your script. Call `DemonLog.Shutdown()` before exiting if you need an explicit flush.

## Usage Snippet
```ahk2
#Requires AutoHotkey v2.0
#Include ..\DemonLog\src\DemonLog.ahk

DemonLog.Init({
    LogPath: A_ScriptDir "\\example.log",
    Level: "INFO",
    BufferBytes: 4096,
    FlushIntervalMs: 2000,
    EnableRotation: true,
    MaxBytes: 512000,
    AutoFlushMs: 1000
})

DemonLog.Log("INFO", "Service started")
DemonLog.SmartLog("WARN", "Intermittent warning", 2500)
; ... application logic ...
DemonLog.Shutdown()
```

## Self-test (recommended)
If you want to verify DemonLog works on your machine (and avoid folder permission issues), run:

- `examples/demo_selftest.ahk`

This test writes to `A_Temp` to ensure the log path is writable even if the repo is located in a protected folder (e.g. Program Files).

## FlushIntervalMs vs AutoFlushMs
- `FlushIntervalMs`: time-based flush checked during `Log()` calls.
- `AutoFlushMs`: timer-based flush even if no new logs happen.

## Feature Highlights
- Log levels (`ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`) with runtime adjustment via `SetLevel()`.
- Buffered writes with optional periodic or size-based flushing.
- Opt-in size-based rotation moves the current log to `*.bak` and continues in a fresh file.
- `SmartLog()` helper that rate-limits repeated entries using a per-key timer.
- `SafeLog()` fallback for emergency disk writes when buffering is disabled.
- Auto-flush timer management for scripts that prefer passive maintenance.

Note: `SmartLog()` defaults its key to `LEVEL:message`. If your message includes changing values (e.g. counters or timestamps), consider passing an explicit `key` to avoid growing the rate-limit cache.

## Safety
- File I/O is limited to the configured `LogPath` and its `.bak` rotation file; the library does not touch the registry or privileged APIs.
- Rotation and deletion operations happen inside that directory and catch failures to avoid crashing the host script.
- All logging calls guard against uninitialized use by bootstrapping the default configuration on demand.

## Benchmarks methodology
No formal benchmarks are provided. If you need measurements, capture wall-clock time around `DemonLog.Log()` and `DemonLog.Flush()` under your workload, noting buffer sizes and flush intervals for reproducibility.
