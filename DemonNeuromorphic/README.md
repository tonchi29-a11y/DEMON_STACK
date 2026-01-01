# DemonNeuromorphic (AHK v2)

Leaky integrate-and-fire spikes to nudge confidence thresholds.

## Quick start
- Run: `examples/demo_selftest.ahk`

## Usage
Provide an intensities array (per neuron), call `Update()` at your cadence.

```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonNeuromorphic.ahk

n := DemonNeuromorphic(Map(
    "Count", 8,
    "Threshold", 0.5,
    "RefractoryMs", 12
))

intens := [0.0, 0.2, 0.8, 0.0, 0.0, 0.1, 0.0, 0.0]
res := n.Update(intens, 4, 1000)
; res["spiked"], res["spikeIndices"], res["boost"]
```

## Examples
- `examples/demo_selftest.ahk`

## Docs
- `docs/overview.md`
- `docs/api.md`
