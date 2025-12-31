# DemonJitter Overview

DemonJitter tracks latency/jitter samples in a fixed-size ring and computes basic statistics and percentiles.

## Why
Many “healing / fallback” systems trigger on tail latency (e.g. p95 spikes) rather than averages.

## What it provides
- Fixed-size sample window (ring buffer)
- Stats: min/max/mean
- Percentiles: p50/p95/p99 (nearest-rank)

## Typical use
- Track durations of apply calls, bridge writes, watchdog deltas, etc.
- Trigger fallback when p95 exceeds a threshold for multiple windows.
