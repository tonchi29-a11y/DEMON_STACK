# DEMON_STACK (AutoHotkey v2)

High-performance, testable AHK v2 library suite for **real-time pipelines**.

DEMON_STACK is a collection of standalone AutoHotkey v2 libraries extracted from the DEMON architecture.  
It is designed for situations where **every microsecond and every missed frame matters**:

- lock-free concurrency
- cache-friendly memory layouts
- deterministic selftests
- clear APIs and operational notes
- “Gold stack” reference pipelines that show real integrations

All modules are **pure AutoHotkey v2** – no external DLLs, drivers, or kernel components.

> If you just need simple hotkeys or macros, this is overkill.  
> If you’re pushing AHK into territory usually reserved for C++ (telemetry, real‑time input processing, multi‑process coordination), this is for you.

---

## When is DEMON_STACK useful?

Use it when you need things like:

- **Ultra-fast inter-process communication** at 1000+ Hz without blocking
- **Producer–consumer decoupling** in tight loops (don’t stall input when processing is slow)
- **Stall detection and auto-healing** (detect hangs, widen timers, switch to degraded mode)
- **Precise jitter/latency tracking** with statistics (min/max/percentiles)
- **Domain-agnostic “brain” pipelines**: input → context → decisions → telemetry

You *probably don’t need it* for:

- Simple hotkey remaps
- One-off automation that runs a few times per minute
- Scripts where ±10–50 ms of jitter is fine

---

## Core philosophy

- **Zero external dependencies**  
  Pure AutoHotkey v2. Clone, include, run.

- **Cache-friendly, deterministic design**  
  - Fixed-size payloads where possible  
  - 64-byte cache line awareness and SOA layouts  
  - Explicit memory barriers and ordering where required

- **Tested & composable**  
  Every library comes with:
  - a selftest (`examples/demo_selftest.ahk`)
  - `docs/overview.md` (what it does, why it exists)
  - `docs/api.md` (how to call it)

  ![Selftest runner](tools/selftest_runner/overview_png/all_selftest_md.png)

- **Gold stacks (reference pipelines)**  
  Ready-to-run example pipelines that show how to combine multiple libraries:
  - e.g. dual-lane input → SPSC ring → EMA smoothing → lock-free IPC → telemetry

  ![Gold stacks](stacks/gold_stack.png)

---

## Repo map

- Base libraries: `Demon*/`
- Gold stacks (reference recipes): `stacks/GOLD_*`
- Tools: `tools/`
- Reports (generated locally): `reports/` (usually ignored in Git)

Each library folder typically contains:

- `src/` – implementation
- `examples/demo_selftest.ahk` – self-contained test/demo
- `docs/api.md` and `docs/overview.md`
- `README.md`, `CHANGELOG.md`, `LICENSE`

---

## Requirements

- **AutoHotkey v2** (64‑bit recommended)
- Windows (shared memory + RawInput are Win-specific)

---

## Base libraries (overview)

### IPC and transport

- **DemonBridge** – Lock-free shared memory IPC:
  - Single-writer, lock-free seqlock pattern
  - Optional CRC32 integrity check
  - Cache-aware layout to minimize contention and false sharing
- **DemonPack64** – Fixed 64-byte payload pack/unpack helpers
- **DemonSPSC** – Single-producer, single-consumer ring buffer (dx, dy, t64; power-of-2 slots) – perfect for decoupling input sampling from processing

### Input and smoothing

- **DemonInput** – Dual-lane input sampling (Timer lane + RawInput lane) with runtime switching
- **DemonEMA** – dt-based exponential moving average (no fixed frame rate assumptions)
- **DemonBatchTelemetry** – Batch telemetry writers (CSV / JSONL / both)

### Context and decision logic

- **DemonContextDetect** – Motion/context classifier (Idle/Long/Close + confidence)
- **DemonPredict** – Decision engine driven by context/features (e.g. ADS/HPR style decisions)
- **DemonNeuromorphic** – Lightweight leaky integrate-and-fire “spike” layer
- **DemonChaos** – Lorenz-inspired chaos score + cooldown bias
- **DemonQuantumBuffer** – Probabilistic accumulator with collapse gate

### Timing, reliability, and system controls

- **DemonTime** – QPC timing helpers
- **DemonWatchdog** – Stall detection + degraded-mode signaling
- **DemonFallback** – Policy wrapper for watchdog-driven fallbacks
- **DemonJitter** – Latency/jitter tracker + percentile stats
- **DemonTimerRes** – Timer resolution request (system-wide, best-effort)
- **DemonPerfInit** – Opt-in performance presets + best-effort restore token
- **DemonAffinity** – CPU affinity helpers (process/thread pinning)

### Utilities

- **DemonConfigLoader** – INI-first config loader + typed getters + poll-based hot reload
- **DemonAtomicFile** – Atomic-ish file writing (temp in same dir → replace)
- **DemonReadyFlag** – Shared memory “ready” flag to coordinate multiple processes

### UI and controls

- **DemonHUD** – Small overlay HUD for status text (observer/diagnostic layer)
- **DemonHotkeys** – Hotkey registration + enable/disable manager

---

## Gold stacks (reference pipelines)

Gold stacks live under `stacks/GOLD_*` and use `gold_*.ahk` naming.  
They are “recipes” showing how to wire the libraries into a working real-time pipeline.

### GOLD_Bridge_SHM

Folder: `stacks/GOLD_Bridge_SHM/`  

Pipeline:

- `Input → SPSC → EMA → Pack64 → Bridge.Write`
- `Bridge.Read → Pack64.Unpack → display`

Run:

1. `stacks/GOLD_Bridge_SHM/gold_receiver.ahk`
2. `stacks/GOLD_Bridge_SHM/gold_sender.ahk`

![GOLD_Bridge_SHM](stacks/GOLD_Bridge_SHM/gold_Bridge_SHM.png)

---

### GOLD_Bridge_ReadyFlag

Folder: `stacks/GOLD_Bridge_ReadyFlag/`  

Demonstrates coordinating two processes using a shared ready flag + shared memory transport.

Run:

1. `stacks/GOLD_Bridge_ReadyFlag/gold_receiver.ahk`
2. `stacks/GOLD_Bridge_ReadyFlag/gold_sender.ahk`

![GOLD_Bridge_ReadyFlag](stacks/GOLD_Bridge_ReadyFlag/gold_receiver_sender.png)

---

### GOLD_Watchdog_Healing

Folder: `stacks/GOLD_Watchdog_Healing/`  

Shows how to combine:

- `DemonTime + DemonWatchdog + DemonLog` (or equivalent logging)

Run:

- `stacks/GOLD_Watchdog_Healing/gold_healing.ahk`

![GOLD_Watchdog_Healing](stacks/GOLD_Watchdog_Healing/gold_healing.png)

---

### GOLD_Input_DualLane

Folder: `stacks/GOLD_Input_DualLane/`  

Demonstrates Timer lane ↔ RawInput lane switching.

Run:

- `stacks/GOLD_Input_DualLane/gold_input_duallane.ahk`

![GOLD_Input_DualLane (Timer lane)](stacks/GOLD_Input_DualLane/gold_input_duallane_timer_lane.png)

![GOLD_Input_DualLane (RawInput lane)](stacks/GOLD_Input_DualLane/gold_input_duallane_raw_input.png)

---

### GOLD_HUD_Controls

Folder: `stacks/GOLD_HUD_Controls/`  

Demonstrates:

- `DemonHUD + DemonHotkeys`

Run:

- `stacks/GOLD_HUD_Controls/gold_hud_controls.ahk`

![GOLD_HUD_Controls](stacks/GOLD_HUD_Controls/gold_hud_controls.png)

---

### GOLD_Brain_Predict

Folder: `stacks/GOLD_Brain_Predict/`  

Full “brain” pipeline with HUD + hotkey toggles:

- `DemonInput → DemonSPSC → DemonContextDetect → DemonPredict`
- Optional overlays: `DemonNeuromorphic`, `DemonChaos`, `DemonQuantumBuffer`

Run:

- `stacks/GOLD_Brain_Predict/gold_brain_predict.ahk`

![GOLD_Brain_Predict](stacks/GOLD_Brain_Predict/gold_brain_predict.png)

---

### GOLD_Telemetry_Batch

Folder: `stacks/GOLD_Telemetry_Batch/`  

Telemetry pipeline demo:

- `DemonInput → DemonSPSC → DemonEMA → DemonBatchTelemetry (CSV + JSONL)`
- Includes HUD + hotkeys for pause/flush/marker

Run:

- `stacks/GOLD_Telemetry_Batch/gold_telemetry_batch.ahk`

![GOLD_Telemetry_Batch](stacks/GOLD_Telemetry_Batch/gold_telemetry_batch.png)

---

## Quick start (simple DemonBridge example)

```ahk
#Requires AutoHotkey v2.0
#Include DemonBridge\src\DemonBridge.ahk

; Create (or open) a shared memory bridge with:
;   - name: "Local\DemonStackDemo"
;   - payload size: 64 bytes
;   - 3 slots
;   - CRC32 enabled
br := DemonBridge("Local\DemonStackDemo", 64, 3, true)

; Prepare a 64-byte payload
payload := Buffer(64, 0)
NumPut("UInt", DllCall("kernel32.dll\GetTickCount", "UInt"), payload, 0)

; Write into shared memory
br.Write(payload)

; Read the latest published payload
out := Buffer(64, 0)
if br.ReadLatest(&out) {
    t := NumGet(out, 0, "UInt")
    ; Use t ...
}
```

## Deep dive: DemonBridge memory layout (for performance nerds)
DemonBridge employs a meticulously engineered memory layout tailored for maximum performance on contemporary x64 processors (both Intel and AMD), where the cache line size is universally 64 bytes.

### Layout breakdown
- **Header (64 bytes / 1 cache line)**
  - Contains header seqlock, writeCounter, lastSlot, payloadSize, slots, and reserved fields.
  - Header reads never touch slot data, reducing cache line transfers and contention.

- **Per-slot content (80 bytes)**
  - Seqlock counter: 8 bytes
  - Payload: 64 bytes
  - CRC32 checksum: 4 bytes
  - Padding: 4 bytes

- **Slot stride: 128 bytes (2 cache lines)**
  - Padding ensures that no two slots share a cache line, eliminating false sharing.
  - Writer operations on one slot avoid invalidating reader cache lines for other slots.

### Visual representation (memory map)
```
Header: [ 64 bytes ]

Slot 0: [seq(8) | payload(64) | crc(4) | pad(4)]  (80 bytes content)
        <------------------- 128-byte stride ------------------->
Slot 1: [seq(8) | payload(64) | crc(4) | pad(4)]
        <------------------- 128-byte stride ------------------->
Slot 2: [seq(8) | payload(64) | crc(4) | pad(4)]
        ...
```

### Why this matters
- **Minimal cache traffic**: Writer and reader touch disjoint cache lines whenever possible.
- **No false sharing**: Helps sustain high-frequency updates (>1000 Hz) without performance degradation.
- **Cross-core correctness**: Paired with explicit FlushProcessWriteBuffers calls for memory visibility and ordering.
- **Deterministic behavior**: Designed to behave consistently across x64 Windows systems.

<details>
  <summary><strong>DemonBridge "Elite" layout: full source (click to expand)</strong></summary>

```ahk
#Requires AutoHotkey v2.0

class DemonBridge {
  static _barInited := false
  static _barFn := ""

  __New(name := "Local\DemonBridge", payloadSize := 64, slots := 3, crcEnabled := true) {
    if payloadSize != 64
      throw Error("payloadSize must be 64 for DemonBridge v1")
    if slots < 2
      throw Error("slots must be >= 2")

    this._name := name
    this._payloadSize := Integer(payloadSize)
    this._slots := Integer(slots)
    this._crcEnabled := !!crcEnabled

    ; "Elite" layout:
    ; - 64-byte header (one cache line)
    ; - slot content is 80 bytes: seq(8) + payload(64) + crc32(4) + pad(4)
    ; - slot stride is 128 bytes (pad to reduce false sharing)
    this._headerSize := 64
    this._slotContentSize := 8 + this._payloadSize + 8
    this._slotStride := 128
    if this._slotContentSize > this._slotStride
      throw Error("slotContentSize must be <= slotStride")

    this._mapSize := this._headerSize + (this._slots * this._slotStride)

    this._hMap := 0
    this._pView := 0

    ; Stats
    this._writeCount := 0
    this._readOk := 0
    this._readRetries := 0
    this._crcFails := 0

    this._OpenOrCreate()
    this._InitIfNew()
  }

  Close() {
    if this._pView {
      DllCall("kernel32.dll\UnmapViewOfFile", "Ptr", this._pView, "Int")
      this._pView := 0
    }
    if this._hMap {
      DllCall("kernel32.dll\CloseHandle", "Ptr", this._hMap, "Int")
      this._hMap := 0
    }
  }

  __Delete() {
    try {
      this.Close()
    } catch {
    }
  }

  ; Writer: write a payload Buffer (must be exactly payloadSize bytes)
  Write(payloadBuf) {
    if !(payloadBuf is Buffer)
      throw TypeError("payloadBuf must be a Buffer")
    if payloadBuf.Size != this._payloadSize
      throw Error("payloadBuf.Size must be " this._payloadSize)

    ; Choose next slot (single-writer assumption)
    hdr := this._ReadHeader()
    wc := hdr.writeCounter + 1
    slot := Mod(wc - 1, this._slots)

    slotOff := this._headerSize + (slot * this._slotStride)
    seqOff := slotOff
    payOff := slotOff + 8
    crcOff := payOff + this._payloadSize

    seq := NumGet(this._pView, seqOff, "UInt64")

    ; seqlock: odd = writing
    NumPut("UInt64", seq + 1, this._pView, seqOff)

    ; copy payload
    DllCall("kernel32.dll\RtlMoveMemory", "Ptr", this._pView + payOff, "Ptr", payloadBuf.Ptr, "UPtr", this._payloadSize)

    crc := this._crcEnabled ? DemonBridge.Crc32(payloadBuf) : 0
    NumPut("UInt", crc, this._pView, crcOff)

    ; memory barrier to reduce reorder surprises across cores
    DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")

    ; seqlock: even = done
    NumPut("UInt64", seq + 2, this._pView, seqOff)

    DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")

    ; publish header (with header seqlock)
    this._WriteHeader(wc, slot)

    this._writeCount += 1
    return true
  }

  ; Reader: reads latest payload into outBuf (must be payloadSize).
  ; Returns true if a consistent payload was read.
  ReadLatest(&outBuf, retries := 8) {
    if !(outBuf is Buffer) || outBuf.Size != this._payloadSize
      outBuf := Buffer(this._payloadSize, 0)

    loop retries {
      hdr := this._ReadHeader()
      slot := hdr.lastSlot
      if slot < 0 || slot >= this._slots {
        this._readRetries += 1
        continue
      }

      slotOff := this._headerSize + (slot * this._slotStride)
      seqOff := slotOff
      payOff := slotOff + 8
      crcOff := payOff + this._payloadSize

      seq1 := NumGet(this._pView, seqOff, "UInt64")
      if (seq1 & 1) {
        ; odd = writer in progress
        this._readRetries += 1
        continue
      }

      ; copy payload out
      DllCall("kernel32.dll\RtlMoveMemory", "Ptr", outBuf.Ptr, "Ptr", this._pView + payOff, "UPtr", this._payloadSize)
      crcRead := NumGet(this._pView, crcOff, "UInt")

      DemonBridge._ReadBarrier()
      seq2 := NumGet(this._pView, seqOff, "UInt64")
      if (seq1 != seq2) || (seq2 & 1) {
        this._readRetries += 1
        continue
      }

      if this._crcEnabled {
        crcCalc := DemonBridge.Crc32(outBuf)
        if (crcCalc != crcRead) {
          this._crcFails += 1
          this._readRetries += 1
          continue
        }
      }

      this._readOk += 1
      return true
    }

    return false
  }

  GetState() {
    return Map(
      "name", this._name,
      "payloadSize", this._payloadSize,
      "slots", this._slots,
      "writeCount", this._writeCount,
      "readOk", this._readOk,
      "readRetries", this._readRetries,
      "crcFails", this._crcFails
    )
  }

  ; ---------------- internals ----------------

  static _ReadBarrier() {
    static dummy := Buffer(4, 0)

    if !DemonBridge._barInited {
      DemonBridge._barInited := true
      DemonBridge._barFn := DemonBridge._PickBarrierFn(dummy)
    }

    if (DemonBridge._barFn != "") {
      DllCall(DemonBridge._barFn, "Ptr", dummy.Ptr, "Int", 0, "Int")
      return
    }

    ; slow fallback but always available
    DllCall("kernel32.dll\FlushProcessWriteBuffers")
  }

  static _PickBarrierFn(dummy) {
    candidates := [
      "KernelBase.dll\InterlockedExchangeAdd",
      "kernel32.dll\InterlockedExchangeAdd",
      "ntdll.dll\RtlInterlockedExchangeAdd"
    ]
    for _, fn in candidates {
      try {
        DllCall(fn, "Ptr", dummy.Ptr, "Int", 0, "Int")
        return fn
      } catch {
      }
    }
    return ""
  }

  _OpenOrCreate() {
    FILE_MAP_ALL_ACCESS := 0xF001F
    PAGE_READWRITE := 0x04
    INVALID_HANDLE_VALUE := -1

    hMap := DllCall("kernel32.dll\OpenFileMappingW", "UInt", FILE_MAP_ALL_ACCESS, "Int", 0, "WStr", this._name, "Ptr")
    if !hMap {
      hMap := DllCall(
      "kernel32.dll\CreateFileMappingW"
        , "Ptr", INVALID_HANDLE_VALUE
        , "Ptr", 0
        , "UInt", PAGE_READWRITE
        , "UInt", 0
        , "UInt", this._mapSize
        , "WStr", this._name
        , "Ptr"
      )
      if !hMap
        throw Error("CreateFileMapping failed. LastError=" A_LastError)
    }

    pView := DllCall("kernel32.dll\MapViewOfFile", "Ptr", hMap, "UInt", FILE_MAP_ALL_ACCESS, "UInt", 0, "UInt", 0, "UPtr", this._mapSize, "Ptr")
    if !pView {
      DllCall("kernel32.dll\CloseHandle", "Ptr", hMap, "Int")
      throw Error("MapViewOfFile failed. LastError=" A_LastError)
    }

    this._hMap := hMap
    this._pView := pView
  }

  _InitIfNew() {
    ; If header payloadSize mismatches, initialize header.
    hdr := this._ReadHeader(false)
    if (hdr.payloadSize != this._payloadSize) || (hdr.slots != this._slots) {
      ; zero memory
      DllCall("kernel32.dll\RtlZeroMemory", "Ptr", this._pView, "UPtr", this._mapSize)

      ; header publish
      this._WriteHeader(0, 0, true)

      ; init slot seq to 0
      loop this._slots {
        slot := A_Index - 1
        slotOff := this._headerSize + (slot * this._slotStride)
        NumPut("UInt64", 0, this._pView, slotOff)
      }
      DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")
    }
  }

  _ReadHeader(strict := true) {
    base := this._pView
    loop 8 {
      hseq1 := NumGet(base, 0, "UInt64")
      if strict && (hseq1 & 1) {
        continue
      }
      wc := NumGet(base, 8, "UInt64")
      lastSlot := NumGet(base, 16, "UInt")
      psz := NumGet(base, 20, "UInt")
      slots := NumGet(base, 24, "UInt")
      DemonBridge._ReadBarrier()
      hseq2 := NumGet(base, 0, "UInt64")
      if (hseq1 = hseq2) && (!(hseq2 & 1) || !strict) {
        return {writeCounter: wc, lastSlot: lastSlot, payloadSize: psz, slots: slots}
      }
    }
    return {writeCounter: 0, lastSlot: 0, payloadSize: 0, slots: 0}
  }

  _WriteHeader(writeCounter, lastSlot, force := false) {
    base := this._pView
    hseq := NumGet(base, 0, "UInt64")

    ; header seqlock
    NumPut("UInt64", hseq + 1, base, 0) ; odd
    NumPut("UInt64", writeCounter, base, 8)
    NumPut("UInt", lastSlot, base, 16)
    NumPut("UInt", this._payloadSize, base, 20)
    NumPut("UInt", this._slots, base, 24)
    NumPut("UInt", 0, base, 28)
    DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")
    NumPut("UInt64", hseq + 2, base, 0) ; even
    DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")
  }

  ; ---------------- CRC32 ----------------

  static Crc32(buf) {
    static table := DemonBridge._CrcTable()
    crc := 0xFFFFFFFF
    p := buf.Ptr
    sz := buf.Size
    Loop sz {
      b := NumGet(p, A_Index - 1, "UChar")
      crc := (crc >> 8) ^ table[((crc ^ b) & 0xFF) + 1]
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF
  }

  static _CrcTable() {
    static t := ""
    if IsObject(t)
      return t
    t := []
    poly := 0xEDB88320
    Loop 256 {
      c := A_Index - 1
      Loop 8 {
        if (c & 1)
          c := (c >> 1) ^ poly
        else
          c >>= 1
      }
      t.Push(c & 0xFFFFFFFF)
    }
    return t
  }
}
```

</details>


### Advanced Decision Layers
- **DemonNeuromorphic**: Simplified leaky integrate-and-fire spiking neuron layer. Accumulates weighted input features (velocity magnitude, acceleration, context confidence) with exponential decay; emits discrete spikes when membrane potential crosses threshold. Spikes can boost confidence, trigger temporary overrides, or gate downstream logic. Lightweight biological-inspired augmentation for enhancing context sensitivity without full neural networks.

- **DemonChaos**: Lorenz-attractor-inspired chaotic oscillator that generates a dynamic chaos score (0.0–1.0) based on recent velocity and context history. Produces adaptive bias signals, cooldown triggers, and temporary boost windows. Used to inject organic variability into decision thresholds, preventing predictable patterns and enabling emergent "feel" adjustments in realtime systems.

- **DemonQuantumBuffer**: Probabilistic input accumulator with "superposition" metaphor – samples are accumulated with random gating (configurable probability distribution) until a collapse threshold is reached, at which point a single representative sample is emitted downstream. Includes cooldown, burst protection, and tunable entropy source. Ideal for introducing controlled non-determinism in high-frequency streams (e.g., reducing effective sample rate during rapid motion while preserving critical transitions).

These three modules are deliberately optional and toggleable – they hook into the core pipeline non-intrusively, allowing experimentation with advanced behavioral modulation while preserving the deterministic foundation of the stack. Perfect for elite tuning scenarios where subtle, adaptive intelligence elevates performance beyond pure smoothing and prediction.

### Real-World Power
While some Gold stacks originated from ultra-low-latency input telemetry experiments, everything is **domain-agnostic and general-purpose**:
- Multi-process data streaming/coordination
- Sensor/telemetry pipelines (e.g., hardware monitoring, robotics prototypes)
- High-frequency automation without hiccups
- Anything needing reliable realtime behavior in pure script

If you're into low-level optimization, concurrency primitives in scripting languages, or just want the most robust realtime tools AHK v2, 
check it out and let me know what you think.

## Testing / Run all library selftests
The repo includes an interactive selftest runner:

- `tools/selftest_runner/run_all_selftests.ahk`

![Selftest runner script](tools/selftest_runner/overview_png/run_all_selftest_ahk.png)

It discovers `<lib>/examples/demo_selftest.ahk` and writes a Markdown report under `reports/`.

![Selftest report output](tools/selftest_runner/overview_png/all_selftest_output.png)

- Some selftests are interactive (MsgBox) by design.
- For CI-style automation, you can standardize selftests to `ExitApp(0/1)` with no UI.

## Notes
.github/copilot-instructions.md contains style/contract guidance for AI assistants; it does not affect runtime behavior.
Prefer Local\... mapping names unless you explicitly need cross-session visibility.

## License
```text
MIT License

Copyright (c) 2025 tONCHEzY

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

MIT (see LICENSE in each library folder).

