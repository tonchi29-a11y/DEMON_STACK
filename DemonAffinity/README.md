# DemonAffinity (AHK v2)

Small CPU affinity helper for AutoHotkey v2.

## Quick start
Run the self-test demo:
- `examples/demo_selftest.ahk`

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonAffinity.ahk

mask := DemonAffinity.MakeMask(2, 4)
if !DemonAffinity.SetCurrentProcess(mask)
    MsgBox "Failed to set process affinity"
; Consider storing the original via GetCurrentProcess() and restoring it on exit.
```

## Docs
- docs/overview.md
- docs/api.md

## Notes
- v1 supports <= 64 logical processors (single processor group).
- No admin required, but Windows may reject affinity changes in restricted environments.
