# DemonQuantumBuffer (AHK v2)

Probabilistic input buffer that “collapses” to allow a sample once enough energy accumulates.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
Call `Update()` with a magnitude (any scalar you want to gate). When the internal accumulator crosses `Threshold`, the buffer collapses and returns `allow := true`.

```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonQuantumBuffer.ahk

q := DemonQuantumBuffer(Map(
    "Threshold", 2.0,
    "Decay", 0.92,
    "Gain", 0.10,
    "NoiseAmp", 0.10
))

mag := 0.35
res := q.Update(mag, 4, 1000)
; res["allow"], res["collapsed"], res["q"]
```

## Examples
- `examples/demo_selftest.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
