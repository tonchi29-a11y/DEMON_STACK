# DemonSPSC (AutoHotkey v2)

A small **single-producer / single-consumer** ring buffer for AutoHotkey v2.

This library is designed for high-frequency pipelines (e.g. timer input producer  consumer smoothing loop).

## Quick start
Run:
- `examples/demo_selftest.ahk`

## API
- `q := DemonSpscRing(capacity)`
- `q.Push(dx, dy, t64) -> true/false`
- `q.Pop(&dx, &dy, &t64) -> true/false`
- `q.Clear()`
- `q.GetHealth() -> Map(fill, cap, drops)`

## Notes
AutoHotkey is single-threaded, but timers and message handlers interleave. This ring buffer still matters because it decouples producer cadence from consumer work and provides drops/health visibility.
