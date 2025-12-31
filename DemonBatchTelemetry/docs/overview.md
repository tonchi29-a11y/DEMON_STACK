# DemonBatchTelemetry Overview

DemonBatchTelemetry records input samples (tMs, dx, dy, src) into a fixed-size ring and flushes them to disk in batches.

## Formats
- CSV: fastest, simplest, best for Excel/quick charts.
- JSONL: structured, best for data pipelines, slightly heavier.
- CSV+JSONL: write both from one recording session.

## Design
- Deterministic batching: no background threads.
- Optional timer-based auto-flush (poll-style) for long recordings.
- Drop counter when the ring is full (new samples overwrite nothing; they are counted as dropped until next flush).

## Typical use
- Record Timer lane or RawInput lane samples via DemonInput.
- Flush periodically (every N samples and/or with an auto-flush timer).
