# DemonBridge (AutoHotkey v2)

DemonBridge is a small **shared-memory IPC** library for AutoHotkey v2.

It uses:
- Named shared memory (CreateFileMapping / MapViewOfFile)
- Lock-free reads via a seqlock pattern (odd/even sequence)
- Multi-slot “latest value” publishing (default 3 slots)
- Optional CRC32 integrity check over the payload

This repo provides the generic transport/protocol layer. It does **not** depend on RawAccel or any game/app logic.

## Quick start
1. Run the receiver:
   - `examples/demo_receiver.ahk`
2. Run the sender:
   - `examples/demo_sender.ahk`

If you start the receiver first, it will show “no data” until the sender starts.

You should see the receiver ToolTip updating continuously.

## Self-test
Run:
- `examples/demo_selftest.ahk`

## Benchmark
Run (auto-spawns receiver, then runs sender):
- `examples/demo_benchmark.ahk`

Receiver-only:
- `examples/demo_benchmark.ahk receiver`

Sender-only:
- `examples/demo_benchmark.ahk sender --no-spawn`

Options:
- `--name Local\DemonBridgeBench`
- `--secs 5`
- `--hz 0` (0 = max throughput)
- `--crc 1` (1 = CRC enabled, 0 = disabled)

## Usage
```ahk2
#Requires AutoHotkey v2.0
#Include ..\src\DemonBridge.ahk

br := DemonBridge("Local\DemonBridgeDemo", 64, 3, true)
buf := Buffer(64, 0)

; write
NumPut("UInt", A_TickCount, buf, 0)
br.Write(buf)

; read
out := Buffer(64, 0)
if br.ReadLatest(&out) {
    t := NumGet(out, 0, "UInt")
}
```

## Notes
- Prefer `Local\...` names for easiest use (no special privileges).
- `Global\...` may require additional privileges in some environments.
- Use a single backslash in names (e.g. `Local\MyBridge`, not `Local\\MyBridge`).
- If the writer stops, a reader may continue showing the last received payload unless the consumer implements staleness checks.
- Payload is fixed at 64 bytes in DemonBridge v1 (by design).

## Docs
- `docs/api.md` — API reference
- `docs/overview.md` — high-level explanation and safety notes
- `docs/architecture.md` — byte layout + protocol spec

## License
MIT (see `LICENSE`).
