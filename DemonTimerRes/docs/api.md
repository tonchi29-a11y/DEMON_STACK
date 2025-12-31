# DemonTimerRes — API

## `DemonTimerRes.Acquire(ms := 1)`
Requests a timer resolution (usually `1` ms).

- **Params**: `ms` (integer, minimum 1)
- **Returns**:
  - `true` if the request is active (or ref-count incremented)
  - `false` if the API call failed / is unavailable, or if already acquired with a different `ms`

### Behavior
- First successful `Acquire()` calls `timeBeginPeriod(ms)` and sets internal refcount to 1.
- Subsequent `Acquire(ms)`:
  - if `ms` matches the currently held value: increments refcount and returns `true`
  - if `ms` differs: returns `false` and does **not** change refcount

## `DemonTimerRes.Release()`
Releases one reference.

- **Returns**:
  - `true` if refcount decreased and the request remains active, or if `timeEndPeriod` succeeds on final release
  - `false` if there was nothing to release, or if the final `timeEndPeriod` call failed/unavailable

### Behavior
- Decrements refcount.
- When refcount reaches 0, calls `timeEndPeriod(ms)` and clears internal state.

## `DemonTimerRes.GetState()`
Returns current state.

- **Returns**: `Map("refs", <int>, "ms", <int>)`
