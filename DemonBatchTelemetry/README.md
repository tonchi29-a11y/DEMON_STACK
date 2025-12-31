# DemonBatchTelemetry (AHK v2)

Batch telemetry writer for input samples (tMs, dx, dy, src).

This library is split by format so it’s obvious what you’re choosing:
- CSV (`src/csv/`) — fastest, simplest, best for Excel/quick charts
- JSONL (`src/jsonl/`) — structured, best for data pipelines, slightly heavier
- CSV+JSONL (`src/csv_jsonl/`) — write both from one recording session

## Quick start
Run:
- `examples/csv/demo_selftest.ahk`
- `examples/jsonl/demo_selftest.ahk`

## Recording examples
- `examples/csv/demo_record_timerlane.ahk`
- `examples/csv/demo_record_rawlane.ahk`
- `examples/csv_jsonl/demo_record_both.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
