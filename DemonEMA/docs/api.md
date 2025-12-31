# DemonEMA API

## Class: DemonEma

### Constructor
- `ema := DemonEma(tauMs := 25.0, fixedAlpha := 0.12)`
  - If `tauMs > 0`, dt-based alpha is used.
  - If `tauMs <= 0`, fixed alpha mode is used (alpha clamped to `[0, 1]`).

### Methods
- `ema.Reset(x := 0.0, y := 0.0)`
  - Resets state and clears the internal timestamp baseline used by `UpdateSample()`.

- `a := ema.Update(dx, dy, dtMs)`
  - Updates the EMA using an explicit `dtMs` (milliseconds).
  - Returns the alpha used for the update.

- `a := ema.UpdateSample(dx, dy, tMs)`
  - Convenience wrapper that computes `dtMs` from consecutive timestamps.
  - First call sets the baseline and returns `0.0` (no update).

- `a := ema.AlphaFromDt(dtMs)`
  - Computes the alpha used for a given `dtMs`.
  - dt-based alpha: `a = 1 - exp(-dt/tau)`
  - fixed alpha: `a = clamp(fixedAlpha, 0, 1)`

- `ema.X()`, `ema.Y()`
  - Read current smoothed values.
