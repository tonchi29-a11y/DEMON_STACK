# DemonBridge API

## Class: DemonBridge

### Constructor
`br := DemonBridge(name := "Local\DemonBridge", payloadSize := 64, slots := 3, crcEnabled := true)`

- `name`: mapping name (e.g. `Local\MyBridge`).
- `payloadSize`: bytes per payload buffer. **In v1 this must be 64**.
- `slots`: number of slots (default 3).
- `crcEnabled`: if true, write/read validates CRC32 over the payload.

### Methods
- `br.Write(payloadBuf) -> true/false`
  - `payloadBuf` must be a `Buffer` of exactly `payloadSize`.
  - `Write()` throws if `payloadBuf` is not a `Buffer` of exactly 64 bytes.
  - Single-writer design.

- `br.ReadLatest(&outBuf, retries := 8) -> true/false`
  - Reads the latest stable slot into `outBuf`.
  - If `outBuf` is not a `Buffer` or has the wrong size, a new `Buffer(payloadSize)` is allocated.
  - Retries are bounded and lock-free.

- `state := br.GetState() -> Map`
  - Includes counters: `writeCount`, `readOk`, `readRetries`, `crcFails`, plus config.

- `br.Close()`
  - Unmaps the view and closes handles.

### Static helpers
- `DemonBridge.Crc32(buf) -> u32`
  - CRC32 computed over the buffer bytes.

## Return / error behavior
- Most Windows API errors throw (e.g. CreateFileMapping/MapViewOfFile failures).
- Read failures typically return `false` after bounded retries (not an exception).
