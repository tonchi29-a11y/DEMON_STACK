# DemonAffinity API

## Static functions

### `DemonAffinity.CpuCount()`
Returns logical CPU count via Windows APIs (`GetActiveProcessorCount` / `GetSystemInfo`).

### `DemonAffinity.MakeMask(skip := 0, count := 1) -> int`
Builds a contiguous mask skipping the first `skip` CPUs, then taking `count` CPUs. Both parameters are clamped to valid ranges.

### `DemonAffinity.MaskFromList(indices) -> int`
Accepts an array/list of 0-based CPU indices and ORs them into a mask. Indices outside `[0, CpuCount-1]` are ignored.

### `DemonAffinity.SetCurrentProcess(mask) -> bool`
Applies `mask` to the current process using `SetProcessAffinityMask`. Returns `true` on success, `false` otherwise.

### `DemonAffinity.GetCurrentProcess() -> Map`
Returns a map containing:
- `processMask`
- `systemMask`

Throws if the underlying Windows API call fails.

### `DemonAffinity.SetCurrentThread(mask) -> prevMask`
Pins the current thread using `SetThreadAffinityMask` and returns the previous mask (use it to restore). `prevMask` is the prior affinity mask for the current thread; `0` means the call failed.

### `DemonAffinity.RestoreThread(prevMask) -> bool`
Restores the thread affinity by reapplying `prevMask`. Returns `true` on success.

## Notes
- v1 handles up to 64 logical processors (single processor group). Processor groups (>64 LPs) are not supported yet.
- Masks must be > 0; passing 0 throws.
