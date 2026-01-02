# DEMON_STACK (AHK v2)

This repository contains reusable AutoHotkey v2 libraries extracted from DEMON, plus “Gold Standard” stack demos that show how to combine them.

## Base libraries
- DemonLog — buffered logging + rotation + SmartLog
- DemonTime — QPC timing helpers
- DemonJitter — fixed-size latency/jitter tracker + percentile stats
- DemonConfigLoader — INI-first config loader + typed getters + poll-based hot reload
- DemonBatchTelemetry — batch telemetry writers (CSV / JSONL / both)
- DemonWatchdog — stall detection + degraded mode signaling
- DemonSPSC — SPSC ring buffer (dx,dy,t64)
- DemonEMA — dt-based EMA smoothing
- DemonContextDetect — motion context classifier (Idle/Long/Close + confidence)
- DemonInput — dual lane input sampling (Timer + RawInput)
- DemonPredict — ADS/HPR decision engine driven by context/features
- DemonNeuromorphic — leaky integrate-and-fire spikes (boost/trigger helper)
- DemonChaos — Lorenz-inspired chaos score + cooldown bias
- DemonQuantumBuffer — probabilistic accumulator + collapse gate
- DemonTimerRes — system timer resolution request (timeBeginPeriod/timeEndPeriod)
- DemonAffinity — CPU affinity mask builder + process/thread pin helpers
- DemonPerfInit — opt-in performance presets + best-effort restore token
- DemonBridge — shared memory IPC (seqlock + CRC32, cache-aligned)
- DemonPack64 — fixed 64-byte payload pack/unpack helpers
- DemonFallback — policy wrapper for watchdog-driven fallbacks
- DemonHUD — small overlay HUD for status text
- DemonHotkeys — hotkey registration + enable/disable manager


## Quick start
Each library provides a selftest entrypoint. Examples:
- DemonLog: `DemonLog/examples/demo_selftest.ahk`
- DemonBatchTelemetry: `DemonBatchTelemetry/examples/demo_selftest.ahk`
- DemonContextDetect: `DemonContextDetect/examples/demo_selftest.ahk`


## Gold stacks

### GOLD_Bridge_SHM
Folder: `stacks/GOLD_Bridge_SHM/`

Pipeline:
Input → SPSC → EMA → Pack64 → Bridge.Write  
Bridge.Read → Pack64.Unpack → display

Run:
1) `stacks/GOLD_Bridge_SHM/gold_receiver.ahk`
2) `stacks/GOLD_Bridge_SHM/gold_sender.ahk`

### GOLD_Watchdog_Healing
Folder: `stacks/GOLD_Watchdog_Healing/`

Shows how to combine:
DemonTime + DemonWatchdog + DemonLog

Run:
- `stacks/GOLD_Watchdog_Healing/gold_healing.ahk`

### GOLD_Input_DualLane
Folder: `stacks/GOLD_Input_DualLane/`

Run:
- `stacks/GOLD_Input_DualLane/gold_input_duallane.ahk`

Hotkeys:
- Ctrl+Alt+R — toggle lane (Timer ↔ RawInput)
- Esc — exit

## Tools

### Selftest runner
Folder: `tools/selftest_runner/`

Runs `examples/demo_selftest.ahk` across all libraries and writes a Markdown report under `reports/`.
