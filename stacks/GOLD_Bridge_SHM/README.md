# GOLD_Bridge_SHM

Opinionated “recipe” showing how the base libraries combine:

## Screenshot
![GOLD_Bridge_SHM](./gold_Bridge_SHM.png)

- Sender: Input → SPSC → EMA → Pack64 → Bridge.Write
  - `gold_sender.ahk`
- Receiver: Bridge.Read → Unpack → ToolTip
  - `gold_receiver.ahk`

## Notes
- Mapping name is `Local\DemonBridgeDemo` by default.
- Run receiver first: it will show "no data" until sender starts.
- Sender uses the Timer lane by default (`StartTimerLane(4)`); you can swap to RawInput by using DemonInput's RawInput lane.
