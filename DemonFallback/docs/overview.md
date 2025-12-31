# DemonFallback Overview

DemonFallback is a tiny, reusable policy/state-machine module.

It takes a set of optional numeric signals (e.g., jitter p95, watchdog hiccups, bridge read failures), and returns:
- a `mode` string (`NORMAL`, `DEGRADED`, `FALLBACK`)
- a `knobs` map (integration-defined rates/flags)
- debug state (`trips`, `reason`, timing/cooldown)

## What it is
- A deterministic policy engine you call from your core tick.

## What it is NOT
- Not a timer/worker manager.
- Not a hardware/game/rawaccel-specific module.
- Not a dependency magnet (no required includes).

## Typical wiring
- Feed `jitterP95Ms` from DemonJitter `GetStats()["p95"]`.
- Feed `watchdogHiccups` from DemonWatchdog `hiccups`.
- Feed `bridgeFail` from integration-defined failure signals (e.g. `crcFails + readRetries`).

Your integration layer decides what `knobs` mean (work interval, HUD refresh, bridge cadence, predictor decimation, timer resolution, etc.).
