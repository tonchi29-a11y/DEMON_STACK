# DemonPerfInit — Overview

DemonPerfInit packages common “safe init” tweaks into opt-in presets for AutoHotkey v2 scripts.

## Why
High-frequency pipelines (watchdogs, input processing, ML inference) behave more predictably when you:
- remove artificial key/mouse/window delays
- raise hotkey spam limits
- optionally bump process/thread priority

## What it touches
Depending on the preset:
- Delay tuning (`SetKeyDelay`, `SetMouseDelay`, `SetWinDelay`, `SetControlDelay`, `SetDefaultMouseSpeed`)
- Hotkey throttling (`A_HotkeyInterval`, `A_MaxHotkeysPerInterval`)
- Process priority class (`SetPriorityClass`) — best-effort
- Current thread priority (`SetThreadPriority`) — best-effort

## Safety
- Presets are opt-in; call `ApplyPreset()` once at startup.
- `Restore()` is best-effort: only values we captured (hotkey limits + priorities when readable) are restored.
- No admin required; failures are swallowed and reported via the token map.

## Presets (v1)
- `SAFE`: mild bump (AboveNormal / thread +1). Note: `SAFE` may not change `A_HotkeyInterval` if your default is already 2000; it mainly raises `A_MaxHotkeysPerInterval`.
- `MATCH`: high-priority preset (High / thread +2)
- `ULTRA`: same as MATCH for now (placeholder for future tuning)
