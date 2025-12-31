# DemonEMA Overview

DemonEMA is a tiny EMA (exponential moving average) helper for AutoHotkey v2.

## Goals
- Standalone, pure AHK v2.
- Smooth 2D signals (`x`, `y`) using an EMA.
- Supports:
  - dt-based alpha using a time constant (`tauMs`): `a = 1 - exp(-dt/tau)`
  - fixed alpha fallback (`fixedAlpha`) when `tauMs <= 0`

## Notes
- dt-based alpha makes smoothing stable across variable update rates.
- `UpdateSample()` computes `dt` from timestamps; the first call sets a baseline and does not update.
