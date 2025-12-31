# DemonConfigLoader (AHK v2)

Config loader for AutoHotkey v2 with typed getters and optional hot reload.

## Quick start
Run:
- `examples/demo_selftest.ahk`

## INI usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonConfigLoader.ahk

loader := DemonConfigLoader("settings.ini", "ini")
enabled := loader.GetBool("General", "Enabled", false)
rate := loader.GetInt("General", "Rate", 10, 1, 100)
```

## Hot reload
See:
- `examples/demo_hot_reload.ahk`

## Docs
- `docs/api.md`
- `docs/overview.md`
