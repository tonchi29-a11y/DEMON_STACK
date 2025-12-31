# DemonContextDetect (AHK v2)

Pure, allocation-light context classifier for mouse/motion streams.

Consumes motion deltas and outputs:
- `context`: `Idle` / `LongRange` / `CloseRange`
- `confidence`: `0..1`
- feature snapshot (`vel`, `avgSpeed`, `hvRatio`, `spike`)

Key design points:
- No OS side-effects (no threads, no raw input, no file I/O)
- Deterministic + testable (feed synthetic samples)
- Hardware/game agnostic (works with raw deltas or EMA-smoothed deltas)

## Quick start
Run:
- `examples/demo_selftest.ahk`
- `examples/demo_live_input_ema.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
