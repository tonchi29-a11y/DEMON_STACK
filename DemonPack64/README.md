# DemonPack64 (AutoHotkey v2)

DemonPack64 is a tiny **packing/unpacking** helper for a fixed 64-byte payload.

This is intended to be used with DemonBridge (shared memory) or any other transport that moves fixed-size buffers.

## Payload layout (64 bytes)

| Offset | Size | Type | Field |
|---:|---:|---|---|
| 0  | 8  | u64 | ts |
| 8  | 4  | u32 | flags |
| 12 | 16 | float[4] | accel[0..3] |
| 28 | 16 | float[4] | sens[0..3] |
| 44 | 4  | float | emaX |
| 48 | 4  | float | emaY |
| 52 | 4  | u32 | reserved0 |
| 56 | 8  | u64 | reserved1 |

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonPack64.ahk

buf := DemonPack64.New()
DemonPack64.PackBasic(buf, A_TickCount, 0x1, 0.0, 0.0)

m := DemonPack64.Unpack(buf)
; m["ts"], m["flags"], m["emaX"], m["emaY"], ...
```

## Docs
- `docs/api.md`
- `docs/overview.md`

## License
MIT (see `LICENSE`).
