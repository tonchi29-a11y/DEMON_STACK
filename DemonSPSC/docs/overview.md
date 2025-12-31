# DemonSPSC Overview

## Purpose
DemonSPSC provides a small single-producer / single-consumer ring buffer for AutoHotkey v2.

It is intended for cases where a producer (timer, input callback, message handler) generates high-frequency samples and a consumer loop reads them later.

## Design goals
- Pure AutoHotkey v2 (no DLL dependencies).
- Single-producer / single-consumer semantics.
- Fixed-size items stored in a contiguous ring buffer.
- Capacity rounds up to the next power of two.
- Lightweight health stats (`fill`, `cap`, `drops`).

## Notes
- AutoHotkey is single-threaded, but timers and message handlers interleave; the ring helps decouple producer cadence from consumer work.
- `Push()` returns `false` when the ring is full (drop), and increments `drops`.
- This queue is SPSC (one producer, one consumer). If you push from multiple timers/handlers, you are no longer SPSC—use separate queues per producer or a different design.
