#Requires AutoHotkey v2.0

class DemonChaos {
    __New(cfg := 0) {
        this._cfg := DemonChaos._DefaultCfg()
        if IsObject(cfg)
            DemonChaos._MergeCfg(this._cfg, cfg)

        this._x := 0.01
        this._y := 0.01
        this._z := 0.01
        this._cooldownUntil := 0
    }

    Reset() {
        this._x := 0.01
        this._y := 0.01
        this._z := 0.01
        this._cooldownUntil := 0
    }

    Step(drive := 0.0, dtMs := 4, nowMs := A_TickCount) {
        dtSec := (dtMs < 1 ? 0.001 : dtMs + 0.0) / 1000.0
        s := this._cfg["Sigma"] + 0.0
        b := this._cfg["Beta"] + 0.0
        r := this._cfg["Rho"] + 0.0
        gain := this._cfg["DriveGain"] + 0.0

        ; Lorenz with drive on x
        dx := (s * (this._y - this._x)) + (gain * drive)
        dy := (this._x * (r - this._z)) - this._y
        dz := (this._x * this._y) - (b * this._z)

        this._x += dx * dtSec
        this._y += dy * dtSec
        this._z += dz * dtSec

        score := Sqrt((this._x*this._x) + (this._y*this._y) + (this._z*this._z))

        thresh := this._cfg["Threshold"] + 0.0
        cooldownMs := Round(this._cfg["CooldownMs"])

        inCd := false
        cdLeft := 0

        untilMs := this._cooldownUntil & 0xFFFFFFFF
        diff := (untilMs - (nowMs & 0xFFFFFFFF)) & 0xFFFFFFFF
        if (diff != 0) && (diff < 0x80000000) {
            inCd := true
            cdLeft := diff
        }

        triggered := false
        if (score >= thresh) && !inCd {
            triggered := true
            this._cooldownUntil := ((nowMs + cooldownMs) & 0xFFFFFFFF)
        }

        ; bias: normalized excess above threshold, 0..1
        excess := score - thresh
        bias := 0.0
        if (excess > 0) {
            norm := excess / (thresh > 0 ? thresh : 1.0)
            if (norm > 1.0)
                norm := 1.0
            bias := (this._cfg["BiasGain"] + 0.0) * norm
            if inCd && (bias < this._cfg["BiasFloorDuringCooldown"] + 0.0)
                bias := this._cfg["BiasFloorDuringCooldown"] + 0.0
        } else if inCd {
            bias := this._cfg["BiasFloorDuringCooldown"] + 0.0
        }

        return Map(
            "score", score,
            "triggered", triggered,
            "bias", bias,
            "cooldownLeftMs", cdLeft
        )
    }

    GetState() {
        return Map("x", this._x, "y", this._y, "z", this._z, "cooldownUntil", this._cooldownUntil)
    }

    ; ---------- internals ----------
    static _DefaultCfg() {
        return Map(
            "Sigma", 10.0,
            "Rho", 28.0,
            "Beta", 8.0/3.0,
            "DriveGain", 0.5,
            "Threshold", 12.0,
            "CooldownMs", 200,
            "BiasGain", 0.25,
            "BiasFloorDuringCooldown", 0.10
        )
    }

    static _MergeCfg(dst, src) {
        for k, v in src
            dst[k] := v
    }
}
