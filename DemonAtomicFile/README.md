# DemonAtomicFile (AHK v2)

Atomic-ish file writing helper (temp file in same directory → replace).

## Files
- `src/DemonAtomicFile.ahk` — library
- `examples/demo_selftest.ahk` — selftest
- `docs/overview.md`, `docs/api.md`

## Quick start
```ahk
#Include DemonAtomicFile\src\DemonAtomicFile.ahk

DemonAtomicFile.WriteTextAtomic(A_ScriptDir "\out.txt", "hello", "UTF-8")
```
