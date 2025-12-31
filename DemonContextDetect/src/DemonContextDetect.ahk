#Requires AutoHotkey v2.0

class DemonContextDetect {
    __New(config := "") {
        this._cfg := DemonContextDetect._MergeCfg(DemonContextDetect._DefaultCfg(), config)
        this.Reset()
    }

    ; Update(dx, dy, dtMs, nowMs := A_TickCount)
    ; Returns Map with keys:
    ; context, confidence, vel, avgSpeed, hvRatio, spike, changed, reason, holdLeftMs
    Update(dx, dy, dtMs, nowMs := A_TickCount) {
        dt := Max(1.0, (dtMs + 0.0))
        now := (Integer(nowMs) & 0xFFFFFFFF)

        ax := Abs(dx + 0.0)
        ay := Abs(dy + 0.0)
        this._mag := Sqrt((dx + 0.0) * (dx + 0.0) + (dy + 0.0) * (dy + 0.0))
        this._vel := this._mag / dt

        hvEps := this._cfg["HvEps"] + 0.0
        if (hvEps <= 0.0)
            hvEps := 0.001
        this._hvRatio := ax / (ay + hvEps)

        ; avgSpeed EMA over vel
        tau := this._cfg["TauAvgMs"] + 0.0
        if (tau > 0.0) {
            a := 1.0 - Exp(-dt / tau)
        } else {
            a := this._cfg["FixedAvgAlpha"] + 0.0
        }
        if (a < 0.0)
            a := 0.0
        else if (a > 1.0)
            a := 1.0
        this._avgSpeed += a * (this._vel - this._avgSpeed)

        spikeEps := this._cfg["SpikeEps"] + 0.0
        if (spikeEps <= 0.0)
            spikeEps := 0.00001
        if (this._avgSpeed > spikeEps)
            this._spike := this._vel / this._avgSpeed
        else
            this._spike := 0.0

        v := this._vel
        av := this._avgSpeed

        oldCtx := this._context
        candidate := oldCtx

        idleOn := this._cfg["IdleOn"] + 0.0
        idleOff := this._cfg["IdleOff"] + 0.0
        longOn := this._cfg["LongOn"] + 0.0
        longOff := this._cfg["LongOff"] + 0.0
        closeOn := this._cfg["CloseOn"] + 0.0
        closeOff := this._cfg["CloseOff"] + 0.0

        ; Schmitt decision by current context
        if (oldCtx = "Idle") {
            if (av >= longOn || v >= longOn)
                candidate := "LongRange"
        } else if (oldCtx = "LongRange") {
            if (av >= closeOn || v >= closeOn)
                candidate := "CloseRange"
            else if (av <= idleOn && v <= idleOn)
                candidate := "Idle"
        } else if (oldCtx = "CloseRange") {
            if (av <= closeOff && v <= closeOff)
                candidate := "LongRange"
        } else {
            ; Safety: keep v1 contexts only.
            candidate := "Idle"
        }

        holdLeft := this._HoldLeftMs(now)
        changed := false
        reason := ""

        if (candidate != oldCtx) {
            if (holdLeft > 0) {
                reason := "hold"
            } else {
                this._context := candidate
                this._ctxSinceMs := now
                changed := true
                reason := DemonContextDetect._ReasonForTransition(oldCtx, candidate)
                this._FireChanged(oldCtx, candidate, reason)
            }
        }

        ; Confidence (based on avgSpeed)
        this._confidence := DemonContextDetect._ConfidenceFor(this._context, av, idleOn, idleOff, longOff, closeOff, closeOn)

        this._reason := reason

        return Map(
            "context", this._context,
            "confidence", this._confidence,
            "vel", this._vel,
            "avgSpeed", this._avgSpeed,
            "hvRatio", this._hvRatio,
            "spike", this._spike,
            "changed", changed,
            "reason", reason,
            "holdLeftMs", this._HoldLeftMs(now)
        )
    }

    Reset() {
        this._context := "Idle"
        this._confidence := 0.0
        this._vel := 0.0
        this._mag := 0.0
        this._avgSpeed := 0.0
        this._hvRatio := 1.0
        this._spike := 0.0
        this._reason := ""
        this._ctxSinceMs := 0
    }

    GetState() {
        now := (A_TickCount & 0xFFFFFFFF)
        return Map(
            "context", this._context,
            "confidence", this._confidence,
            "vel", this._vel,
            "avgSpeed", this._avgSpeed,
            "hvRatio", this._hvRatio,
            "spike", this._spike,
            "reason", this._reason,
            "ctxSinceMs", this._ctxSinceMs,
            "holdLeftMs", this._HoldLeftMs(now),
            "thresholds", DemonContextDetect._CopyThresholds(this._cfg)
        )
    }

    _HoldLeftMs(nowU32) {
        hold := Integer(this._cfg["HoldMs"])
        if (hold <= 0)
            return 0
        if (this._ctxSinceMs = 0)
            return 0
        age := ((nowU32 - this._ctxSinceMs) & 0xFFFFFFFF)
        left := hold - age
        return (left > 0) ? left : 0
    }

    static _DefaultCfg() {
        ; Units: vel is |(dx,dy)| / dtMs (counts per ms)
        return Map(
            "TauAvgMs", 120.0,
            "FixedAvgAlpha", 0.12,
            "HoldMs", 120,
            "HvEps", 0.001,
            "SpikeEps", 0.00001,
            "IdleOn", 0.08,
            "IdleOff", 0.12,
            "LongOn", 0.35,
            "LongOff", 0.25,
            "CloseOn", 0.90,
            "CloseOff", 0.70
        )
    }

    static _Clamp01(x) {
        if (x < 0.0)
            return 0.0
        if (x > 1.0)
            return 1.0
        return x + 0.0
    }

    static _ConfidenceFor(ctx, av, idleOn, idleOff, longOff, closeOff, closeOn) {
        a := av + 0.0

        if (ctx = "Idle") {
            denom := (idleOff - idleOn) + 0.0
            if (denom <= 0.0)
                return 1.0
            return 1.0 - DemonContextDetect._Clamp01((a - idleOn) / denom)
        }

        if (ctx = "CloseRange") {
            denom := (closeOn - closeOff) + 0.0
            if (denom <= 0.0)
                return 1.0
            return DemonContextDetect._Clamp01((a - closeOff) / denom)
        }

        ; LongRange
        denom := (closeOff - longOff) + 0.0
        if (denom <= 0.0)
            return 0.5
        return DemonContextDetect._Clamp01((a - longOff) / denom)
    }

    static _ReasonForTransition(oldCtx, newCtx) {
        if (oldCtx = "Idle" && newCtx = "LongRange")
            return "idle->long"
        if (oldCtx = "LongRange" && newCtx = "CloseRange")
            return "long->close"
        if (oldCtx = "CloseRange" && newCtx = "LongRange")
            return "close->long"
        if (oldCtx = "LongRange" && newCtx = "Idle")
            return "long->idle"
        return ""
    }

    static _CopyThresholds(cfg) {
        return Map(
            "IdleOn", cfg["IdleOn"],
            "IdleOff", cfg["IdleOff"],
            "LongOn", cfg["LongOn"],
            "LongOff", cfg["LongOff"],
            "CloseOn", cfg["CloseOn"],
            "CloseOff", cfg["CloseOff"],
            "HoldMs", cfg["HoldMs"],
            "TauAvgMs", cfg["TauAvgMs"],
            "FixedAvgAlpha", cfg["FixedAvgAlpha"],
            "HvEps", cfg["HvEps"],
            "SpikeEps", cfg["SpikeEps"]
        )
    }

    _FireChanged(oldCtx, newCtx, reason) {
        cb := this.OnContextChanged
        if IsObject(cb) {
            try {
                cb.Call(this, oldCtx, newCtx, reason, this._confidence)
            } catch {
            }
        }
    }

    static _MergeCfg(base, override) {
        out := Map()
        for k, v in base
            out[k] := v

        if IsObject(override) {
            for k, v in override
                out[k] := v
        }
        return out
    }
}
