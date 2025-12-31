# DemonPack64 API

## Class: DemonPack64

### Constants
- `DemonPack64.SIZE` = `64`

### Buffer helpers
- `buf := DemonPack64.New()`
  - Returns a `Buffer(64)`.

- `DemonPack64.Zero(buf)`
  - Zeroes all 64 bytes.

### Packing
- `DemonPack64.PackBasic(buf, ts, flags, emaX, emaY) -> buf`
  - Zeroes the buffer first.
  - Writes: `ts`, `flags`, `emaX`, `emaY`.

- `DemonPack64.PackFull(buf, ts, flags, emaX, emaY, accel?, sens?) -> buf`
  - Zeroes the buffer first.
  - If provided, `accel` and `sens` should be Array-like with at least 4 entries (1-based indexing).

### Unpacking
- `m := DemonPack64.Unpack(buf) -> Map`
  - Returns keys: `ts`, `flags`, `accel`, `sens`, `emaX`, `emaY`, `reserved0`, `reserved1`.

- `DemonPack64.UnpackBasic(buf, &ts, &flags, &emaX, &emaY) -> true`
  - Fast path: unpacks only `ts`, `flags`, `emaX`, `emaY`.
  - Uses ByRef outputs to avoid allocations in hot loops.

- `ts := DemonPack64.ReadTs(buf) -> u64`
  - Convenience helper when you only need the timestamp.

### Errors
- All APIs require `buf` to be a `Buffer(64)`; otherwise they throw.
