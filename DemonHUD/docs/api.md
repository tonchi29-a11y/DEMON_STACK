# DemonHUD API

## Class: DemonHUD

### Constructor
`hud := DemonHUD(cfg := 0)`

Config keys (defaults):
- `Width`: 340
- `Height`: 220
- `Margin`: 10
- `Alpha`: 220
- `ClickThrough`: true
- `FontName`: "Consolas"
- `FontSize`: 10
- `BgColor`: "101010"
- `TextColor`: "FFFFFF"

### Methods
- `hud.Show(x := "", y := "") -> bool`
- `hud.Hide()`
- `hud.Close()`
- `hud.IsVisible() -> bool`
- `hud.SetText(text) -> bool`
- `hud.SetOpacity(alpha0to255) -> bool`
- `hud.Start(providerFn, intervalMs := 250)`
  - providerFn is called as `providerFn(hud) -> string`
  - must be non-blocking (timer context)
- `hud.Stop()`
- `hud.GetState() -> Map`
