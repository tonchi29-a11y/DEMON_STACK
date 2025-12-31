# DemonSPSC API

## Class: DemonSpscRing

### Constructor
- `q := DemonSpscRing(capacity := 1024)`
  - `capacity` is rounded up to the next power of two (minimum 2).

### Methods
- `q.Push(dx, dy, t64) -> true/false`
  - Returns `false` if the ring is full (item dropped).
  - `t64` is an `Int64` timestamp (e.g. `A_TickCount` or a TickCount64-style value). The library stores it but does not interpret it.
- `q.Pop(&dx, &dy, &t64) -> true/false`
  - Returns `false` if the ring is empty.
  - `t64` receives the stored `Int64` timestamp.
- `q.Clear()`
  - Resets `head`, `tail`, and `drops` (buffer contents are not cleared).
- `q.Fill() -> Integer`
  - Returns the current number of queued items.
- `q.GetHealth() -> Map`
  - Keys: `fill`, `cap`, `drops`.

### Data layout (v1)
Each item is stored as 16 bytes:
- `dx`: Float (4 bytes)
- `dy`: Float (4 bytes)
- `t64`: Int64 (8 bytes)
