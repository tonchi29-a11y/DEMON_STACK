# DemonInput API

## Class: DemonInput

### Constructor
- `inp := DemonInput(onSample)`
  - `onSample(dx, dy, tMs, source)` is a callback invoked on each emitted sample.
  - `tMs` is `A_TickCount` (wraps as a 32-bit tick count). If you need long-running monotonic timing, use DemonTime/QPC in the caller.
  - `source` is one of: `"timer"`, `"raw"`.

### Methods
- `inp.StartTimerLane(sampleMs := 4)`
  - Starts timer-based sampling using `MouseGetPos` deltas.
  - Emits samples with `source = "timer"` and `tMs = A_TickCount`.

- `inp.StartRawInputLane(hwnd := A_ScriptHwnd, inputSink := false, aggregatePerTick := true)`
  - Registers for raw mouse input and listens for `WM_INPUT`.
  - Installs a `WM_INPUT` handler and restores the previous handler on `Stop()`.
  - Emits samples with `source = "raw"` and `tMs = A_TickCount`.
  - `inputSink`:
    - `false` (default): typically receives raw input when the script/window is eligible/foreground.
    - `true`: registers as an input sink so the script can receive raw input even without focus (Windows behavior).
  - `aggregatePerTick`:
    - If true, multiple raw events within the same `A_TickCount` tick are accumulated and flushed once per tick.

- `inp.Stop()`
  - Stops the timer lane (if running) and unregisters raw input (if running).

- `state := inp.GetState()`
  - Returns a `Map` with basic counters and the last emitted sample.

### State map keys
- `lane`: `"stopped"`, `"timer"`, `"raw"`, or `"timer+raw"`
- `timerRunning`, `rawRunning`
- `samplesTimer`, `samplesRaw`, `samplesTotal`
- `lastDx`, `lastDy`, `lastTms`, `lastSource`
