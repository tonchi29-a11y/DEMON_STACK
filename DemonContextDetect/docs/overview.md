# Overview

`DemonContextDetect` classifies a motion stream into a small, reusable set of contexts:

- `Idle`
- `LongRange`
- `CloseRange`

It is designed to be a clean bridge between:
- a signal pipeline (raw input → SPSC → EMA)
- higher-level logic (predictors, profile switching, etc.)

## Inputs
Call `Update(dx, dy, dtMs)` per sample.

- `dx`, `dy`: motion deltas for the sample window
  - can be raw deltas, or already smoothed (EMA)
- `dtMs`: elapsed time for the sample window in milliseconds

## Features (v1)
Computed per update:
- `vel`: $\sqrt{dx^2 + dy^2} / dtMs$ (counts per ms)
- `avgSpeed`: EMA of `vel` with time constant `TauAvgMs`
- `hvRatio`: `abs(dx) / (abs(dy) + HvEps)`
- `spike`: `vel / avgSpeed`

## Hysteresis
To prevent flapping, `HoldMs` enforces a minimum time in the current context before switching.
