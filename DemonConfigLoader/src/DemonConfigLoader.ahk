#Requires AutoHotkey v2.0

class DemonConfigLoader {
    __New(filePath, format := "auto", jsonParseFn := 0) {
        if !filePath
            throw Error("DemonConfigLoader: filePath is required")

        this.filePath := filePath
        this.format := StrLower(format)
        this._jsonParseFn := jsonParseFn

        if (this.format = "auto") {
            ext := StrLower(RegExReplace(filePath, ".*\.", ""))
            this.format := (ext = "json") ? "json" : "ini"
        }

        this._watchTimerFn := 0
        this._watchIntervalMs := 0
        this._lastWriteStamp := ""
        this._onChange := 0
    }

    ; ---------- Basic file helpers ----------

    Exists() => FileExist(this.filePath) ? true : false

    GetLastWriteStamp() {
        ; Returns a sortable timestamp string (YYYYMMDDHH24MISS) or "" if missing.
        if !FileExist(this.filePath)
            return ""
        try {
            return FileGetTime(this.filePath, "M")
        } catch {
            return ""
        }
    }

    ReadText() {
        try {
            return FileRead(this.filePath, "UTF-8")
        } catch as e {
            throw Error("DemonConfigLoader: FileRead failed: " this.filePath "`n" e.Message)
        }
    }

    ; ---------- INI (direct reads/writes) ----------

    IniGet(section, key, default := "") {
        try {
            return IniRead(this.filePath, section, key, default)
        } catch {
            return default
        }
    }

    IniSet(section, key, value) {
        try {
            IniWrite(value, this.filePath, section, key)
            return true
        } catch {
            return false
        }
    }

    ; Typed getters for INI values (read-through, no caching).
    GetStr(section, key, default := "") {
        v := this.IniGet(section, key, default)
        return v
    }

    GetInt(section, key, default := 0, minVal := "", maxVal := "") {
        s := this.IniGet(section, key, "")
        v := DemonConfigLoader._ParseInt(s, default)
        if (minVal != "")
            v := Max(Integer(minVal), v)
        if (maxVal != "")
            v := Min(Integer(maxVal), v)
        return v
    }

    GetFloat(section, key, default := 0.0, minVal := "", maxVal := "") {
        s := this.IniGet(section, key, "")
        v := DemonConfigLoader._ParseFloat(s, default)
        if (minVal != "")
            v := Max(minVal + 0.0, v)
        if (maxVal != "")
            v := Min(maxVal + 0.0, v)
        return v
    }

    GetBool(section, key, default := false) {
        s := this.IniGet(section, key, "")
        return DemonConfigLoader._ParseBool(s, default)
    }

    ; Loads the whole INI into Map(section -> Map(key -> value)).
    ; Only supports typical "key=value" lines (comments and blank lines ignored).
    LoadIniAll() {
        if !FileExist(this.filePath)
            return Map()

        text := this.ReadText()
        lines := StrSplit(text, "`n", "`r")
        cfg := Map()
        curSection := ""

        for _, line in lines {
            line := Trim(line)
            if (line = "")
                continue
            if (SubStr(line, 1, 1) = ";") || (SubStr(line, 1, 1) = "#")
                continue

            if RegExMatch(line, "^\[(.*)\]$", &m) {
                curSection := Trim(m[1])
                if !cfg.Has(curSection)
                    cfg[curSection] := Map()
                continue
            }

            ; key=value
            eqPos := InStr(line, "=")
            if (eqPos <= 0)
                continue

            k := Trim(SubStr(line, 1, eqPos - 1))
            v := Trim(SubStr(line, eqPos + 1))
            if (k = "")
                continue

            if (curSection = "")
                curSection := "DEFAULT"

            if !cfg.Has(curSection)
                cfg[curSection] := Map()

            cfg[curSection][k] := v
        }

        return cfg
    }

    ; ---------- JSON (optional via injected parser) ----------

    LoadJson() {
        if !FileExist(this.filePath)
            return Map()
        if !IsObject(this._jsonParseFn)
            throw Error("DemonConfigLoader: JSON parsing requires jsonParseFn (Func/closure)")

        text := this.ReadText()
        ; jsonParseFn should return an object (Map/Object).
        return this._jsonParseFn.Call(text)
    }

    ; ---------- Unified load (based on format) ----------

    Load() {
        if (this.format = "ini")
            return this.LoadIniAll()
        if (this.format = "json")
            return this.LoadJson()
        throw Error("DemonConfigLoader: unknown format: " this.format)
    }

    ; ---------- Hot reload (poll-based) ----------

    Watch(onChange, intervalMs := 500) {
        if !IsObject(onChange)
            throw Error("DemonConfigLoader.Watch: onChange must be a callback object (Func/closure)")

        this.Unwatch()

        intervalMs := Max(100, Integer(intervalMs))
        this._watchIntervalMs := intervalMs
        this._lastWriteStamp := this.GetLastWriteStamp()
        this._onChange := onChange

        this._watchTimerFn := ObjBindMethod(this, "_WatchTick")
        SetTimer(this._watchTimerFn, intervalMs)
        return true
    }

    Unwatch() {
        if this._watchTimerFn {
            try {
                SetTimer(this._watchTimerFn, 0)
            } catch {
            }
            this._watchTimerFn := 0
        }
        this._watchIntervalMs := 0
        this._onChange := 0
        return true
    }

    _WatchTick(*) {
        stamp := this.GetLastWriteStamp()
        if (stamp = "")
            return

        if (this._lastWriteStamp = "") {
            this._lastWriteStamp := stamp
            return
        }

        if (stamp = this._lastWriteStamp)
            return

        this._lastWriteStamp := stamp

        cfg := 0
        ok := true
        errMsg := ""

        try {
            cfg := this.Load()
        } catch as e {
            ok := false
            errMsg := e.Message
        }

        cb := this._onChange
        if IsObject(cb) {
            ; onChange(loader, ok, cfgOr0, errMsg)
            try {
                cb.Call(this, ok, cfg, errMsg)
            } catch {
                ; never crash the timer due to callback
            }
        }
    }

    ; ---------- parsing helpers ----------

    static _ParseInt(s, default := 0) {
        try {
            if (s = "")
                return Integer(default)
            return Integer(Trim(s))
        } catch {
            return Integer(default)
        }
    }

    static _ParseFloat(s, default := 0.0) {
        try {
            if (s = "")
                return default + 0.0
            return (Trim(s) + 0.0)
        } catch {
            return default + 0.0
        }
    }

    static _ParseBool(s, default := false) {
        v := StrLower(Trim(s))
        if (v = "")
            return !!default
        if (v = "1" || v = "true" || v = "yes" || v = "on")
            return true
        if (v = "0" || v = "false" || v = "no" || v = "off")
            return false
        return !!default
    }

    __Delete() {
        try {
            this.Unwatch()
        } catch {
        }
    }
}
