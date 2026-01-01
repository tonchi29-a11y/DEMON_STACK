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

## JSONL schema

Each line is one JSON object:

{"tMs":49083062,"dx":0.0,"dy":0.0,"src":"timer"}

Notes:
- Encoding: UTF-8
- Newline: CRLF (\r\n)
- Fields:
	- `tMs` (u32/u64 timestamp)
	- `dx`, `dy` (float)
	- `src` (string: "timer"/"raw"/custom)

Style Contract reminder:
- Do not embed literal newlines inside `Format()` strings when writing JSONL.
- Append the newline outside the format string, e.g.:

```ahk2
text .= Format('{"tMs":{1},"dx":{2},"dy":{3},"src":"{4}"}', t, dx, dy, src) . "`r`n"
```
