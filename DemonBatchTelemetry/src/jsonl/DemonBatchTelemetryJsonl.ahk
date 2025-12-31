#Requires AutoHotkey v2.0

class DemonBatchTelemetryJsonl {
    __New(filePath, capacity := 4096, flushEvery := 256) {
        if !filePath
            throw Error("DemonBatchTelemetryJsonl: filePath required")

        this.filePath := filePath
        this.capacity := Max(64, Integer(capacity))
        this.flushEvery := Max(1, Integer(flushEvery))

        this._count := 0
        this._drops := 0
        this._idx := 1

        this._t := [], this._dx := [], this._dy := [], this._src := []
        this._t.Length := this.capacity
        this._dx.Length := this.capacity
        this._dy.Length := this.capacity
        this._src.Length := this.capacity

        this._timerFn := 0
    }

    Add(tMs, dx, dy, source := "") {
        i := this._idx
        this._t[i] := Integer(tMs)
        this._dx[i] := dx + 0.0
        this._dy[i] := dy + 0.0
        this._src[i] := source

        if (this._count < this.capacity)
            this._count += 1
        else
            this._drops += 1

        i += 1
        if (i > this.capacity)
            i := 1
        this._idx := i

        if (Mod(this._count + this._drops, this.flushEvery) = 0)
            this.Flush()

        return true
    }

    Flush() {
        if (this._count <= 0)
            return false

        SplitPath(this.filePath, , &dir)
        if (dir != "" && !DirExist(dir))
            DirCreate(dir)

        n := this._count
        start := (this._idx - n)
        if (start <= 0)
            start += this.capacity

        text := ""
        Loop n {
            j := start + (A_Index - 1)
            if (j > this.capacity)
                j -= this.capacity

            t := this._t[j]
            dx := this._dx[j]
            dy := this._dy[j]
            src := DemonBatchTelemetryJsonl._JsonEscape(this._src[j])

            text .= Format('{{""tMs"":{1},""dx"":{2},""dy"":{3},""src"":""{4}""}}', t, dx, dy, src) . "`r`n"
        }

        this._count := 0

        try {
            FileAppend(text, this.filePath, "UTF-8")
            return true
        } catch {
            return false
        }
    }

    StartAutoFlush(intervalMs := 1000) {
        this.StopAutoFlush()
        intervalMs := Max(100, Integer(intervalMs))
        this._timerFn := ObjBindMethod(this, "_AutoFlushTick")
        SetTimer(this._timerFn, intervalMs)
    }

    StopAutoFlush() {
        if this._timerFn {
            try {
                SetTimer(this._timerFn, 0)
            } catch {
            }
            this._timerFn := 0
        }
    }

    GetState() {
        return Map(
            "filePath", this.filePath,
            "capacity", this.capacity,
            "count", this._count,
            "drops", this._drops,
            "flushEvery", this.flushEvery
        )
    }

    _AutoFlushTick(*) {
        this.Flush()
    }

    static _JsonEscape(s) {
        ; Minimal JSON string escaping for \, " and newlines.
        s := s ""
        s := StrReplace(s, "\", "\\")
        s := StrReplace(s, Chr(34), "\" Chr(34))
        s := StrReplace(s, "`r", "\r")
        s := StrReplace(s, "`n", "\n")
        return s
    }

    __Delete() {
        try {
            this.StopAutoFlush()
        } catch {
        }
        try {
            this.Flush()
        } catch {
        }
    }
}
