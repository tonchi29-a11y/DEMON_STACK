# DemonBatchTelemetry API

This library is split by output format.

## CSV
### Class: DemonBatchTelemetryCsv
Constructor:
- `bt := DemonBatchTelemetryCsv(filePath, capacity := 4096, flushEvery := 256, writeHeader := true)`

Methods:
- `bt.Add(tMs, dx, dy, source := "") -> true/false`
- `bt.Flush() -> true/false`
- `bt.StartAutoFlush(intervalMs := 1000)`
- `bt.StopAutoFlush()`
- `bt.GetState() -> Map`

## JSONL
### Class: DemonBatchTelemetryJsonl
Constructor:
- `bt := DemonBatchTelemetryJsonl(filePath, capacity := 4096, flushEvery := 256)`

Methods:
- `bt.Add(tMs, dx, dy, source := "") -> true/false`
- `bt.Flush() -> true/false`
- `bt.StartAutoFlush(intervalMs := 1000)`
- `bt.StopAutoFlush()`
- `bt.GetState() -> Map`

## CSV + JSONL
### Class: DemonBatchTelemetryCsvJsonl
Constructor:
- `bt := DemonBatchTelemetryCsvJsonl(csvPath, jsonlPath, capacity := 4096, flushEvery := 256)`

Methods:
- `bt.Add(tMs, dx, dy, source := "") -> true/false`
- `bt.Flush() -> true/false`
- `bt.StartAutoFlush(intervalMs := 1000)`
- `bt.StopAutoFlush()`
- `bt.GetState() -> Map`
