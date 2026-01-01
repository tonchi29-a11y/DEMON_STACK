# DemonBatchTelemetry (AHK v2)

Batch telemetry writer for input samples (`tMs`, `dx`, `dy`, `src`).

This library is split by format so it’s obvious what you’re choosing:
- CSV (`src/csv/`) — fastest, simplest, best for Excel/quick charts
- JSONL (`src/jsonl/`) — structured, best for data pipelines, slightly heavier
- CSV+JSONL (`src/csv_jsonl/`) — write both from one recording session

## Quick start
Run:
- `examples/demo_selftest.ahk` (root entrypoint: validates CSV + JSONL)

## Usage
Pick one writer (CSV or JSONL), call `Add()` per sample, then `Flush()` periodically.

```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\csv\DemonBatchTelemetryCsv.ahk
; #Include ..\src\jsonl\DemonBatchTelemetryJsonl.ahk

bt := DemonBatchTelemetryCsv(A_Temp "\\samples.csv", 4096, 256, true)
; bt := DemonBatchTelemetryJsonl(A_Temp "\\samples.jsonl", 4096, 256)

bt.Add(A_TickCount, 1.0, -2.0, "timer")
bt.Add(A_TickCount, 0.0, 0.0, "raw")
bt.Flush()
```

Notes:
- `StartAutoFlush(intervalMs := 1000)` uses an AutoHotkey timer to call `Flush()` periodically.
- If you want fully deterministic behavior, don’t use auto-flush; call `Flush()` yourself.

## Examples
- CSV
	- `examples/csv/demo_selftest.ahk`
	- `examples/csv/demo_record_timerlane.ahk`
	- `examples/csv/demo_record_rawlane.ahk`
- JSONL
	- `examples/jsonl/demo_selftest.ahk`
- CSV + JSONL
	- `examples/csv_jsonl/demo_record_both.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
