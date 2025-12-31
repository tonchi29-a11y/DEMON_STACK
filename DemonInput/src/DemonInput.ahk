#Requires AutoHotkey v2.0

class DemonInput {
    __New(onSample) {
        if !IsObject(onSample)
            throw Error("DemonInput requires a callback object (Func/BoundFunc/closure).")

        this._onSample := onSample

        ; Timer lane
        this._timerFn := ObjBindMethod(this, "_OnTimerTick")
        this._timerMs := 0
        this._timerRunning := false
        this._lastMouseX := ""
        this._lastMouseY := ""

        ; RawInput lane
        this._rawRunning := false
        this._rawHwnd := 0
        this._inputSink := false
        this._aggregate := true
        this._rawMsgFn := ObjBindMethod(this, "_OnWmInput")
        this._prevWmInput := 0

        this._rawAccDx := 0
        this._rawAccDy := 0
        this._rawAccTms := ""

        ; Counters / last sample
        this._samplesTimer := 0
        this._samplesRaw := 0
        this._samplesTotal := 0
        this._lastDx := 0
        this._lastDy := 0
        this._lastTms := 0
        this._lastSource := ""

        ; Shared raw buffer (static-style) - allocated lazily
        this._rawBuf := 0
        this._rawBufSize := 0
    }

    StartTimerLane(sampleMs := 4) {
        ms := Max(1, Integer(sampleMs))
        this._timerMs := ms

        if !this._timerRunning {
            this._timerRunning := true
            this._lastMouseX := ""
            this._lastMouseY := ""
            SetTimer(this._timerFn, ms)
        } else {
            SetTimer(this._timerFn, ms)
        }
    }

    StartRawInputLane(hwnd := A_ScriptHwnd, inputSink := false, aggregatePerTick := true) {
        if !hwnd
            throw Error("DemonInput RawInput lane requires a valid hwnd.")

        this._inputSink := !!inputSink
        this._aggregate := !!aggregatePerTick
        this._rawHwnd := hwnd

        if this._rawRunning
            return

        this._RegisterRawMouse(hwnd, this._inputSink)
        this._prevWmInput := OnMessage(0x00FF, this._rawMsgFn)

        this._rawRunning := true
        this._rawAccDx := 0
        this._rawAccDy := 0
        this._rawAccTms := ""
    }

    Stop() {
        if this._timerRunning {
            SetTimer(this._timerFn, 0)
            this._timerRunning := false
        }

        if this._rawRunning {
            try OnMessage(0x00FF, this._prevWmInput)
            this._prevWmInput := 0
            try this._UnregisterRawMouse()
            this._rawRunning := false

            ; Flush any pending aggregate sample
            if (this._aggregate && this._rawAccTms != "" && (this._rawAccDx != 0 || this._rawAccDy != 0)) {
                this._Emit(this._rawAccDx, this._rawAccDy, this._rawAccTms, "raw")
                this._rawAccDx := 0
                this._rawAccDy := 0
                this._rawAccTms := ""
            }
        }
    }

    GetState() {
        lane := "stopped"
        if (this._timerRunning && this._rawRunning)
            lane := "timer+raw"
        else if (this._timerRunning)
            lane := "timer"
        else if (this._rawRunning)
            lane := "raw"

        return Map(
            "lane", lane,
            "timerRunning", this._timerRunning,
            "rawRunning", this._rawRunning,
            "samplesTimer", this._samplesTimer,
            "samplesRaw", this._samplesRaw,
            "samplesTotal", this._samplesTotal,
            "lastDx", this._lastDx,
            "lastDy", this._lastDy,
            "lastTms", this._lastTms,
            "lastSource", this._lastSource
        )
    }

    _OnTimerTick(*) {
        MouseGetPos &x, &y

        if (this._lastMouseX = "") {
            this._lastMouseX := x
            this._lastMouseY := y
        }

        dx := x - this._lastMouseX
        dy := y - this._lastMouseY
        this._lastMouseX := x
        this._lastMouseY := y

        tMs := A_TickCount
        this._Emit(dx, dy, tMs, "timer")
    }

    _OnWmInput(wParam, lParam, msg, hwnd) {
        ; WM_INPUT handler: keep this short.
        ; Parse RAWINPUT mouse deltas and emit aggregated/per-event samples.

        if !this._rawRunning
            return 0

        if !lParam
            return 0

        dx := 0
        dy := 0
        if !this._ReadRawMouse(lParam, &dx, &dy)
            return 0

        ; Ignore zero deltas to reduce noise
        if (dx = 0 && dy = 0)
            return 0

        tMs := A_TickCount

        if !this._aggregate {
            this._Emit(dx, dy, tMs, "raw")
            return 0
        }

        if (this._rawAccTms = "") {
            this._rawAccTms := tMs
            this._rawAccDx := dx
            this._rawAccDy := dy
            return 0
        }

        if (tMs = this._rawAccTms) {
            this._rawAccDx += dx
            this._rawAccDy += dy
            return 0
        }

        ; Tick changed: flush previous tick aggregate, start new tick aggregate
        if (this._rawAccDx != 0 || this._rawAccDy != 0)
            this._Emit(this._rawAccDx, this._rawAccDy, this._rawAccTms, "raw")

        this._rawAccTms := tMs
        this._rawAccDx := dx
        this._rawAccDy := dy
        return 0
    }

    _Emit(dx, dy, tMs, source) {
        this._lastDx := dx
        this._lastDy := dy
        this._lastTms := tMs
        this._lastSource := source

        if (source = "timer")
            this._samplesTimer += 1
        else if (source = "raw")
            this._samplesRaw += 1

        this._samplesTotal += 1

        cb := this._onSample
        try cb.Call(dx, dy, tMs, source)
        catch {
            ; do not crash host due to callback
        }
    }

    _RegisterRawMouse(hwnd, inputSink) {
        ; RAWINPUTDEVICE
        ; usUsagePage=0x01 (Generic Desktop)
        ; usUsage=0x02 (Mouse)
        ; dwFlags=0 or RIDEV_INPUTSINK
        ; hwndTarget is only used when RIDEV_INPUTSINK is set
        
        rid := Buffer(8 + A_PtrSize, 0)
        NumPut("UShort", 0x01, rid, 0)
        NumPut("UShort", 0x02, rid, 2)

        flags := inputSink ? 0x00000100 : 0 ; RIDEV_INPUTSINK
        NumPut("UInt", flags, rid, 4)
        NumPut("Ptr", inputSink ? hwnd : 0, rid, 8)

        ok := DllCall("user32.dll\RegisterRawInputDevices", "Ptr", rid.Ptr, "UInt", 1, "UInt", rid.Size, "UInt")
        if !ok
            throw Error("RegisterRawInputDevices failed.")
    }

    _UnregisterRawMouse() {
        rid := Buffer(8 + A_PtrSize, 0)
        NumPut("UShort", 0x01, rid, 0)
        NumPut("UShort", 0x02, rid, 2)
        NumPut("UInt", 0x00000001, rid, 4) ; RIDEV_REMOVE
        NumPut("Ptr", 0, rid, 8)

        DllCall("user32.dll\RegisterRawInputDevices", "Ptr", rid.Ptr, "UInt", 1, "UInt", rid.Size, "UInt")
    }

    _ReadRawMouse(hRawInput, &dx, &dy) {
        static RID_INPUT := 0x10000003

        size := 0
        res := DllCall("user32.dll\GetRawInputData", "Ptr", hRawInput, "UInt", RID_INPUT, "Ptr", 0, "UIntP", &size, "UInt", 8 + (2 * A_PtrSize), "UInt")
        if (size <= 0)
            return false

        if (!this._rawBuf || size > this._rawBufSize) {
            this._rawBufSize := size
            this._rawBuf := Buffer(size, 0)
        }

        read := size
        res2 := DllCall("user32.dll\GetRawInputData", "Ptr", hRawInput, "UInt", RID_INPUT, "Ptr", this._rawBuf.Ptr, "UIntP", &read, "UInt", 8 + (2 * A_PtrSize), "UInt")
        if (res2 = 0xFFFFFFFF)
            return false

        headerSize := 8 + (2 * A_PtrSize)
        type := NumGet(this._rawBuf, 0, "UInt")
        if (type != 0) {
            ; Not a mouse.
            return false
        }

        ; RAWMOUSE offsets within the union
        ; usFlags at +0 (UShort)
        ; lLastX at +12 (Int)
        ; lLastY at +16 (Int)
        flags := NumGet(this._rawBuf, headerSize + 0, "UShort")
        if (flags & 0x01) {
            ; MOUSE_MOVE_ABSOLUTE - ignore
            return false
        }

        dx := NumGet(this._rawBuf, headerSize + 12, "Int")
        dy := NumGet(this._rawBuf, headerSize + 16, "Int")
        return true
    }

    __Delete() {
        try this.Stop()
    }
}
