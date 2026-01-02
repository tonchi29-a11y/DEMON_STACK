# DemonHotkeys (AHK v2)

Hotkey registration + enable/disable manager for small controller scripts.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
```ahk
#Requires AutoHotkey v2.0
#Include ..\src\DemonHotkeys.ahk

hk := DemonHotkeys()
id := hk.Add("^!q", (name) => ExitApp())
hk.Enable()
```

## Examples
- `examples/demo_selftest.ahk`
- `examples/demo_live_basic.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`

## License
MIT (see `LICENSE`).
