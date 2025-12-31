# DemonJitter (AHK v2)

Fixed-size jitter/latency tracker with percentile stats.

## Quick start
Run:
- `examples/demo_selftest.ahk`

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonJitter.ahk

j := DemonJitter(256)
j.Add(0.42)
st := j.GetStats()
MsgBox "p95=" st["p95"]
```

## Examples
- `examples/demo_selftest.ahk`
- `examples/demo_live_measure.ahk` (uses DemonTime)
- `examples/demo_trip_watch.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
