# DemonNeuromorphic API

## Class: DemonNeuromorphic
Lightweight leaky integrate-and-fire spikes for decision/context boosts.

### Constructor
`n := DemonNeuromorphic(config?)`

### Update
`res := n.Update(intensitiesArray, dtMs := 4, nowMs := A_TickCount)`

Returns:
- `spiked` (bool), `spikeCount` (int), `spikeIndices` (Array<int>)
- `boost` (float 0..MaxBoost)
- `potentials` (snapshot), `spikesTotal`

### Other
- `n.Reset()`
- `n.GetState() -> Map`
