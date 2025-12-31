#Requires AutoHotkey v2.0

class DemonAffinity {
    ; Returns number of logical processors (best-effort).
    static CpuCount() {
        try {
            return DllCall("kernel32.dll\GetActiveProcessorCount", "UInt", 0xFFFF, "UInt")
        } catch {
            si := Buffer(48, 0)
            DllCall("kernel32.dll\GetSystemInfo", "Ptr", si.Ptr)
            return NumGet(si, 24 + A_PtrSize, "UInt")
        }
    }

    ; Build an affinity mask from a list of CPU indices (0-based).
    ; Example: MaskFromList([2,3,4]) pins to CPUs 2-4.
    static MaskFromList(indices) {
        if !IsObject(indices)
            throw TypeError("indices must be an Array/List")

        cpuLimit := Min(DemonAffinity.CpuCount(), 64)
        mask := 0

        for _, i in indices {
            i := Integer(i)
            if (i < 0 || i >= cpuLimit)
                continue
            mask |= (1 << i)
        }
        return mask
    }

    ; Build a contiguous mask: skip first N CPUs, then take count CPUs.
    ; Example: MakeMask(skip:=2, count:=4) -> CPUs 2,3,4,5
    static MakeMask(skip := 0, count := 1) {
        skip := Max(0, Integer(skip))
        count := Max(1, Integer(count))

        cpuLimit := Min(DemonAffinity.CpuCount(), 64)
        start := Min(skip, cpuLimit - 1)
        stop := Min(start + count - 1, cpuLimit - 1)

        mask := 0
        Loop (stop - start + 1) {
            cpu := start + (A_Index - 1)
            mask |= (1 << cpu)
        }
        return mask
    }

    ; Applies affinity mask to the current process.
    ; Returns true on success, false on failure.
    static SetCurrentProcess(mask) {
        mask := DemonAffinity._ToPtrMask(mask)
        hProc := DllCall("kernel32.dll\GetCurrentProcess", "Ptr")
        ok := 0
        try ok := DllCall("kernel32.dll\SetProcessAffinityMask", "Ptr", hProc, "Ptr", mask, "Int")
        catch {
            return false
        }
        return !!ok
    }

    ; Reads current process affinity mask.
    ; Returns Map("processMask", <ptr/int>, "systemMask", <ptr/int>) or throws if APIs fail.
    static GetCurrentProcess() {
        hProc := DllCall("kernel32.dll\GetCurrentProcess", "Ptr")
        pm := 0, sm := 0
        ok := 0
        try ok := DllCall("kernel32.dll\GetProcessAffinityMask", "Ptr", hProc, "PtrP", &pm, "PtrP", &sm, "Int")
        catch {
            throw Error("GetProcessAffinityMask DllCall failed.")
        }
        if !ok
            throw Error("GetProcessAffinityMask failed. LastError=" A_LastError)
        return Map("processMask", pm, "systemMask", sm)
    }

    ; Pins the current thread to a CPU mask (temporary pinning).
    ; Returns previous mask (Ptr/int) or 0 on failure.
    static SetCurrentThread(mask) {
        mask := DemonAffinity._ToPtrMask(mask)
        hThread := DllCall("kernel32.dll\GetCurrentThread", "Ptr")
        prev := 0
        try prev := DllCall("kernel32.dll\SetThreadAffinityMask", "Ptr", hThread, "Ptr", mask, "Ptr")
        catch {
            return 0
        }
        return prev
    }

    ; Restores thread affinity using the value returned by SetCurrentThread.
    static RestoreThread(prevMask) {
        if !prevMask
            return false
        hThread := DllCall("kernel32.dll\GetCurrentThread", "Ptr")
        out := 0
        try out := DllCall("kernel32.dll\SetThreadAffinityMask", "Ptr", hThread, "Ptr", prevMask, "Ptr")
        catch {
            return false
        }
        return !!out
    }

    ; --- helpers ---
    static _ToPtrMask(mask) {
        ; AHK integers are 64-bit on x64. This is fine for <=64 CPUs.
        ; For >64 CPUs, Windows uses processor groups (out of scope for v1).
        m := Integer(mask)
        if (m = 0)
            throw Error("Affinity mask must be non-zero")
        return m
    }
}
