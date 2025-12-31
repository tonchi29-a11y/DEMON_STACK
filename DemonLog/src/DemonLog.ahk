#Requires AutoHotkey v2.0

class DemonLog {
    static _initialized := false
    static _level := 3
    static _logPath := ""
    static _buffer := ""
    static _bufferLimit := 8192
    static _flushInterval := 5000
    static _lastFlush := 0
    static _rotateEnabled := true
    static _maxBytes := 524288
    static _smartCache := Map()
    static _timerRef := 0
    static _autoFlushMs := 0
    static _encoding := "UTF-8"
    static _levelMap := Map("ERROR", 1, "WARN", 2, "INFO", 3, "DEBUG", 4, "TRACE", 5)

    static Init(config := 0) {
        if !IsObject(config)
            config := {}
        this._logPath := this.__Cfg(config, "LogPath", this.__DefaultLogPath())
        this._level := this.__ResolveLevel(this.__Cfg(config, "Level", this._level))
        this._bufferLimit := Max(256, this.__Cfg(config, "BufferBytes", this._bufferLimit))
        this._flushInterval := Max(0, this.__Cfg(config, "FlushIntervalMs", this._flushInterval))
        this._rotateEnabled := !!this.__Cfg(config, "EnableRotation", this._rotateEnabled)
        this._maxBytes := Max(0, this.__Cfg(config, "MaxBytes", this._maxBytes))
        this._encoding := this.__Cfg(config, "Encoding", this._encoding)
        this._smartCache := Map()
        this._buffer := ""
        this._lastFlush := A_TickCount
        this._initialized := true
        this.StartAutoFlush(this.__Cfg(config, "AutoFlushMs", this._autoFlushMs))
    }

    static SetLevel(level) => this._level := this.__ResolveLevel(level)
    static GetLevel() => this._level

    static Log(level, msg) {
        if !this._initialized
            this.Init()
        msg := this.__ToString(msg)
        lvlRank := this.__ResolveLevel(level)
        if (lvlRank > this._level)
            return false
        line := this.__FormatLine(level, msg)
        this._buffer .= line
        this.__MaybeFlush()
        return true
    }

    static SmartLog(level, msg, minIntervalMs := 0, key := "") {
        if !this._initialized
            this.Init()
        msg := this.__ToString(msg)
        key := key ? key : StrUpper(level) ":" msg
        if (minIntervalMs > 0) && this._smartCache.Has(key) {
            if ((A_TickCount - this._smartCache[key]) < minIntervalMs)
                return false
        }
        this._smartCache[key] := A_TickCount
        return this.Log(level, msg)
    }

    static Flush(*) {
        if !this._initialized
            return
        if (this._buffer = "") {
            this._lastFlush := A_TickCount
            return
        }
        path := this._logPath
        this.__EnsureDirectory(path)
        this.__RotateIfNeeded(path)
        chunk := this._buffer
        this._buffer := ""
        try FileAppend(chunk, path, this._encoding)
        catch {
        }
        this._lastFlush := A_TickCount
    }

    static SafeLog(line) {
        if !this._initialized
            this.Init()
        path := this._logPath
        this.__EnsureDirectory(path)
        Loop 12 {
            try {
                FileAppend(line "`n", path, this._encoding)
                return true
            } catch {
                Sleep 25
            }
        }
        return false
    }

    static StartAutoFlush(intervalMs) {
        this.StopAutoFlush()
        intervalMs := Max(0, intervalMs)
        if (intervalMs < 250)
            return
        this._autoFlushMs := intervalMs
        this._timerRef := ObjBindMethod(this, "__AutoFlush")
        SetTimer(this._timerRef, intervalMs)
    }

    static StopAutoFlush() {
        if (this._timerRef) {
            SetTimer(this._timerRef, 0)
            this._timerRef := 0
        }
        this._autoFlushMs := 0
    }

    static Shutdown(*) {
        this.StopAutoFlush()
        this.Flush()
        this._initialized := false
    }

    static __AutoFlush() => this.Flush()

    static __MaybeFlush() {
        needFlush := (StrLen(this._buffer) * 2) >= this._bufferLimit
        if (!needFlush && this._flushInterval > 0)
            needFlush := (A_TickCount - this._lastFlush) >= this._flushInterval
        if (needFlush)
            this.Flush()
    }

    static __FormatLine(level, msg) {
        stamp := this.__Timestamp()
        return stamp " " StrUpper(level) " " msg "`n"
    }

    static __EnsureDirectory(path) {
        SplitPath(path, , &dir)
        if (dir && !DirExist(dir))
            DirCreate(dir)
    }

    static __RotateIfNeeded(path) {
        if (!this._rotateEnabled || this._maxBytes <= 0)
            return
        if !FileExist(path)
            return
        try {
            size := FileGetSize(path)
        } catch {
            return
        }
        if (size < this._maxBytes)
            return
        backup := path ".bak"
        try {
            FileDelete(backup)
        } catch {
        }
        try {
            FileMove(path, backup, 1)
        } catch {
            try {
                FileDelete(path)
            } catch {
            }
        }
        rotateMsg := this.__Timestamp() " LOG ROTATED (previous copy: " backup ")`n"
        try {
            FileAppend(rotateMsg, path, this._encoding)
        } catch {
        }
    }

    static __Timestamp() {
        base := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        return base "." Format("{:03}", A_MSec)
    }

    static __ResolveLevel(value) {
        if IsNumber(value)
            return Max(1, Min(5, Floor(value)))
        if !value
            return 3
        key := StrUpper(Trim(value))
        return this._levelMap.Has(key) ? this._levelMap[key] : 3
    }

    static __Cfg(config, key, default) {
        if (config is Map)
            return config.Has(key) ? config[key] : default
        if IsObject(config) {
            try {
                return config.HasOwnProp(key) ? config.%key% : default
            } catch {
                return default
            }
        }
        return default
    }

    static __DefaultLogPath() => A_ScriptDir "\DemonLog.log"

    static __ToString(val) {
        try {
            return val . ""
        } catch {
            return "(unprintable message)"
        }
    }
}
