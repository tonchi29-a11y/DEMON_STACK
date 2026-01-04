# DemonReadyFlag — Overview

DemonReadyFlag is a tiny shared-memory “ready” flag for coordinating two (or more) processes.

## Why
Sometimes you need a simple signal like “CORE is initialized” so that a HUD/receiver process can wait or show status.

## What it provides
- Named file mapping (default `Local\DemonReadyFlag`)
- Atomic `SetReady()` and `IsReady()` via Win32 interlocked ops
- Small footprint (default mapping size 64 bytes; only first 4 bytes are used)

## Notes
- This library is Windows-only (uses Win32 shared memory APIs).
- The flag is stored at offset 0 as a 32-bit integer (0/1).
- Interlocked ops are selected via runtime probing; fallback path uses heavy barrier + plain read/write (not hot-path).
