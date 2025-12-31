# DemonPack64 Overview

DemonPack64 defines a stable 64-byte payload layout and provides helpers to pack/unpack it.

## Why
- Keeps “wire format” stable across scripts and processes.
- Avoids ad-hoc `NumPut` scattered across the codebase.

## Design notes
- Fixed size: 64 bytes.
- Little-endian field encoding via AutoHotkey `NumPut` / `NumGet`.
- Intended pairing: DemonBridge (shared memory) using `payloadSize := 64`.

## Field meanings
- `ts` is a u64 timestamp. You can store `A_TickCount` (u32 value) in u64, or a true tick64/QPC-derived timestamp later.
- `flags` is a u32 bitfield for modes (ADS/HPR/etc) chosen by your host application.
- `accel[4]` and `sens[4]` are float arrays for profile parameters.
- `emaX/emaY` are float smoothed outputs.
