# DemonPredict Overview

DemonPredict is a pure AHK v2 decision engine that converts motion context and feature signals into an ADS/HPR choice.

## What it does
- Computes `adsProb` (0..1) from context/features.
- Applies Schmitt thresholds (`T_ON/T_OFF`) and TAU timers (`TAU_ON_MS/TAU_OFF_MS`) plus cooldown to prevent flapping.
- Outputs `desired` ("ADS" or "HPR") with `changed` and `reason`.

## What it does not do
- No timers, no I/O, no OS calls.
- Does not switch profiles itself; it only produces decisions.

## Pipeline position
Typical wiring:
DemonInput → DemonSPSC → DemonEMA → DemonContextDetect → DemonPredict → (your profile switcher / bridge)

## Operational notes
- Caller controls cadence via `dtMs` and `nowMs`.
- Use a monotonic millisecond clock for `nowMs` (e.g. `A_TickCount`).
- Callback `OnDecisionChanged` must be non-blocking (timer/message context friendly).

## Integration snippet
```ahk2
st := ctx.GetState()
r := pred.Update(st["context"], st["confidence"], st["vel"], st["avgSpeed"], st["hvRatio"], st["spike"], rmbDown, dt, now)
if r["changed"] {
    ; switch profile outside this library
}
```
