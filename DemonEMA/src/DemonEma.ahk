#Requires AutoHotkey v2.0

class DemonEma {
    __New(tauMs := 25.0, fixedAlpha := 0.12) {
        this.tauMs := tauMs + 0.0
        this.fixedAlpha := fixedAlpha + 0.0
        this._x := 0.0
        this._y := 0.0
        this._lastTms := "" ; for UpdateSample()
    }

    Reset(x := 0.0, y := 0.0) {
        this._x := x + 0.0
        this._y := y + 0.0
        this._lastTms := ""
    }

    ; Update with explicit dt in milliseconds
    Update(dx, dy, dtMs) {
        a := this.AlphaFromDt(dtMs)
        this._x += a * (dx - this._x)
        this._y += a * (dy - this._y)
        return a
    }

    ; Convenience: pass a timestamp (ms), EMA computes dt internally.
    ; First call sets baseline and returns 0 alpha (no update).
    UpdateSample(dx, dy, tMs) {
        if (this._lastTms = "") {
            this._lastTms := tMs
            return 0.0
        }
        dt := (tMs - this._lastTms)
        this._lastTms := tMs
        if (dt < 0)
            dt := 0
        return this.Update(dx, dy, dt)
    }

    AlphaFromDt(dtMs) {
        dt := dtMs + 0.0
        if (dt < 0)
            dt := 0

        ; dt-based alpha if tauMs > 0, else fixed alpha
        if (this.tauMs > 0.0) {
            ; a = 1 - exp(-dt/tau)
            return 1.0 - Exp(-dt / this.tauMs)
        }

        ; fixed alpha mode
        a := this.fixedAlpha
        if (a < 0.0)
            a := 0.0
        else if (a > 1.0)
            a := 1.0
        return a
    }

    X() => this._x
    Y() => this._y
}
