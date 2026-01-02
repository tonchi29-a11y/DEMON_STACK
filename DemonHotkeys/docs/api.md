# DemonHotkeys API

## Class: DemonHotkeys

### Constructor
`hk := DemonHotkeys(cfg := 0)`

Config defaults:
- `SwallowCallbackErrors`: true
- `ThrowOnRegisterError`: false

### Add
`index := hk.Add(keyName, callback, options := "")`

- `keyName`: string hotkey (e.g. `^!h`)
- `callback`: function object, called as `callback(keyName)`
- `options`: passed to `Hotkey()` (optional)

Returns:
- `index` (1-based integer) used by `Remove(index)`.

### Enable / Disable
- `hk.Enable() -> true`
- `hk.Disable() -> true`

### Remove
`ok := hk.Remove(index) -> bool`

Notes:
- Index is 1-based (the value returned by `Add()`).
- Remove is best-effort:
	- disables the hotkey (`Hotkey(key, "Off")`)
	- attempts to delete/unregister (`Hotkey(key, "Delete")`) if supported by the runtime
- If a key was already removed or index is invalid, returns false.

### Clear
`hk.Clear()`

Best-effort unregisters all hotkeys, clears internal list, and disables the manager.

### State
`st := hk.GetState() -> Map`

Returns keys:
- `enabled` (bool)
- `count` (int): active hotkeys count
- `fires` (int)
- `errors` (int)

### Optional callback
- `hk.OnHotkeyFired := Fn`
- `Fn(hk, keyName)` must be non-blocking.

Reference:
- AutoHotkey v2 `Hotkey()`: https://www.autohotkey.com/docs/v2/lib/Hotkey.htm
