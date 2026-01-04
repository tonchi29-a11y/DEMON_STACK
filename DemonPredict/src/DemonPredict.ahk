#Requires AutoHotkey v2.0

class DemonPredict {
    __New(cfg := 0) {
        this._cfg := DemonPredict._DefaultCfg()
        if IsObject(cfg)
            DemonPredict._MergeCfg(this._cfg, cfg)

        this._desired := "HPR"
        this._adsProb := 0.0

        this._onMs := 0.0
        this._offMs := 0.0
        this._lastChangeMs := 0

        this.OnDecisionChanged := 0
    }

    Reset() {
        this._desired := "HPR"
        this._adsProb := 0.0
        this._onMs := 0.0
        this._offMs := 0.0
        this._lastChangeMs := 0
    }

    ; Update decision engine.
    ; context: "Idle"|"LongRange"|"CloseRange"
    ; confidence: 0..1
    ; vel/avgSpeed/hvRatio/spike: floats (from ContextDetect)
    ; rmbDown: bool (optional manual override)
    ; dtMs: ms since last update (clamped >=1)
    ; nowMs: time base (A_TickCount), wrap-safe
    Update(context, confidence, vel, avgSpeed, hvRatio, spike, rmbDown := false, dtMs := 4, nowMs := A_TickCount) {
        dt := Max(1.0, (dtMs + 0.0))
        ctx := context ""
        now := (Integer(nowMs) & 0xFFFFFFFF)

        prob := this._ComputeAdsProb(ctx, confidence + 0.0, vel + 0.0, avgSpeed + 0.0, hvRatio + 0.0, spike + 0.0, !!rmbDown)
        this._adsProb := prob

        changed := false
        reason := ""

        ; cooldown gate
        since := ((now - this._lastChangeMs) & 0xFFFFFFFF)
        cooldownOk := (since >= Integer(this._cfg["CooldownMs"]))

        tOn := this._cfg["T_ON"] + 0.0
        tOff := this._cfg["T_OFF"] + 0.0
        tauOn := this._cfg["TAU_ON_MS"] + 0.0
        tauOff := this._cfg["TAU_OFF_MS"] + 0.0

        ; Manual override (optional)
        if (this._cfg["RmbOverrides"] && rmbDown) {
            ; immediate ADS if not already
            if (this._desired != "ADS" && cooldownOk) {
                this._desired := "ADS"
                this._lastChangeMs := now
                this._onMs := 0.0
                this._offMs := 0.0
                changed := true
                reason := "rmb"
            }
            return this._ResultMap(prob, changed, reason, now)
        }

        ; Schmitt + timers
        if (prob >= tOn) {
            this._onMs += dt
            this._offMs := 0.0
        } else if (prob <= tOff) {
            this._offMs += dt
            this._onMs := 0.0
        } else {
            ; middle band: decay both slowly to avoid sticky state
            this._onMs := Max(0.0, this._onMs - (dt * 0.5))
            this._offMs := Max(0.0, this._offMs - (dt * 0.5))
        }

        ; Engage ADS
        if (this._desired = "HPR") && (this._onMs >= tauOn) && cooldownOk {
            this._desired := "ADS"
            this._lastChangeMs := now
            this._onMs := 0.0
            this._offMs := 0.0
            changed := true
            reason := "tau_on"
        }

        ; Return to HPR
        if (this._desired = "ADS") && (this._offMs >= tauOff) && cooldownOk {
            this._desired := "HPR"
            this._lastChangeMs := now
            this._onMs := 0.0
            this._offMs := 0.0
            changed := true
            reason := "tau_off"
        }

        if changed {
            cb := this.OnDecisionChanged
            if IsObject(cb) {
                try {
                    cb.Call(this, this._desired, reason, prob)
                } catch {
                }
            }
        }

        return this._ResultMap(prob, changed, reason, now)
    }

    GetState() {
        return Map(
            "desired", this._desired,
            "adsProb", this._adsProb,
            "onMs", this._onMs,
            "offMs", this._offMs,
            "lastChangeMs", this._lastChangeMs
        )
    }

    _ResultMap(prob, changed, reason, nowMs) {
        since := ((nowMs - this._lastChangeMs) & 0xFFFFFFFF)
        cd := Integer(this._cfg["CooldownMs"])
        cdLeft := (since >= cd) ? 0 : (cd - since)

        return Map(
            "adsProb", prob,
            "desired", this._desired,
            "changed", !!changed,
            "reason", reason,
            "onMs", this._onMs,
            "offMs", this._offMs,
            "cooldownLeftMs", cdLeft
        )
    }

    _ComputeAdsProb(ctx, conf, vel, avgSpeed, hvRatio, spike, rmbDown) {
        if (this._cfg["RmbOverrides"] && rmbDown)
            return 1.0

        ; Context contribution
        ctxScore := 0.0
        if (ctx = "CloseRange")
            ctxScore := 1.0
        else if (ctx = "LongRange")
            ctxScore := 0.45
        else
            ctxScore := 0.0

        ctxScore *= DemonPredict._Clamp01(conf)

        ; Spike contribution (vel/avg)
        sMin := this._cfg["SpikeMin"] + 0.0
        sMax := this._cfg["SpikeMax"] + 0.0
        sNorm := (sMax - sMin) + 0.0
        spikeScore := DemonPredict._Clamp01((spike - sMin) / ((sNorm = 0.0) ? 1.0 : sNorm))

        ; hvRatio contribution
        hMin := this._cfg["HvMin"] + 0.0
        hMax := this._cfg["HvMax"] + 0.0
        hNorm := (hMax - hMin) + 0.0
        hvScore := DemonPredict._Clamp01((hvRatio - hMin) / ((hNorm = 0.0) ? 1.0 : hNorm))

        ; speed contribution (avgSpeed)
        vMin := this._cfg["SpeedMin"] + 0.0
        vMax := this._cfg["SpeedMax"] + 0.0
        vNorm := (vMax - vMin) + 0.0
        speedScore := DemonPredict._Clamp01((avgSpeed - vMin) / ((vNorm = 0.0) ? 1.0 : vNorm))

        wCtx := this._cfg["W_CTX"] + 0.0
        wSpike := this._cfg["W_SPIKE"] + 0.0
        wHv := this._cfg["W_HV"] + 0.0
        wSpeed := this._cfg["W_SPEED"] + 0.0

        prob := (wCtx * ctxScore) + (wSpike * spikeScore) + (wHv * hvScore) + (wSpeed * speedScore)
        return DemonPredict._Clamp01(prob)
    }

    ; ---------- defaults ----------
    static _DefaultCfg() {
        return Map(
            ; Manual override
            "RmbOverrides", true,

            ; Schmitt + timers
            "T_ON", 0.55,
            "T_OFF", 0.45,
            "TAU_ON_MS", 40.0,
            "TAU_OFF_MS", 75.0,
            "CooldownMs", 250,

            ; Feature normalization
            "SpikeMin", 1.5,
            "SpikeMax", 3.0,
            "HvMin", 1.0,
            "HvMax", 3.0,
            "SpeedMin", 0.10,
            "SpeedMax", 1.20,

            ; Weights (sum doesn’t need to be 1; clamp01 applied at end)
            "W_CTX", 0.40,
            "W_SPIKE", 0.35,
            "W_HV", 0.10,
            "W_SPEED", 0.15
        )
    }

    static _MergeCfg(dst, src) {
        for k, v in src
            dst[k] := v
    }

    static _Clamp01(x) {
        if (x < 0.0)
            return 0.0
        if (x > 1.0)
            return 1.0
        return x + 0.0
    }
}
