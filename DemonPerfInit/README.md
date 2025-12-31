# DemonPerfInit (AHK v2)

Opt-in “safe init / performance presets” for AutoHotkey v2.

## Quick start
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonPerfInit.ahk

token := DemonPerfInit.ApplyPreset("MATCH")
; ... run your script ...
DemonPerfInit.Restore(token) ; best-effort
```

## Examples
- `examples/demo_selftest.ahk`
- `examples/demo_apply_and_restore.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`

## Notes
- Presets are opt-in; don’t auto-apply in shared libraries.
- Restore is best-effort; only values captured in the token are restored.
- No admin required; OS-level failures are swallowed and reflected via token flags.
- `SAFE` may not change `A_HotkeyInterval` if your default is already 2000; it mainly raises `A_MaxHotkeysPerInterval`.
