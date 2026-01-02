# DemonHotkeys API

## Class: DemonHotkeys

### Constructor
`hk := DemonHotkeys(cfg := 0)`

Config defaults:
- `SwallowCallbackErrors`: true
- `ThrowOnRegisterError`: false

### Add
`id := hk.Add(keyName, callback, options := "")`

- `keyName`: string hotkey (e.g. `^!h`)
- `callback`: function object, called as `callback(keyName)`
- `options`: passed to `Hotkey()` (optional)

Returns:
- `id` (integer) used for `Remove(id)`.

### Enable / Disable
- `hk.Enable()`
- `hk.Disable()`

### Remove / Clear
- `ok := hk.Remove(id) -> bool`
- `hk.Clear()`

Notes:
- `Remove()` is best-effort. It disables the hotkey and removes it from the manager.

### State
`st := hk.GetState() -> Map`

Returns keys:
- `enabled` (bool)
- `count` (int)
- `fires` (int)
- `errors` (int)

### Optional callback
- `hk.OnHotkeyFired := Fn`
- `Fn(hk, keyName)` must be non-blocking.
