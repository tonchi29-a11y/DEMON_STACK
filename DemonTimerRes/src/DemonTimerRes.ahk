#Requires AutoHotkey v2.0

class DemonTimerRes {
    static _refs := 0
    static _ms := 0

    ; Acquire a timer resolution request (usually 1ms).
    ; Returns true if request succeeded, false otherwise.
    static Acquire(ms := 1) {
        ms := Max(1, Integer(ms))

        ; If already acquired at same ms, just refcount.
        if (DemonTimerRes._refs > 0) {
            if (DemonTimerRes._ms != ms)
                return false
            DemonTimerRes._refs += 1
            return true
        }

        rc := 0
        try rc := DllCall("winmm.dll\timeBeginPeriod", "UInt", ms, "UInt")
        catch {
            ; API not available or call failed
            return false
        }

        if (rc != 0) {
            ; Failed to set. Keep refs=0 to avoid mismatched Release.
            return false
        }

        DemonTimerRes._refs := 1
        DemonTimerRes._ms := ms
        return true
    }

    ; Release one reference. Safe to call extra times (won’t go below 0).
    static Release() {
        if (DemonTimerRes._refs <= 0)
            return false

        DemonTimerRes._refs -= 1
        if (DemonTimerRes._refs > 0)
            return true

        ms := DemonTimerRes._ms
        DemonTimerRes._ms := 0

        rc := 0
        try rc := DllCall("winmm.dll\timeEndPeriod", "UInt", ms, "UInt")
        catch {
            ; Even if the API isn't available, consider ourselves released.
            return false
        }

        ; Even if rc!=0, we consider ourselves released to avoid leaks.
        return (rc = 0)
    }

    static GetState() {
        return Map(
            "refs", DemonTimerRes._refs,
            "ms", DemonTimerRes._ms
        )
    }
}
