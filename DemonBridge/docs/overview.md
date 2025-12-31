# DemonBridge Overview

DemonBridge is a shared-memory transport for passing fixed-size payloads between processes with minimal latency.

## What it is
- A **named shared memory** mapping + a small protocol to publish “latest data”
- A **multi-slot** (default 3) design to reduce contention
- A **seqlock** (sequence counter) strategy to avoid torn reads without mutexes
- Optional **CRC32** integrity checking

Designed for **single-writer, one-or-more readers**. Multiple writers are not supported in v1.

## Typical use
- A producer process/script writes payloads at high frequency.
- A consumer process/script reads the latest stable payload when needed.

## Safety and expectations
- This is user-mode only (no kernel drivers).
- `Local\...` mappings are easiest for typical desktop usage.
- `Global\...` mappings can require additional privileges depending on environment.

## Callback / UI guidelines
If you build higher-level systems on top of DemonBridge:
- Avoid blocking UI (MsgBox) in hot loops.
- Keep per-tick work minimal (pack data into a Buffer and write).

## See also
- `docs/architecture.md` for the byte layout and lock-free protocol spec.
