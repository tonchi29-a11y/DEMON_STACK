#Requires AutoHotkey v2.0

class DemonNeuromorphic {
    __New(cfg := 0) {
        this._cfg := DemonNeuromorphic._DefaultCfg()
        if IsObject(cfg)
            DemonNeuromorphic._MergeCfg(this._cfg, cfg)

        this._count := Max(0, Round(this._cfg["Count"]))
        this._p := []
        this._refUntil := []
        this._spikesTotal := 0

        Loop this._count {
            this._p.Push(0.0)
            this._refUntil.Push(0)
        }
    }

    Reset() {
        i := 1
        Loop this._count {
            this._p[i] := 0.0
            this._refUntil[i] := 0
            i += 1
        }
        this._spikesTotal := 0
    }

    ; intensities: Array of floats (length <= Count)
    Update(intensities, dtMs := 4, nowMs := A_TickCount) {
        dt := (dtMs < 1) ? 1.0 : (dtMs + 0.0)
        baseDt := this._cfg["BaseDtMs"] + 0.0
        decay := this._cfg["Decay"] + 0.0
        lr := this._cfg["LearningRate"] + 0.0
        thr := this._cfg["Threshold"] + 0.0
        refr := Round(this._cfg["RefractoryMs"])
        spikeBoost := this._cfg["SpikeBoost"] + 0.0
        maxBoost := this._cfg["MaxBoost"] + 0.0

        factor := dt / (baseDt > 0 ? baseDt : 1.0)
        dPow := decay ** factor

        spikeIdx := []
        spiked := false
        spikeCount := 0

        i := 1
        Loop this._count {
            inten := 0.0
            if IsObject(intensities) && (i <= intensities.Length)
                inten := intensities[i] + 0.0
            if inten < 0
                inten := 0.0

            untilMs := this._refUntil[i] & 0xFFFFFFFF
            diff := (untilMs - (nowMs & 0xFFFFFFFF)) & 0xFFFFFFFF

            ; refractory active only if until is strictly in the future
            if (diff != 0) && (diff < 0x80000000) {
                this._p[i] := 0.0
            } else {
                ; integrate with decay
                p := (this._p[i] * dPow) + (lr * inten)
                if (p >= thr) {
                    spiked := true
                    spikeCount += 1
                    spikeIdx.Push(i)
                    this._p[i] := 0.0
                    this._refUntil[i] := ((nowMs + refr) & 0xFFFFFFFF)
                    this._spikesTotal += 1
                } else {
                    this._p[i] := p
                }
            }
            i += 1
        }

        boost := spikeBoost * spikeCount
        if (boost > maxBoost)
            boost := maxBoost

        return Map(
            "spiked", spiked,
            "spikeCount", spikeCount,
            "spikeIndices", spikeIdx,
            "boost", boost,
            "potentials", this._p.Clone(),
            "spikesTotal", this._spikesTotal
        )
    }

    GetState() {
        return Map(
            "count", this._count,
            "potentials", this._p.Clone(),
            "spikesTotal", this._spikesTotal
        )
    }

    ; ---------- internals ----------
    static _DefaultCfg() {
        return Map(
            "Count", 8,
            "Decay", 0.995,
            "LearningRate", 0.05,
            "Threshold", 0.5,
            "RefractoryMs", 12,
            "BaseDtMs", 4,
            "SpikeBoost", 0.20,
            "MaxBoost", 0.50
        )
    }

    static _MergeCfg(dst, src) {
        for k, v in src
            dst[k] := v
    }
}
