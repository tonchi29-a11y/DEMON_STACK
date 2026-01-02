# DemonHotkeys Overview

DemonHotkeys is a small manager for registering and toggling groups of hotkeys.

## What it does
- Registers hotkeys via `Hotkey()`.
- Enables/disables bindings cleanly.
- Supports best-effort unregister via `Remove()` / `Clear()`.
- Tracks simple counters (`fires`, `errors`) for diagnostics.

## What it does not do
- No timers or I/O.
- No game/app assumptions.

## Operational notes
- Hotkey callbacks must be fast/non-blocking.
- By default, callback exceptions are swallowed to keep long-running controller scripts alive.
