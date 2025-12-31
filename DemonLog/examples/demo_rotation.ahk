#Requires AutoHotkey v2.0
#Include ..\src\DemonLog.ahk

logPath := A_ScriptDir "\demo_rotation.log"
DemonLog.Init({
    LogPath: logPath,
    Level: "INFO",
    BufferBytes: 512,
    FlushIntervalMs: 500,
    EnableRotation: true,
    MaxBytes: 1024
})

loopCount := 60
Loop loopCount {
    DemonLog.Log("INFO", "Rotation demo entry " . A_Index)
    Sleep 50
}

DemonLog.Flush()
MsgBox "Rotation demo logged " loopCount " entries.`nNew file:" "`n" logPath "`nPrevious copy (if rotation happened):" "`n" logPath ".bak"
