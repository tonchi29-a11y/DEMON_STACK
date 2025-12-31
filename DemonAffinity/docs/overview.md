# DemonAffinity — Overview

DemonAffinity is a lightweight AutoHotkey v2 helper for building CPU affinity masks and applying them to the current process or thread.

## Why?
Pinning high-frequency or jitter-sensitive work (watchdogs, timing-critical loops, ML inference) can reduce context switches and cross-core migration costs.

## Features
- Build contiguous masks or arbitrary lists of CPUs (CPU count via Windows APIs)
- Apply affinity to the current process or thread
- Retrieve current affinity to log/diagnose
- No elevation required; wraps standard Windows APIs

## Safety & limitations
- APIs can fail (e.g., sandboxed environments); methods return status or throw meaningfully
- v1 covers up to 64 logical processors (single processor group). Systems with more cores require processor-group APIs (out of scope for now).

## When to use it
- Before entering a high-frequency loop (e.g., watchdog healing logic)
- To pin the “lane” that feeds DemonBridge / DemonSPSC to a specific CCX/core cluster
- To experiment with latency vs. throughput trade-offs
