# Changelog

All notable changes to this project will be documented in this file.

## v0.1.0 - 2025-12-29
- Initial DemonInput release
- Timer lane (MouseGetPos deltas)
- RawInput lane (WM_INPUT mouse deltas) with optional input-sink and per-tick aggregation
- Emits samples via callback (dx, dy, tMs, source)
- Restores any previous WM_INPUT handler on Stop()
