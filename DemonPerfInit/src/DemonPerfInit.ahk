#Requires AutoHotkey v2.0

class DemonPerfInit {
    static Presets := Map(
        "SAFE",  Map(
            "ProcessPriority", "AboveNormal",
            "ThreadPriority",  1,
            "HotkeyInterval",  2000,
            "MaxHotkeysPerInterval", 9999,
            "SetDelays", true
        ),
        "MATCH", Map(
            "ProcessPriority", "High",
            "ThreadPriority",  2,
            "HotkeyInterval",  99999999,
            "MaxHotkeysPerInterval", 99999999,
            "SetDelays", true
        ),
        "ULTRA", Map(
            "ProcessPriority", "High",
            "ThreadPriority",  2,
            "HotkeyInterval",  99999999,
            "MaxHotkeysPerInterval", 99999999,
            "SetDelays", true
        )
    )

    static ApplyPreset(name := "MATCH") {
        nameU := StrUpper(name)
        if !DemonPerfInit.Presets.Has(nameU)
            throw Error("Unknown preset: " name)

        cfg := DemonPerfInit.Presets[nameU]
        token := Map(
            "preset", nameU,
            "old", Map(),
            "applied", Map()
        )

        token["old"]["HotkeyInterval"] := A_HotkeyInterval
        token["old"]["MaxHotkeysPerInterval"] := A_MaxHotkeysPerInterval
        token["old"]["ThreadPriority"] := DemonPerfInit._GetCurrentThreadPriority()
        token["old"]["ProcessPriority"] := DemonPerfInit._TryGetProcessPriority()

        if cfg["SetDelays"] {
            DemonPerfInit._ApplyDelayTuning()
            token["applied"]["SetDelays"] := true
        }

        A_HotkeyInterval := cfg["HotkeyInterval"]
        A_MaxHotkeysPerInterval := cfg["MaxHotkeysPerInterval"]
        token["applied"]["HotkeyInterval"] := true
        token["applied"]["MaxHotkeysPerInterval"] := true

        okProc := false
        try {
            hProc := DllCall("kernel32.dll\GetCurrentProcess", "Ptr")
            cls := DemonPerfInit._PriorityNameToClass(cfg["ProcessPriority"])
            okProc := !!DllCall("kernel32.dll\SetPriorityClass", "Ptr", hProc, "UInt", cls, "Int")
        } catch {
            okProc := false
        }
        token["applied"]["ProcessPriority"] := okProc

        okThr := false
        try {
            okThr := DemonPerfInit._SetCurrentThreadPriority(cfg["ThreadPriority"])
        } catch {
            okThr := false
        }
        token["applied"]["ThreadPriority"] := okThr

        return token
    }

    static Restore(token) {
        if !(token is Map)
            throw TypeError("Restore expects the token Map returned by ApplyPreset")

        old := token.Has("old") ? token["old"] : Map()

        if old.Has("HotkeyInterval")
            A_HotkeyInterval := old["HotkeyInterval"]
        if old.Has("MaxHotkeysPerInterval")
            A_MaxHotkeysPerInterval := old["MaxHotkeysPerInterval"]

        if old.Has("ProcessPriority") && old["ProcessPriority"] {
            try {
                hProc := DllCall("kernel32.dll\GetCurrentProcess", "Ptr")
                DllCall("kernel32.dll\SetPriorityClass", "Ptr", hProc, "UInt", old["ProcessPriority"], "Int")
            }
        }

        if old.Has("ThreadPriority") && old["ThreadPriority"] != "" {
            try DemonPerfInit._SetCurrentThreadPriority(old["ThreadPriority"])
        }

        return true
    }

    static _ApplyDelayTuning() {
        try SetKeyDelay(-1)
        try SetMouseDelay(-1)
        try SetWinDelay(-1)
        try SetControlDelay(-1)
        try SetDefaultMouseSpeed(0)
    }

    static _GetCurrentThreadPriority() {
        hThread := DllCall("kernel32.dll\GetCurrentThread", "Ptr")
        pri := DllCall("kernel32.dll\GetThreadPriority", "Ptr", hThread, "Int")
        return pri
    }

    static _SetCurrentThreadPriority(pri) {
        hThread := DllCall("kernel32.dll\GetCurrentThread", "Ptr")
        ok := DllCall("kernel32.dll\SetThreadPriority", "Ptr", hThread, "Int", Integer(pri), "Int")
        return !!ok
    }

    static _TryGetProcessPriority() {
        try {
            hProc := DllCall("kernel32.dll\GetCurrentProcess", "Ptr")
            cls := DllCall("kernel32.dll\GetPriorityClass", "Ptr", hProc, "UInt")
            return cls
        } catch {
            return 0
        }
    }

    static _PriorityNameToClass(name) {
        n := StrUpper(name)
        switch n {
            case "IDLE": return 0x40
            case "BELOWNORMAL": return 0x4000
            case "NORMAL": return 0x20
            case "ABOVENORMAL": return 0x8000
            case "HIGH": return 0x80
            case "REALTIME": return 0x100
            default: return 0x20
        }
    }
}
