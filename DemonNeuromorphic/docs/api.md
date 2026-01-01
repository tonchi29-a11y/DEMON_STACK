# DemonNeuromorphic API

## Class: DemonNeuromorphic
Lightweight leaky integrate-and-fire spikes for decision/context boosts.

### Constructor
`n := DemonNeuromorphic(cfg := 0)`

- If `cfg` is a `Map`, it overrides defaults.

Config keys (defaults):
- `Count` (8)
- `Decay` (0.995)
- `LearningRate` (0.05)
- `Threshold` (0.5)
- `RefractoryMs` (12)
- `BaseDtMs` (4)
- `SpikeBoost` (0.20)
- `MaxBoost` (0.50)

### Update
`res := n.Update(intensitiesArray, dtMs := 4, nowMs := A_TickCount)`

Returns:
- `spiked` (bool), `spikeCount` (int), `spikeIndices` (Array<int>)
- `boost` (float 0..MaxBoost)
- `potentials` (snapshot), `spikesTotal`

### Other
- `n.Reset()`
- `n.GetState() -> Map`
