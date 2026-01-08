# GOLD_Input_DualLane

Opinionated “recipe” showing how the base libraries combine:

## Screenshots
![GOLD_Input_DualLane (Timer lane)](./gold_input_duallane_timer_lane.png)

![GOLD_Input_DualLane (RawInput lane)](./gold_input_duallane_raw_input.png)

- DemonInput (Timer lane + RawInput lane)
- DemonSPSC (ring buffer)
- DemonEMA (dt-based smoothing)

## What it demonstrates
- Dual input lanes (Timer vs RawInput)
- Lane toggle at runtime
- SPSC decoupling + EMA smoothing
- Low-overhead, readable telemetry display

## Run
- `gold_input_duallane.ahk`

## Hotkeys
- `Ctrl+Alt+R` — toggle lane (Timer ↔ RawInput)
- `Esc` — exit
