# DemonHUD (AHK v2)

Small overlay HUD for displaying multi-line status text. Designed as a UI observer layer.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonHUD.ahk

hud := DemonHUD()
hud.Show(20, 20)
hud.SetText("Hello`nworld")
```

## Examples
- `examples/demo_selftest.ahk`
- `examples/demo_live_basic.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`

## License
MIT (see `LICENSE`).
