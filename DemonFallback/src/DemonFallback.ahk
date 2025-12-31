#Requires AutoHotkey v2.0

class DemonFallback {
    __New(config := 0) {
        this._cfg := DemonFallback._BuildConfig(config)

        this._mode := "NORMAL"
        this._lastChangeMs := 0
        this._lastReason := ""

        this._tripsJitter := 0
        this._tripsWd := 0
        this._tripsBridge := 0

        this.OnModeChanged := 0
    }

    Update(signals, nowMs := A_TickCount) {
        now := Integer(nowMs) & 0xFFFFFFFF

        sigJit := (this._Sig(signals, "jitterP95Ms", 0.0) + 0.0)
        sigWd := Integer(this._Sig(signals, "watchdogHiccups", 0))
        sigBridgeFail := Integer(this._Sig(signals, "bridgeFail", 0))

        force := Trim(this._Sig(signals, "forceMode", ""))
        disableFallback := !!this._Sig(signals, "disableFallback", false)

        ; --- Trip counters (simple + deterministic) ---
        if (sigJit > (this._cfg["JitterP95_ThresholdMs"] + 0.0))
            this._tripsJitter += 1
        else
            this._tripsJitter := Max(0, this._tripsJitter - this._cfg["TripDecayOnOk"])

        if (sigWd >= 1)
            this._tripsWd += 1
        else
            this._tripsWd := Max(0, this._tripsWd - this._cfg["TripDecayOnOk"])

        if (sigBridgeFail >= 1)
            this._tripsBridge += 1
        else
            this._tripsBridge := Max(0, this._tripsBridge - this._cfg["TripDecayOnOk"])

        ; --- Time gating (wrap-safe) ---
        sinceChange := this._SinceChangeMs(now)
        cooldownOK := (sinceChange >= this._cfg["CooldownMs"])
        holdOK := (sinceChange >= this._cfg["MinHoldMs"])

        oldMode := this._mode
        changed := false
        changeReason := ""

        ; --- Force mode (bypass cooldown/hold) ---
        if (force != "") {
            forceUp := StrUpper(force)
            if (forceUp = "NORMAL" || forceUp = "DEGRADED" || forceUp = "FALLBACK") {
                if (disableFallback && forceUp = "FALLBACK")
                    forceUp := "DEGRADED"

                if (forceUp != oldMode) {
                    this._mode := forceUp
                    this._lastChangeMs := now
                    this._lastReason := "force:" forceUp
                    changed := true
                    changeReason := this._lastReason
                    this._FireChanged(oldMode, forceUp, this._lastReason)
                }
            }
        } else {
            wantFallback := (this._tripsBridge >= this._cfg["BridgeFailTripLimit"])
            wantDegraded := (this._tripsWd >= this._cfg["WatchdogHiccupTripLimit"]) || (this._tripsJitter >= this._cfg["JitterTripLimit"])

            if disableFallback {
                if wantFallback {
                    wantFallback := false
                    wantDegraded := true
                }
            }

            ; --- Escalation (requires cooldownOK) ---
            if (!changed && cooldownOK) {
                if (wantFallback && this._mode != "FALLBACK") {
                    oldMode := this._mode
                    this._mode := "FALLBACK"
                    this._lastChangeMs := now
                    this._lastReason := "bridgeTrips>=" this._cfg["BridgeFailTripLimit"]
                    changed := true
                    changeReason := this._lastReason
                    this._FireChanged(oldMode, this._mode, this._lastReason)
                } else if (wantDegraded && this._mode = "NORMAL") {
                    oldMode := this._mode
                    this._mode := "DEGRADED"
                    this._lastChangeMs := now
                    if (this._tripsWd >= this._cfg["WatchdogHiccupTripLimit"])
                        this._lastReason := "wdTrips>=" this._cfg["WatchdogHiccupTripLimit"]
                    else
                        this._lastReason := "jitterTrips>=" this._cfg["JitterTripLimit"]
                    changed := true
                    changeReason := this._lastReason
                    this._FireChanged(oldMode, this._mode, this._lastReason)
                }
            }

            ; --- De-escalation (step-down, requires holdOK + cooldownOK + all trips==0) ---
            if (!changed && cooldownOK && holdOK && this._AllTripsZero()) {
                if (this._mode = "FALLBACK") {
                    oldMode := this._mode
                    this._mode := "DEGRADED"
                    this._lastChangeMs := now
                    this._lastReason := "recover"
                    changed := true
                    changeReason := this._lastReason
                    this._FireChanged(oldMode, this._mode, this._lastReason)
                } else if (this._mode = "DEGRADED") {
                    oldMode := this._mode
                    this._mode := "NORMAL"
                    this._lastChangeMs := now
                    this._lastReason := "recover"
                    changed := true
                    changeReason := this._lastReason
                    this._FireChanged(oldMode, this._mode, this._lastReason)
                }
            }
        }

        sinceChange2 := this._SinceChangeMs(now)
        cooldownLeft := Max(0, this._cfg["CooldownMs"] - sinceChange2)
        holdLeft := Max(0, this._cfg["MinHoldMs"] - sinceChange2)

        return Map(
            "mode", this._mode,
            "changed", changed,
            "reason", changed ? changeReason : "",
            "knobs", this._KnobsForMode(this._mode),
            "trips", this._TripsMap(),
            "cooldownLeftMs", Integer(cooldownLeft),
            "holdLeftMs", Integer(holdLeft)
        )
    }

    GetState() {
        now := (A_TickCount & 0xFFFFFFFF)
        sinceChange := this._SinceChangeMs(now)
        coolLeft := Max(0, this._cfg["CooldownMs"] - sinceChange)
        holdLeft := Max(0, this._cfg["MinHoldMs"] - sinceChange)
        return Map(
            "mode", this._mode,
            "lastChangeMs", this._lastChangeMs,
            "cooldownLeftMs", coolLeft,
            "holdLeftMs", holdLeft,
            "lastReason", this._lastReason,
            "trips", this._TripsMap()
        )
    }

    ForceMode(mode, reason := "manual", nowMs := A_TickCount) {
        m := StrUpper(Trim(mode))
        if !(m = "NORMAL" || m = "DEGRADED" || m = "FALLBACK")
            throw Error("DemonFallback.ForceMode: invalid mode")

        now := Integer(nowMs) & 0xFFFFFFFF
        oldMode := this._mode
        if (oldMode = m) {
            this._lastReason := reason
            return true
        }

        this._mode := m
        this._lastChangeMs := now
        this._lastReason := reason

        this._FireChanged(oldMode, m, reason)

        return true
    }

    Reset() {
        this._mode := "NORMAL"
        this._lastChangeMs := 0
        this._lastReason := ""

        this._tripsJitter := 0
        this._tripsWd := 0
        this._tripsBridge := 0
    }

    ; ---------------- internals ----------------

    _TripsMap() {
        return Map(
            "jitter", this._tripsJitter,
            "wd", this._tripsWd,
            "bridge", this._tripsBridge
        )
    }

    _KnobsForMode(mode) {
        m := StrUpper(mode)
        if (m = "DEGRADED")
            return DemonFallback._CopyMap(this._cfg["DegradedKnobs"])
        if (m = "FALLBACK")
            return DemonFallback._CopyMap(this._cfg["FallbackKnobs"])
        return DemonFallback._CopyMap(this._cfg["NormalKnobs"])
    }

    _AllTripsZero() {
        return (this._tripsJitter <= 0) && (this._tripsWd <= 0) && (this._tripsBridge <= 0)
    }

    _SinceChangeMs(nowMsU32) {
        if (this._lastChangeMs = 0)
            return 0xFFFFFFFF
        return ((nowMsU32 - this._lastChangeMs) & 0xFFFFFFFF)
    }

    _FireChanged(oldMode, newMode, reason) {
        cb := this.OnModeChanged
        if IsObject(cb) {
            try cb.Call(this, oldMode, newMode, reason, this._KnobsForMode(newMode))
            catch {
            }
        }
    }

    _Sig(signals, key, defaultVal) {
        if (signals is Map)
            return signals.Has(key) ? signals[key] : defaultVal

        if IsObject(signals) {
            try {
                return signals.HasOwnProp(key) ? signals.%key% : defaultVal
            } catch {
                return defaultVal
            }
        }

        return defaultVal
    }

    static _CopyMap(m) {
        out := Map()
        if (m is Map) {
            for k, v in m
                out[k] := v
        } else if IsObject(m) {
            ; best effort: enumerate own props if possible
            try {
                for k, v in m.OwnProps()
                    out[k] := v
            } catch {
            }
        }
        return out
    }

    static _BuildConfig(config) {
        cfg := Map()

        cfg["JitterP95_ThresholdMs"] := 0.60
        cfg["JitterTripLimit"] := 2
        cfg["BridgeFailTripLimit"] := 3
        cfg["WatchdogHiccupTripLimit"] := 1

        cfg["TripDecayOnOk"] := 1
        cfg["CooldownMs"] := 1500
        cfg["MinHoldMs"] := 800

        cfg["NormalKnobs"] := Map("workMs", 8, "hudMs", 100, "bridgeMs", 20, "predictorDecimate", 2, "timerRes", false)
        cfg["DegradedKnobs"] := Map("workMs", 20, "hudMs", 250, "bridgeMs", 100, "predictorDecimate", 3, "timerRes", true)
        cfg["FallbackKnobs"] := Map("workMs", 30, "hudMs", 500, "bridgeMs", 250, "predictorDecimate", 4, "timerRes", true)

        if (config is Map) {
            for k, v in config
                cfg[k] := v
        } else if IsObject(config) {
            for k in cfg {
                try {
                    if config.HasOwnProp(k)
                        cfg[k] := config.%k%
                } catch {
                }
            }
        }

        ; sanitize numeric fields
        cfg["JitterP95_ThresholdMs"] := (cfg["JitterP95_ThresholdMs"] + 0.0)
        cfg["JitterTripLimit"] := Max(1, Integer(cfg["JitterTripLimit"]))
        cfg["BridgeFailTripLimit"] := Max(1, Integer(cfg["BridgeFailTripLimit"]))
        cfg["WatchdogHiccupTripLimit"] := Max(1, Integer(cfg["WatchdogHiccupTripLimit"]))
        cfg["TripDecayOnOk"] := Max(0, Integer(cfg["TripDecayOnOk"]))
        cfg["CooldownMs"] := Max(0, Integer(cfg["CooldownMs"]))
        cfg["MinHoldMs"] := Max(0, Integer(cfg["MinHoldMs"]))

        return cfg
    }
}
