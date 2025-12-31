# DemonConfigLoader API

## Class: DemonConfigLoader

### Constructor
`loader := DemonConfigLoader(filePath, format := "auto", jsonParseFn := 0)`

- `format`:
  - `auto` (default): uses extension (`.json` => json, otherwise ini)
  - `ini`
  - `json` (requires `jsonParseFn`)

### INI direct access
- `loader.IniGet(section, key, default := "") -> string`
- `loader.IniSet(section, key, value) -> true/false`

### Typed getters (INI read-through)
- `GetStr(section, key, default := "")`
- `GetInt(section, key, default := 0, minVal := "", maxVal := "")`
- `GetFloat(section, key, default := 0.0, minVal := "", maxVal := "")`
- `GetBool(section, key, default := false)`

### Load full config
- `loader.LoadIniAll() -> Map(section -> Map(key -> value))`
- `loader.Load() -> Map/Object`
  - Uses `format` (ini/json)

### JSON (optional)
- `loader.LoadJson() -> Object`
  - Requires `jsonParseFn` (Func/closure) that returns an object.

### Hot reload
- `loader.Watch(onChange, intervalMs := 500)`
  - `onChange(loader, ok, cfgOr0, errMsg)`
- `loader.Unwatch()`
