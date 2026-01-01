# Changelog

All notable changes to this project will be documented in this file.

## v0.1.1 - 2026-01-01
- DemonBridge: internal fields renamed to `_...` to avoid name collisions and match repo conventions.
- DemonBridge: slot selection clarified to `(writeCounter - 1) % slots` (first publish uses slot 0).
- DemonBridge: added a lightweight interlocked-based read barrier in header/slot read paths.
- DemonBridge: fixed one-line `try` into block `try { } catch { }` per style contract.

## v0.1.0 - 2025-12-29
- Initial DemonBridge release: named shared memory + seqlock + CRC32 + multi-slot layout
