#Requires AutoHotkey v2.0
#Include ..\src\DemonLog.ahk

; Use a writable path regardless of where the repo sits:
logPath := A_Temp "\DemonLog_selftest.log"

DemonLog.Init({
    LogPath: logPath,
    Level: "DEBUG",
    BufferBytes: 512,
    FlushIntervalMs: 0,
    EnableRotation: true,
    MaxBytes: 1024,
    AutoFlushMs: 0
})

DemonLog.Log("INFO", "Self-test start")
DemonLog.Log("DEBUG", "Temp path: " A_Temp)

; Force rotation
Loop 200
    DemonLog.Log("INFO", "Line " A_Index)

DemonLog.Flush()
DemonLog.Shutdown()

if !FileExist(logPath)
    MsgBox "FAIL: log file not created:`n" logPath
else
    MsgBox "PASS:`n" logPath