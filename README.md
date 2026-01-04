# DEMON_STACK (AutoHotkey v2)
High-performance, testable AHK v2 library suite for real-time pipelines.

DEMON_STACK is a collection of reusable modules extracted from the DEMON architecture and packaged as standalone AutoHotkey v2 libraries. The focus is on:
- low overhead building blocks
- cache-friendly layouts (where applicable)
- deterministic selftests
- clear API + operational notes
- composable “Gold stacks” that demonstrate real integrations

No application/game/hardware-specific assumptions are baked into the libraries.

---

## Repo map
- Base libraries: `Demon*/`
- Gold stacks (reference recipes): `stacks/GOLD_*`
- Tools: `tools/`
- Reports (generated locally): `reports/` (typically not committed)

---

## Requirements
- AutoHotkey v2 (64-bit recommended)

---

## Base libraries

### IPC and transport
- **DemonBridge** — shared memory IPC (multi-slot seqlock publish + optional CRC32, cache-friendly layout)
- **DemonPack64** — fixed 64-byte payload pack/unpack helpers
- **DemonSPSC** — single-producer single-consumer ring buffer (dx, dy, t64)

### Input and smoothing
- **DemonInput** — dual lane input sampling (Timer + RawInput)
- **DemonEMA** — dt-based EMA smoothing
- **DemonBatchTelemetry** — batch telemetry writers (CSV / JSONL / both)

### Context and decision logic
- **DemonContextDetect** — motion context classifier (Idle/Long/Close + confidence)
- **DemonPredict** — ADS/HPR decision engine driven by context/features
- **DemonNeuromorphic** — leaky integrate-and-fire spike layer (boost/trigger helper)
- **DemonChaos** — Lorenz-inspired chaos score + cooldown bias
- **DemonQuantumBuffer** — probabilistic accumulator + collapse gate

### Timing, reliability, and system controls
- **DemonTime** — QPC timing helpers
- **DemonWatchdog** — stall detection + degraded-mode signaling
- **DemonFallback** — policy wrapper for watchdog-driven fallbacks
- **DemonJitter** — latency/jitter tracker + percentile stats
- **DemonTimerRes** — timer resolution request (system-wide, best-effort)
- **DemonPerfInit** — opt-in performance presets + best-effort restore token
- **DemonAffinity** — CPU affinity helpers (process/thread pinning)

### Utilities
- **DemonConfigLoader** — INI-first config loader + typed getters + poll-based hot reload
- **DemonAtomicFile** — atomic-ish file writing (temp in same dir → replace)
- **DemonReadyFlag** — shared memory ready flag for coordinating processes

### UI and controls
- **DemonHUD** — small overlay HUD for status text (observer layer)
- **DemonHotkeys** — hotkey registration + enable/disable manager

Each library folder contains:
- `src/` implementation
- `examples/demo_selftest.ahk`
- `docs/api.md` and `docs/overview.md`
- `README.md`, `CHANGELOG.md`, `LICENSE`

---

## Gold stacks
Gold stacks live under `stacks/GOLD_*` and use `gold_*.ahk` naming. They are “recipes” showing how to combine multiple libraries into a working pipeline.

### GOLD_Bridge_SHM
Folder: `stacks/GOLD_Bridge_SHM/`  
Pipeline:
- `Input → SPSC → EMA → Pack64 → Bridge.Write`
- `Bridge.Read → Pack64.Unpack → display`

Run:
1) `stacks/GOLD_Bridge_SHM/gold_receiver.ahk`
2) `stacks/GOLD_Bridge_SHM/gold_sender.ahk`

### GOLD_Bridge_ReadyFlag
Folder: `stacks/GOLD_Bridge_ReadyFlag/`  
Demonstrates coordinating two processes using a shared ready flag + SHM transport.

Run:
1) `stacks/GOLD_Bridge_ReadyFlag/gold_receiver.ahk`
2) `stacks/GOLD_Bridge_ReadyFlag/gold_sender.ahk`

### GOLD_Watchdog_Healing
Folder: `stacks/GOLD_Watchdog_Healing/`  
Shows how to combine:
- `DemonTime + DemonWatchdog + DemonLog`

Run:
- `stacks/GOLD_Watchdog_Healing/gold_healing.ahk`

### GOLD_Input_DualLane
Folder: `stacks/GOLD_Input_DualLane/`  
Demonstrates Timer lane ↔ RawInput lane switching.

Run:
- `stacks/GOLD_Input_DualLane/gold_input_duallane.ahk`

### GOLD_HUD_Controls
Folder: `stacks/GOLD_HUD_Controls/`  
Demonstrates:
- `DemonHUD + DemonHotkeys`

Run:
- `stacks/GOLD_HUD_Controls/gold_hud_controls.ahk`

### GOLD_Brain_Predict
Folder: `stacks/GOLD_Brain_Predict/`  
Demonstrates a full “brain” pipeline with HUD observer + hotkey toggles:
- `DemonInput → DemonSPSC → DemonContextDetect → DemonPredict`
- plus optional overlays: `DemonNeuromorphic`, `DemonChaos`, `DemonQuantumBuffer`

Run:
- `stacks/GOLD_Brain_Predict/gold_brain_predict.ahk`

### GOLD_Telemetry_Batch
Folder: `stacks/GOLD_Telemetry_Batch/`  
Telemetry pipeline demo:
- `DemonInput → DemonSPSC → DemonEMA → DemonBatchTelemetry (CSV + JSONL)`
- includes HUD + hotkeys for pause/flush/marker

Run:
- `stacks/GOLD_Telemetry_Batch/gold_telemetry_batch.ahk`

---

## Testing

### Run all library selftests
The repo includes an interactive selftest runner:

- `tools/selftest_runner/run_all_selftests.ahk`

It discovers `<lib>/examples/demo_selftest.ahk` and writes a Markdown report under `reports/`.

Note:
- Some selftests are interactive (MsgBox) by design.
- If you want CI-style automation, standardize selftests to `ExitApp(0/1)` with no UI.

---

## Quick start (example: DemonBridge)
```ahk
#Requires AutoHotkey v2.0
#Include DemonBridge\src\DemonBridge.ahk

br := DemonBridge("Local\DemonStackDemo", 64, 3, true)

payload := Buffer(64, 0)
NumPut("UInt", DllCall("kernel32.dll\GetTickCount", "UInt"), payload, 0)

br.Write(payload)

out := Buffer(64, 0)
if br.ReadLatest(&out) {
	t := NumGet(out, 0, "UInt")
}

Notes
.github/copilot-instructions.md contains style/contract guidance for AI assistants; it does not affect runtime behavior.
Prefer Local\... mapping names unless you explicitly need cross-session visibility.
License
MIT (see LICENSE in each library folder).
