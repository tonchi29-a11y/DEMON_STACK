# DemonAtomicFile — Overview

DemonAtomicFile provides a tiny helper for atomic-ish file writes using the common pattern:

1) write to a temporary file
2) move/replace it over the target

## Why
On Windows, a rename/move within the same directory (same volume) can be performed atomically by the filesystem.
That’s why the temp file must be created in the same folder as the target path.

## What it provides
- `WriteTextAtomic(path, text, encoding)`
- Temp file naming that stays in the same directory as the target

## Notes
- Implementation uses AutoHotkey `FileMove(..., overwrite := true)`.
- If you need stricter Win32 semantics, you can wrap `MoveFileExW` / `ReplaceFileW` in a higher-level helper, but this library stays minimal.
