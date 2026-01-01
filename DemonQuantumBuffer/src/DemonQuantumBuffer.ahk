#Requires AutoHotkey v2.0

class DemonQuantumBuffer {
    __New(cfg := 0) {
        this._cfg := DemonQuantumBuffer._DefaultCfg()
        if IsObject(cfg)
            DemonQuantumBuffer._MergeCfg(this._cfg, cfg)

        this._q := 0.0
        this._rng := 0xDEADBEEF  ; simple LCG seed
    }

    Reset() {
        this._q := 0.0
    }

    SetSeed(seed) {
        this._rng := seed & 0xFFFFFFFF
    }

    Update(magnitude, dtMs := 4, nowMs := A_TickCount) {
        dt := (dtMs < 1) ? 1.0 : (dtMs + 0.0)
        baseDt := this._cfg["BaseDtMs"] + 0.0
        decay := this._cfg["Decay"] + 0.0
        k := this._cfg["Gain"] + 0.0
        thr := this._cfg["Threshold"] + 0.0
        unc := this._cfg["Uncertainty"] + 0.0
        noiseAmp := this._cfg["NoiseAmp"] + 0.0

        factor := dt / (baseDt > 0 ? baseDt : 1.0)
        dPow := decay ** factor

        ; LCG noise in [-1,1]
        this._rng := (1664525 * this._rng + 1013904223) & 0xFFFFFFFF
        u := this._rng / 4294967296.0
        noise := (u * 2.0 - 1.0) * (noiseAmp * unc)

        q := (this._q * dPow) + (k * (magnitude + 0.0)) + noise

        collapsed := (q >= thr)
        allow := false

        if collapsed {
            allow := true
            q := 0.0
        }

        this._q := (q < 0.0) ? 0.0 : q

        return Map(
            "collapsed", collapsed,
            "allow", allow,
            "q", this._q
        )
    }

    GetState() {
        return Map("q", this._q, "seed", this._rng)
    }

    ; ---------- internals ----------
    static _DefaultCfg() {
        return Map(
            "BaseDtMs", 4.0,
            "Decay", 0.92,
            "Gain", 0.10,
            "Threshold", 2.0,
            "Uncertainty", 1.0,
            "NoiseAmp", 0.10
        )
    }

    static _MergeCfg(dst, src) {
        for k, v in src
            dst[k] := v
    }
}
