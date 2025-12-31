#Requires AutoHotkey v2.0

class DemonWatchdog {
    __New(periodMs := 250, toleranceMs := 120, degradedAfter := 3, recoverBelow := 2) {
        ; Ensure DemonTime exists
        try DemonTime.Freq()
        catch
            throw Error("DemonWatchdog requires DemonTime. Include DemonTime.ahk first.")

        this.periodMs := Max(1, Integer(periodMs))
        this.toleranceMs := Max(0, Integer(toleranceMs))
        this.degradedAfter := Max(1, Integer(degradedAfter))
        this.recoverBelow := Integer(recoverBelow) ; allow -1 sentinel meaning "never auto-exit"

        ; Public callback slots (assign Func objects or closures)
        this.OnStall := 0
        this.OnDegradedChanged := 0

        ; Public readable state
        this.hiccups := 0
        this.lastDeltaMs := 0.0

        ; Internal state
        this._isDegraded := false
        this._running := false
        this._lastQpc := 0
        this._timerFn := ObjBindMethod(this, "_Tick")
    }

    Start() {
        if this._running
            return
        this._running := true

        this.hiccups := 0
        this.lastDeltaMs := 0.0
        this._isDegraded := false
        this._lastQpc := DemonTime.NowQpc()

        SetTimer(this._timerFn, this.periodMs)
    }

    Stop() {
        if !this._running
            return
        SetTimer(this._timerFn, 0)
        this._running := false
    }

    Touch() {
        ; Optional: reset baseline if you intentionally blocked the script
        this._lastQpc := DemonTime.NowQpc()
    }

    IsDegraded() => this._isDegraded

    EnterDegraded(reason := "") {
        if this._isDegraded
            return
        this._isDegraded := true
        this._CallDegradedChanged(true, reason)
    }

    ExitDegraded(reason := "") {
        if !this._isDegraded
            return
        this._isDegraded := false
        this._CallDegradedChanged(false, reason)
    }

    _Tick(*) {
        now := DemonTime.NowQpc()
        if !this._lastQpc {
            this._lastQpc := now
            return
        }

        dtMs := (now - this._lastQpc) * 1000.0 / DemonTime.Freq()
        this._lastQpc := now
        this.lastDeltaMs := dtMs

        threshold := this.periodMs + this.toleranceMs
        if (dtMs > threshold) {
            this.hiccups += 1
            this._CallOnStall(dtMs, threshold)

            if (!this._isDegraded && this.hiccups >= this.degradedAfter)
                this.EnterDegraded("hiccups>=" this.degradedAfter)

            this._lastQpc := DemonTime.NowQpc()
            return
        }

        ; Recovery: decay hiccups on good ticks
        if (this.hiccups > 0)
            this.hiccups -= 1

        if (this._isDegraded && this.recoverBelow >= 0 && this.hiccups <= this.recoverBelow)
            this.ExitDegraded("hiccups<=" this.recoverBelow)
    }

    _CallOnStall(dtMs, thresholdMs) {
        cb := this.OnStall
        if !cb
            return
        try cb.Call(this, dtMs, thresholdMs)
        catch {
            ; never crash host due to callback
        }
    }

    _CallDegradedChanged(isDegraded, reason) {
        cb := this.OnDegradedChanged
        if !cb
            return
        try cb.Call(this, isDegraded, reason)
        catch {
        }
    }

    __Delete() {
        try this.Stop()
    }
}
