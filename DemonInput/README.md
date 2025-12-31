# DemonInput (AutoHotkey v2)

Generic input sampler for AutoHotkey v2 that emits `(dx, dy, tMs, source)` samples via a callback.

This library is intentionally minimal:
- No ring buffer / queue inside (caller decides where to push)
- No smoothing inside (caller decides how to filter)

## Quick start
Run:
- `examples/demo_selftest.ahk`

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonInput.ahk

OnSample(dx, dy, tMs, source) {
    ; Keep this fast. Avoid blocking UI here.
}

inp := DemonInput(OnSample)

; Lane A: timer-based deltas
inp.StartTimerLane(4)

; Lane B: raw input (mouse)
; inp.StartRawInputLane(A_ScriptHwnd, true, true) ; inputSink + aggregate
```

## Notes
- Callbacks run on the script thread (timer/message context). Keep them fast.
- RawInput is Windows-only and requires a target window handle (`hwnd`).
  - Using `A_ScriptHwnd` registers the script’s hidden main window.
  - With an input-sink registration, input can be received even without focus.

Run the examples:
- `examples/demo_timer_lane.ahk`
- `examples/demo_rawinput_lane.ahk`
- `examples/demo_dual_lane_spsc_ema.ahk`
- `examples/demo_selftest.ahk`
