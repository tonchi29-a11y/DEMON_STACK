# DemonHUD Overview

DemonHUD is a lightweight overlay HUD (GUI) for AutoHotkey v2.

## What it does
- Creates an always-on-top HUD window and displays multi-line text.
- Optional click-through (WM_NCHITTEST returns HTTRANSPARENT).
- Optional heartbeat timer: calls a provider function and updates displayed text.

## What it does not do
- No input hooks, no telemetry capture, no file I/O.
- No game/app assumptions.

## Pipeline position
Observer/UI layer. Typically consumes state produced by other modules (Input/EMA/Context/Predict/Bridge).

## Operational notes
- If `Start()` is used, the provider runs in timer context and must be fast/non-blocking.
- Use `SetText()` only when content changed to reduce GUI churn (DemonHUD does a simple no-change guard).
