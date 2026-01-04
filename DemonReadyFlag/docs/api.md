# DemonReadyFlag — API

## class `DemonReadyFlag`

### `__New(name := "Local\DemonReadyFlag", mapBytes := 64)`
Creates or opens a named shared-memory mapping and maps it into the current process.

- `name`: mapping name. Use `Local\...` for per-session visibility; use `Global\...` if you need cross-session visibility.
- `mapBytes`: mapping size in bytes (must be >= 4). Only the first 4 bytes are used for the flag.

### `Close()`
Unmaps and closes handles. Safe to call multiple times.

### `SetReady(isReady := true)`
Atomically stores `1` (ready) or `0` (not ready). Returns `true` on success.

### `IsReady()`
Atomically reads the flag value. Returns `true` if non-zero.

Implementation may use KernelBase/NTDLL interlocked fallbacks; final fallback uses FlushProcessWriteBuffers + NumGet/NumPut.

### `GetState()`
Returns a `Map` with basic info:
- `name`
- `mapBytes`
