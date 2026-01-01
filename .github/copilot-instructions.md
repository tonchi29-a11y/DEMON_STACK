# DEMON_STACK — Copilot instructions (AHK v2)

## Big picture
DEMON_STACK is a mono-repo of small, reusable AutoHotkey v2 libraries (each in its own `Demon*/` folder) plus reference “Gold” stacks in `stacks/GOLD_*`.

Typical pipeline patterns:
- Input → SPSC → EMA → ContextDetect → (Predict) → Telemetry / Bridge
- Bridge SHM demo: see `stacks/GOLD_Bridge_SHM/`.

## Non-negotiable style contract (do not break)
- AutoHotkey **v2 only**.
- Avoid AHK parser traps:
  - No one-line `try return` / `catch return`.
  - No `??` operator.
  - No `Func("Name")` string lookups; use direct function refs / bound methods.
- `DllCall` targets must use a **single backslash**: `kernel32.dll\Function` (never `\\`).
- Avoid name collisions with methods (case-insensitive): internal fields **must** be prefixed with `_`.
- Library structure is uniform:
  - `src/`, `examples/`, `docs/`, `README.md`, `LICENSE` (MIT), `CHANGELOG.md`
  - `docs/api.md` and `docs/overview.md`
  - `examples/demo_selftest.ahk` must exist (tools assume this).
- Gold stacks live only under `stacks/GOLD_*` and use `gold_*.ahk` names.
- Libraries must be hardware/game agnostic (no RawAccel/game assumptions inside libs).
- BatchTelemetry JSONL rule: **no literal newlines inside `Format()` strings**.
  - Always append line breaks outside: `text .= Format('...json...', ...) . "`r`n"`.

## Repo conventions that matter
- Config is passed as `Map` overrides (see many `__New(config := "")` patterns).
- “Pure logic” libs should have no OS side-effects (no timers, no raw input, no file I/O).
- Callback properties must be safe to read in timer/message threads:
  - Initialize callback slots in `__New` (e.g. `this.OnContextChanged := 0`).
  - When calling callbacks: `cb := this.OnX ; if IsObject(cb) try cb.Call(...)`.

## Workflows
- Run all selftests (interactive): `tools/selftest_runner/run_all_selftests.ahk`
  - The runner discovers `<lib>/examples/demo_selftest.ahk` one level deep.
  - The runner avoids `Array.Sort()` for compatibility; it uses string `Sort()`.

## Where to look for examples
- Good “pure logic + deterministic selftest”: `DemonContextDetect/`.
- Batch telemetry CSV/JSONL writers: `DemonBatchTelemetry/src/`.
- SHM integration pattern: `DemonBridge/` + `stacks/GOLD_Bridge_SHM/`.
- New decision engine pattern: `DemonPredict/`.
