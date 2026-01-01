#Requires AutoHotkey v2.0

class DemonHotkeys {
    __New(cfg := 0) {
        this._cfg := DemonHotkeys._DefaultCfg()
        if IsObject(cfg)
            DemonHotkeys._MergeCfg(this._cfg, cfg)

        ; Array of Maps: {key, cb, opts, handler, registered, active}
        this._items := []
        this._enabled := false
        this._fires := 0
        this._errors := 0

        this.OnHotkeyFired := 0
    }

    Add(keyName, callback, options := "") {
        if !(keyName is String) || (keyName = "")
            throw Error("keyName must be non-empty string")
        if !IsObject(callback)
            throw TypeError("callback must be a function object")

        item := Map(
            "key", keyName,
            "cb", callback,
            "opts", options "",
            "handler", 0,
            "registered", false,
            "active", true
        )
        this._items.Push(item)
        idx := this._items.Length

        ; If already enabled, register immediately.
        if this._enabled
            this._RegisterOne(idx)

        return idx
    }

    Enable() {
        if this._enabled
            return true
        this._enabled := true

        i := 1
        Loop this._items.Length {
            this._RegisterOne(i)
            i += 1
        }
        return true
    }

    Disable() {
        if !this._enabled
            return true

        i := 1
        Loop this._items.Length {
            item := this._items[i]
            if item["active"] {
                hk := item["key"]
                try {
                    Hotkey(hk, "Off")
                } catch {
                }
            }
            i += 1
        }

        this._enabled := false
        return true
    }

    ; Unregister a hotkey by index (removes binding if supported).
    Remove(index) {
        i := Integer(index)
        if (i < 1) || (i > this._items.Length)
            return false

        item := this._items[i]
        if !item["active"]
            return false

        hk := item["key"]

        ; Turn off first, then delete binding if available.
        try {
            Hotkey(hk, "Off")
        } catch {
        }
        try {
            Hotkey(hk, "Delete")
        } catch {
        }

        item["active"] := false
        item["registered"] := false
        item["handler"] := 0
        return true
    }

    Clear() {
        ; Best-effort unregister everything.
        i := 1
        Loop this._items.Length {
            this.Remove(i)
            i += 1
        }

        this._items := []
        this._enabled := false
    }

    GetState() {
        return Map(
            "enabled", this._enabled,
            "count", this._ActiveCount(),
            "fires", this._fires,
            "errors", this._errors
        )
    }

    ; ---------------- internals ----------------

    _ActiveCount() {
        c := 0
        i := 1
        Loop this._items.Length {
            if this._items[i]["active"]
                c += 1
            i += 1
        }
        return c
    }

    _RegisterOne(i) {
        item := this._items[i]
        if !item["active"]
            return

        hk := item["key"]
        cb := item["cb"]
        opts := item["opts"]

        if !IsObject(item["handler"])
            item["handler"] := this._MakeHandler(cb, hk)

        if item["registered"] {
            try {
                Hotkey(hk, "On")
            } catch as e {
                this._errors += 1
                if this._cfg["ThrowOnRegisterError"]
                    throw e
            }
            return
        }

        handler := item["handler"]
        try {
            if (opts != "")
                Hotkey(hk, handler, opts)
            else
                Hotkey(hk, handler, "On")
            item["registered"] := true
        } catch as e {
            this._errors += 1
            if this._cfg["ThrowOnRegisterError"]
                throw e
        }
    }

    _MakeHandler(cb, hk) {
        ; Returns a closure. No Func("Name").
        return (*) => this._Invoke(cb, hk)
    }

    _Invoke(cb, hk) {
        this._fires += 1
        onFired := this.OnHotkeyFired
        if IsObject(onFired) {
            try {
                onFired.Call(this, hk)
            } catch {
            }
        }

        try {
            cb.Call(hk)
        } catch {
            this._errors += 1
            if this._cfg["SwallowCallbackErrors"]
                return
            throw
        }
    }

    static _DefaultCfg() {
        return Map(
            "SwallowCallbackErrors", true,
            "ThrowOnRegisterError", false
        )
    }

    static _MergeCfg(dst, src) {
        for k, v in src
            dst[k] := v
    }
}
