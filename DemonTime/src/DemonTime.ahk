#Requires AutoHotkey v2.0

class DemonTime {
    static _freq := 0

    ; Returns QPC frequency (ticks per second) as int64
    static Freq() {
        if (this._freq)
            return this._freq
        f := 0
        if !DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &f)
            throw Error("QueryPerformanceFrequency failed")
        this._freq := f
        return f
    }

    ; Returns QPC counter as int64
    static NowQpc() {
        c := 0
        if !DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &c)
            throw Error("QueryPerformanceCounter failed")
        return c
    }

    ; Returns elapsed milliseconds since qpcStart (float)
    static MsSince(qpcStart) {
        dt := this.NowQpc() - qpcStart
        return (dt * 1000.0) / this.Freq()
    }

    ; Returns elapsed seconds since qpcStart (float)
    static SecSince(qpcStart) {
        dt := this.NowQpc() - qpcStart
        return dt / this.Freq()
    }

    ; AHK tick (ms, 32-bit wrap). Useful for coarse timing.
    static Tick() => A_TickCount

    ; Sleep wrapper + measure actual elapsed using QPC
    static MeasureSleep(ms) {
        t0 := this.NowQpc()
        Sleep ms
        return this.MsSince(t0)
    }
}
