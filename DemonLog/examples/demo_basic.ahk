#Requires AutoHotkey v2.0
#Include ..\src\DemonLog.ahk

logPath := A_ScriptDir "\demo_basic.log"
DemonLog.Init({
    LogPath: logPath,
    Level: "INFO",
    BufferBytes: 2048,
    FlushIntervalMs: 2000,
    AutoFlushMs: 1000
})

DemonLog.Log("INFO", "DemonLog basic demo started")
DemonLog.Log("DEBUG", "This line is filtered because level=INFO")
DemonLog.SetLevel("DEBUG")
DemonLog.Log("DEBUG", "Debug logging enabled")
Sleep 500
DemonLog.Log("WARN", "Demonstrating buffered writes")
Sleep 1500
DemonLog.Flush()

MsgBox "Basic demo complete.`nLog written to:" "`n" logPath
