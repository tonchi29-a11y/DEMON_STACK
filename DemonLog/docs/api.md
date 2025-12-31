# DemonLog API

## Quick Start
- Include the library and call `DemonLog.Init()` with any overrides.
- Log events with `DemonLog.Log(level, text)` and limit bursts with `DemonLog.SmartLog(level, text, intervalMs, key)`.
- When the script ends, call `DemonLog.Shutdown()` if you want to guarantee a final flush.

## Self-test
Run `examples/demo_selftest.ahk` to validate file I/O and rotation in a guaranteed-writable location (`A_Temp`).

## Configuration Keys
| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `LogPath` | String | `A_ScriptDir "\DemonLog.log"` | Target file path. Directories are created on demand. |
| `Level` | String/Int | `3` (`INFO`) | Minimum log level accepted by `Log()` and `SmartLog()`. |
| `BufferBytes` | Int | `8192` | Buffer length threshold that triggers a flush. Minimum value is 256 bytes. |
| `FlushIntervalMs` | Int | `5000` | Time-based flush interval checked during `Log()` calls. Set to `0` to disable interval-based flushing. |
| `EnableRotation` | Bool | `true` | Enables size-based rotation logic before every flush. |
| `MaxBytes` | Int | `524288` | File size limit that triggers rotation when `EnableRotation` is true. |
| `Encoding` | String | `"UTF-8"` | Passed to `FileAppend()` for both buffered flushes and `SafeLog()`. |
| `AutoFlushMs` | Int | `0` | Timer-based flush even if no new logs happen. When `>= 250`, starts a repeating timer that calls `Flush()` every interval. |

## Public Methods
- `Init(config := {})`: Applies configuration, resets the buffer, restarts auto-flush if requested.
- `Log(level, message)`: Formats the message with a timestamp and queues it for flushing when the level threshold allows it.
- `SmartLog(level, message, minIntervalMs := 0, key := "")`: Rate-limits repeated events by caching the last emit timestamp per key.
- `Flush()`: Writes any buffered data to disk, optionally rotating the log beforehand.
- `SafeLog(line)`: Best-effort direct append for crash handlers and other emergency call sites.
- `SetLevel(level)` / `GetLevel()`: Adjust or read the numeric threshold (1–5 for `ERROR`→`TRACE`).
- `StartAutoFlush(intervalMs)` / `StopAutoFlush()`: Manage the timer that periodically invokes `Flush()`.
- `Shutdown()`: Stops the auto-flush timer, flushes the buffer, and marks the logger as uninitialized.

## Safety
- All public methods can be called multiple times; `Init()` is idempotent and will auto-configure if the logger was not initialized yet.
- Each file operation is wrapped in `try/catch`, so logging failures do not crash the host script.
- Rotation deletes or overwrites only the `.bak` file that belongs to the configured `LogPath`.

## Benchmarks methodology
API behavior is deterministic and not benchmarked here. If you need measurements, run your script with different buffer sizes while capturing Windows Performance Recorder or simply comparing elapsed milliseconds between `A_TickCount` checkpoints.
