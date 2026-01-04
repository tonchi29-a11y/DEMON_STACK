# DemonReadyFlag (AHK v2)

A tiny shared-memory ready flag for coordinating processes.

## Files
- `src/DemonReadyFlag.ahk` — library
- `examples/demo_selftest.ahk` — selftest
- `docs/overview.md`, `docs/api.md`

## Quick start
```ahk
#Include DemonReadyFlag\src\DemonReadyFlag.ahk

flag := DemonReadyFlag("Local\MyAppReady")
flag.SetReady(true)
; ... in another process ...
if flag.IsReady() {
    ; proceed
}
```
