## DemonBridge Shared Memory Spec (v1)

This document specifies the **byte-level layout** and **read/write protocol** used by DemonBridge.

### Goals
- Ultra-low-latency IPC via **named shared memory** (CreateFileMapping / MapViewOfFile).
- Tear-free reads via **seqlock** (odd/even sequence counter).
- Integrity validation via **CRC32** over the payload.
- Cache-friendly layout: **64-byte header** and **128-byte slot stride**.

---

## Memory Layout

### Constants (v1 defaults)
- `HEADER_SIZE = 64` bytes
- `PAYLOAD_SIZE = 64` bytes
- `SLOT_CONTENT = 80` bytes (`seq + payload + crc + pad`)
- `SLOT_STRIDE = 128` bytes (content + padding)
- `SLOTS = 3`
- Total mapping size: `HEADER_SIZE + SLOTS * SLOT_STRIDE`  
  - With `SLOTS=3`: `64 + 3*128 = 448 bytes`

All fields are little-endian.

---

## Header Layout (64 bytes)

Offsets are relative to the start of the mapping:

| Offset | Size | Type | Field |
|---:|---:|---|---|
| 0  | 8  | u64 | `hseq` |
| 8  | 8  | u64 | `writeCounter` |
| 16 | 4  | u32 | `lastSlot` |
| 20 | 4  | u32 | `payloadSize` |
| 24 | 4  | u32 | `slots` |
| 28 | 4  | u32 | `reserved` |
| 32 | 32 | bytes | `reserved2/padding` |

Notes:
- `hseq` is the **header seqlock**.
- `writeCounter` increases by 1 each successful write publish.
- `lastSlot` is the most recently completed slot index (0..slots-1).
- `payloadSize` is expected to be `64` in v1.
- `slots` is expected to be `3` in v1 (but can be configured).

---

## Slot Layout

Slot `i` begins at:

`slotBase(i) = HEADER_SIZE + i * SLOT_STRIDE`

### Slot Content (80 bytes)

Offsets below are relative to `slotBase(i)`:

| Rel. Offset | Size | Type | Field |
|---:|---:|---|---|
| 0  | 8  | u64 | `seq` |
| 8  | 64 | bytes | `payload` |
| 72 | 4  | u32 | `crc32(payload)` |
| 76 | 4  | u32 | `pad` |
| 80..127 | 48 | bytes | `slotPadding` |

Notes:
- `seq` is the **slot seqlock** for this slot.
- `pad` and `slotPadding` are unused in v1 (keep zero).
- Slot stride is 128 bytes so **every slot start is 64-byte aligned**.

---

## Write Protocol (single-writer)

Writer publishes to one slot at a time:

1) Choose next slot:
   - `writeCounter := writeCounter + 1`
   - `slot := writeCounter % slots`

2) Begin slot write (seqlock):
   - Read current `seq`
   - Write `seq := seq + 1` (must become **odd**) → indicates “writing”

3) Write payload:
   - Copy exactly `payloadSize` bytes into `payload`

4) Compute and write CRC:
   - `crc := CRC32(payload)` over the **payload bytes only**
   - Write `crc` to `crc32(payload)` field

5) Memory barrier:
   - Use a memory barrier (e.g. `FlushProcessWriteBuffers`) before publishing completion.

6) End slot write:
   - Write `seq := seq + 1` (must become **even**) → indicates “stable”

7) Publish header (under header seqlock `hseq`):
   - Set `hseq` odd
   - Write `writeCounter`, `lastSlot`, `payloadSize`, `slots`
   - Barrier
   - Set `hseq` even

---

## Read Protocol (lock-free reader)

Reader fetches the latest completed slot:

1) Read header (seqlock):
   - Read `hseq1` and ensure it is **even**
   - Read `writeCounter`, `lastSlot`, `payloadSize`, `slots`
   - Read `hseq2`
   - Accept header only if `hseq1 == hseq2` and `hseq2` is even

2) Read slot `lastSlot` (seqlock + CRC):
   - Read `seq1` and ensure it is **even**
   - Copy `payloadSize` bytes from `payload` into a local buffer
   - Read `crcRead`
   - Read `seq2`
   - Accept only if:
     - `seq1 == seq2`
     - `seq2` is even
     - `CRC32(localPayload) == crcRead`

3) If any check fails:
   - Retry a small bounded number of times (e.g. 5–10)

---

## Notes on Alignment and Performance

- This spec intentionally uses `HEADER_SIZE=64` and `SLOT_STRIDE=128` to ensure:
  - header begins on a cache line
  - each slot begins on a cache line
  - reduced false sharing between writer and reader

- The algorithm remains correct even without cache-line alignment, but alignment improves stability at high update rates.

---

## Compatibility
- v1 assumes a fixed `PAYLOAD_SIZE=64` for the slot layout above. If you change payload size, you must update offsets and/or compute a new stride.