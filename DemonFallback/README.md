# DemonFallback (AHK v2)

Pure policy/state-machine helper that consumes numeric “signals” and outputs a `mode` + recommended “knob preset” map.

Key design points:
- No OS side-effects: no timers, threads, affinity, raw input, or file I/O.
- Deterministic + testable: feed signals, assert mode transitions.
- Integration-friendly: works with DemonWatchdog/DemonJitter/DemonBridge, but does not depend on them.

## Quick start
Run:
- `examples/demo_selftest.ahk`
- `examples/demo_watchdog_jitter_policy.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
