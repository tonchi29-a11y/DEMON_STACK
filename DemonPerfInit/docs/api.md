# DemonPerfInit API

## `DemonPerfInit.ApplyPreset(name := "MATCH") -> token`
Applies a named preset and returns a token Map for best-effort restore.

Token schema:
- `preset`: preset name (`SAFE`, `MATCH`, `ULTRA`)
- `old`: captured values (`HotkeyInterval`, `MaxHotkeysPerInterval`, `ProcessPriority`, `ThreadPriority` when available)
- `applied`: per-setting success flags (`ProcessPriority`, `ThreadPriority`, `SetDelays`, etc.)

No exception is thrown when OS APIs reject the change; success flags reflect the outcome.

## `DemonPerfInit.Restore(token) -> true`
Restores what was captured in the token:
- `A_HotkeyInterval`
- `A_MaxHotkeysPerInterval`
- Process priority class via `SetPriorityClass` (if readable)
- Thread priority (best-effort)

Delay tuning isn’t restored in v1. Callers can re-apply their own defaults if needed.

## Helpers (internal)
- `_ApplyDelayTuning()` — fast `Set*Delay` values
- `_GetCurrentThreadPriority()` / `_SetCurrentThreadPriority()` — call Win32 APIs
- `_TryGetProcessPriority()` — uses `ProcessGetPriority()` when supported
