#Requires AutoHotkey v2.0

class DemonReadyFlag {
    __New(name := "Local\DemonReadyFlag", mapBytes := 64) {
        if !(name is String) || (name = "")
            throw ValueError("name must be non-empty string")
        if !IsInteger(mapBytes) || (mapBytes < 4)
            throw ValueError("mapBytes must be >= 4")

        this._name := name
        this._mapBytes := Integer(mapBytes)
        this._hMap := 0
        this._pView := 0

        this._OpenOrCreate()
    }

    __Delete() {
        try {
            this.Close()
        } catch {
        }
    }

    Close() {
        if this._pView {
            DllCall("kernel32.dll\UnmapViewOfFile", "Ptr", this._pView)
            this._pView := 0
        }
        if this._hMap {
            DllCall("kernel32.dll\CloseHandle", "Ptr", this._hMap)
            this._hMap := 0
        }
    }

    ; Writes the ready flag (true => 1, false => 0).
    SetReady(isReady := true) {
        if !this._pView
            throw Error("DemonReadyFlag not initialized")

        DemonReadyFlag._InitInterlocked()

        v := isReady ? 1 : 0

        if (DemonReadyFlag._exchFn != "") {
            DllCall(DemonReadyFlag._exchFn, "Ptr", this._pView, "Int", v, "Int")
            return true
        }

        ; Fallback: plain store + heavy barrier (OK for low-frequency ready flag)
        NumPut("Int", v, this._pView, 0)
        DllCall("kernel32.dll\FlushProcessWriteBuffers")
        return true
    }

    ; Reads the ready flag (atomic).
    IsReady() {
        if !this._pView
            return false

        DemonReadyFlag._InitInterlocked()

        if (DemonReadyFlag._addFn != "") {
            v := DllCall(DemonReadyFlag._addFn, "Ptr", this._pView, "Int", 0, "Int")
            return (v != 0)
        }

        ; Fallback: heavy barrier then read
        DllCall("kernel32.dll\FlushProcessWriteBuffers")
        v := NumGet(this._pView, 0, "Int")
        return (v != 0)
    }

    GetState() {
        DemonReadyFlag._InitInterlocked()
        return Map(
            "name", this._name,
            "mapBytes", this._mapBytes,
            "exchangeFn", DemonReadyFlag._exchFn,
            "readFn", DemonReadyFlag._addFn
        )
    }

    static _inited := false
    static _exchFn := ""
    static _addFn := ""

    static _InitInterlocked() {
        if DemonReadyFlag._inited
            return
        DemonReadyFlag._inited := true

        ; Try exchange
        DemonReadyFlag._exchFn := DemonReadyFlag._PickFn([
            "kernel32.dll\InterlockedExchange",
            "KernelBase.dll\InterlockedExchange",
            "ntdll.dll\RtlInterlockedExchange"
        ])

        ; Try exchange-add (read barrier)
        DemonReadyFlag._addFn := DemonReadyFlag._PickFn([
            "kernel32.dll\InterlockedExchangeAdd",
            "KernelBase.dll\InterlockedExchangeAdd",
            "ntdll.dll\RtlInterlockedExchangeAdd"
        ])
    }

    static _PickFn(candidates) {
        dummy := Buffer(4, 0)
        for _, fn in candidates {
            try {
                DllCall(fn, "Ptr", dummy.Ptr, "Int", 0, "Int")
                return fn
            } catch {
            }
        }
        return ""
    }

    _OpenOrCreate() {
        PAGE_READWRITE := 0x04
        FILE_MAP_ALL_ACCESS := 0xF001F
        INVALID_HANDLE_VALUE := -1

        this._hMap := DllCall("kernel32.dll\CreateFileMappingW"
            , "Ptr", INVALID_HANDLE_VALUE
            , "Ptr", 0
            , "UInt", PAGE_READWRITE
            , "UInt", 0
            , "UInt", this._mapBytes
            , "WStr", this._name
            , "Ptr"
        )
        if !this._hMap {
            err := DllCall("kernel32.dll\GetLastError", "UInt")
            throw Error("CreateFileMappingW failed. LastError=" err)
        }

        this._pView := DllCall("kernel32.dll\MapViewOfFile"
            , "Ptr", this._hMap
            , "UInt", FILE_MAP_ALL_ACCESS
            , "UInt", 0
            , "UInt", 0
            , "UPtr", this._mapBytes
            , "Ptr"
        )
        if !this._pView {
            err2 := DllCall("kernel32.dll\GetLastError", "UInt")
            DllCall("kernel32.dll\CloseHandle", "Ptr", this._hMap)
            this._hMap := 0
            throw Error("MapViewOfFile failed. LastError=" err2)
        }
    }
}
