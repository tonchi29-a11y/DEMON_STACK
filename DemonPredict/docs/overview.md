# DemonPredict Overview

DemonPredict is a pure decision engine that converts motion context + features into an ADS/HPR decision.

## Inputs
Typically fed from DemonContextDetect:
- `context`, `confidence`, `vel`, `avgSpeed`, `hvRatio`, `spike`

## Output
- `adsProb` (0..1)
- `desired` profile ("ADS" or "HPR")
- Schmitt thresholds + TAU timers reduce flapping

## Notes
- No OS calls, no timers, no I/O.
- Caller decides how often to call `Update()` (decimation is external).
