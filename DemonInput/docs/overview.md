# DemonInput Overview

DemonInput is a small input sampling helper for AutoHotkey v2.

## Scope (v1)
DemonInput emits samples via a callback:
- `(dx, dy, tMs, source)`

`tMs` is `A_TickCount`, which wraps as a 32-bit tick count. If you need long-running monotonic timing, use DemonTime/QPC in the caller.

It provides two optional lanes:
- **Timer lane**: uses `MouseGetPos` deltas at a fixed sampling interval.
- **RawInput lane**: uses `WM_INPUT` to read raw mouse deltas.

The library does not include buffering (SPSC) or smoothing (EMA); those are caller concerns.

## Callback guidelines
Callbacks run on the script thread (timer/message context). Keep them fast.

Avoid blocking UI (e.g. `MsgBox`) inside `onSample`. Blocking pauses the script thread, prevents timers from running, and can create additional stalls or distorted sampling.

## RawInput notes
- Windows-only.
- Requires a target window handle to register raw input (commonly `A_ScriptHwnd`).
- If you enable `inputSink`, the script may receive raw input even when not focused.
- Raw input delivery depends on registration flags and focus behavior; use it when you need high-frequency deltas with less pointer acceleration/OS filtering.
