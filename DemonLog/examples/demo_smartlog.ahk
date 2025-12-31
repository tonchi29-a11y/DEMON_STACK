#Requires AutoHotkey v2.0
#Include ..\src\DemonLog.ahk

logPath := A_ScriptDir "\demo_smartlog.log"
DemonLog.Init({
    LogPath: logPath,
    Level: "DEBUG",
    BufferBytes: 1024,
    FlushIntervalMs: 1000
})

Loop 8 {
    DemonLog.SmartLog("WARN", "Repeated warning", 1500)
    Sleep 250
}

DemonLog.Log("INFO", "Only a few WARN entries should appear despite the loop")
DemonLog.Flush()

MsgBox "SmartLog demo finished. Check:" "`n" logPath
