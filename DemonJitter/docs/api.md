# DemonJitter API

## Class: DemonJitter

### Constructor
`j := DemonJitter(capacity := 256)`

### Methods
- `j.Add(ms) -> float`
  - Adds a non-negative sample (ms).

- `j.Snapshot() -> Array`
  - Debug/export hook (allocates); returns samples oldest→newest.

- `j.GetStats() -> Map`
  - Returns keys: `count`, `min`, `max`, `mean`, `p50`, `p95`, `p99`.
  - Percentiles use nearest-rank: `rank = ceil(p/100*n)`.

- `j.Clear()`
- `j.Count()`, `j.Capacity()`

### Optional: watcher helper
- `j.WatchP95(thresholdMs, tripLimit := 2, decayOnOk := 1) -> Map`
  - Returns: `p95`, `trips`, `triggered`.
- `j.ResetTrips()`

## Notes
- Stats are computed from a snapshot copy and numeric sort.
- For small capacities (e.g. 128–512) this is fast and simple.
