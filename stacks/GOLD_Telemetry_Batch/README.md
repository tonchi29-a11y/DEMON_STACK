# GOLD_Telemetry_Batch

Telemetry pipeline demo with durable outputs.

Pipeline:
DemonInput → DemonSPSC → DemonEMA → DemonBatchTelemetry (CSV + JSONL)

Also includes:
- DemonHUD (observer UI)
- DemonHotkeys (pause/flush/marker)

## Run
- `stacks/GOLD_Telemetry_Batch/gold_telemetry_batch.ahk`

## Output files
The script writes to `%TEMP%`:
- `demon_telemetry_<pid>_<tick>.csv`
- `demon_telemetry_<pid>_<tick>.jsonl`

Paths are shown in the HUD.

## Hotkeys
- Ctrl+Alt+P — pause/resume writes
- Ctrl+Alt+F — flush now
- Ctrl+Alt+L — marker line + flush
- Esc / F12 — exit
