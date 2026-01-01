#Requires AutoHotkey v2.0

class DemonHUD {
    static _instances := Map()
    static _wmNcHitTestMsg := 0x84
    static _ncHooked := false

    __New(cfg := 0) {
        this._cfg := DemonHUD._DefaultCfg()
        if IsObject(cfg)
            DemonHUD._MergeCfg(this._cfg, cfg)

        this._gui := 0
        this._txt := 0
        this._visible := false
        this._lastText := ""
        this._lastAlpha := -1

        this._timerActive := false
        this._provider := 0
        this._hbMs := 250
        this._hbFn := this._OnHeartbeat.Bind(this)

        this._CreateGui()
    }

    __Delete() {
        try {
            this.Close()
        } catch {
        }
    }

    Close() {
        this.Stop()
        this.Hide()

        if IsObject(this._gui) {
            hwnd := this._gui.Hwnd
            try {
                this._gui.Destroy()
            } catch {
            }
            this._gui := 0
            this._txt := 0

            ; Unregister from click-through map
            if DemonHUD._instances.Has(hwnd)
                DemonHUD._instances.Delete(hwnd)

            ; Unhook message if last instance
            if (DemonHUD._instances.Count = 0) && DemonHUD._ncHooked {
                OnMessage(DemonHUD._wmNcHitTestMsg, 0)
                DemonHUD._ncHooked := false
            }
        }
    }

    Show(x := "", y := "") {
        if !IsObject(this._gui)
            return false

        opts := "NoActivate"
        if (x != "") && (y != "")
            opts .= " x" x " y" y

        this._gui.Show(opts)
        this._visible := true
        this.SetOpacity(this._cfg["Alpha"])
        return true
    }

    Hide() {
        if IsObject(this._gui) {
            try {
                this._gui.Hide()
            } catch {
            }
        }
        this._visible := false
    }

    IsVisible() {
        return !!this._visible
    }

    SetText(text) {
        if !IsObject(this._txt)
            return false

        t := text ""
        if (t = this._lastText)
            return true

        this._txt.Value := t
        this._lastText := t
        return true
    }

    SetOpacity(alpha) {
        if !IsObject(this._gui)
            return false

        a := Round(alpha)
        if (a < 0)
            a := 0
        if (a > 255)
            a := 255

        if (a = this._lastAlpha)
            return true

        WinSetTransparent(a, "ahk_id " this._gui.Hwnd)
        this._lastAlpha := a
        return true
    }

    ; Optional: drive updates via a timer (provider must be fast and non-blocking).
    ; provider: function object called as provider(hud) -> string
    Start(provider, intervalMs := 250) {
        if !IsObject(provider)
            throw TypeError("provider must be a function object")

        this._provider := provider
        this._hbMs := Max(20, Round(intervalMs))
        this._timerActive := true

        SetTimer(this._hbFn, this._hbMs)
    }

    Stop() {
        if this._timerActive {
            SetTimer(this._hbFn, 0)
            this._timerActive := false
        }
        this._provider := 0
    }

    GetState() {
        return Map(
            "visible", this._visible,
            "alpha", this._lastAlpha,
            "heartbeatActive", this._timerActive,
            "heartbeatMs", this._hbMs
        )
    }

    ; ---------------- internals ----------------

    _CreateGui() {
        w := Round(this._cfg["Width"])
        h := Round(this._cfg["Height"])
        bg := this._cfg["BgColor"] ""
        fg := this._cfg["TextColor"] ""
        font := this._cfg["FontName"] ""
        fontSize := Round(this._cfg["FontSize"])
        margin := Round(this._cfg["Margin"])

        g := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale")
        g.BackColor := bg

        ; Use a read-only Edit as a simple multi-line text surface.
        g.SetFont("s" fontSize, font)
        txt := g.Add(
            "Edit",
            "x" margin " y" margin " w" (w - margin*2) " h" (h - margin*2)
            . " -VScroll -HScroll ReadOnly -TabStop",
            ""
        )
        ; Opaque background prevents ghosting.
        txt.Opt("Background" bg)
        txt.SetFont("c" fg)

        this._gui := g
        this._txt := txt

        ; Click-through via WM_NCHITTEST if enabled.
        if this._cfg["ClickThrough"] {
            hwnd := g.Hwnd
            DemonHUD._instances[hwnd] := this
            if !DemonHUD._ncHooked {
                OnMessage(DemonHUD._wmNcHitTestMsg, DemonHUD._OnNcHitTest)
                DemonHUD._ncHooked := true
            }
        }
    }

    _OnHeartbeat(*) {
        if !this._timerActive
            return
        if !IsObject(this._provider)
            return

        ; Provider must be fast. Swallow errors to avoid killing the host.
        try {
            t := this._provider.Call(this)
            this.SetText(t)
        } catch {
        }
    }

    static _OnNcHitTest(wParam, lParam, msg, hwnd) {
        ; Return HTTRANSPARENT (-1) for click-through.
        if DemonHUD._instances.Has(hwnd)
            return -1
    }

    static _DefaultCfg() {
        return Map(
            "Width", 340,
            "Height", 220,
            "Margin", 10,
            "Alpha", 220,
            "ClickThrough", true,
            "FontName", "Consolas",
            "FontSize", 10,
            "BgColor", "101010",
            "TextColor", "FFFFFF"
        )
    }

    static _MergeCfg(dst, src) {
        for k, v in src
            dst[k] := v
    }
}
