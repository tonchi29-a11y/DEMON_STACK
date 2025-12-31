# DemonConfigLoader Overview

DemonConfigLoader is a small configuration helper for AutoHotkey v2.

## Goals
- Professional, reusable config reading for your modules
- Typed getters with defaults and optional clamping
- Optional hot-reload (poll-based) without heavy dependencies

## Format support (v1)
- INI is fully supported (read/write + LoadIniAll)
- JSON is supported via an injected parser function (so this library stays dependency-free)

## Hot reload behavior
- Uses polling of file modified time (mtime)
- When a change is detected:
  - attempts to load the config
  - calls `onChange(loader, ok, cfg, errMsg)`
- Callbacks must be fast (timer context).
