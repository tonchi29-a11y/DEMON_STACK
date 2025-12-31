#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\src\DemonWatchdog.ahk
#Include ..\..\DemonLog\src\DemonLog.ahk

logPath := A_Temp "\watchdog_demo.log"
DemonLog.Init({ LogPath: logPath, Level: "INFO", AutoFlushMs: 1000 })

DemonLog.Log("INFO", "[demo_basic] starting, A_Temp=" A_Temp)
DemonLog.Flush()

WD_OnStall(wd, deltaMs, thresholdMs := "") {
    msg := Format("[demo_basic] Stall {1:.1f} ms (hiccups={2})", deltaMs, wd.hiccups)
    DemonLog.Log("WARN", msg)
}

WD_OnModeChange(wd, isDegraded, reason := "") {
    msg := "[demo_basic] Degraded mode = " (isDegraded ? "ON" : "OFF")
    if (reason != "")
        msg .= " (" reason ")"
    DemonLog.Log("INFO", msg)
}

wd := DemonWatchdog(200, 80, 2, 0)
wd.OnStall := WD_OnStall
wd.OnDegradedChanged := WD_OnModeChange
wd.Start()

MsgBox "Watchdog running.`nA_Temp: " A_Temp "`nLog: " logPath
Sleep 300

; Real stall: prevents timers from running for ~550ms
Critical "On"
t0 := A_TickCount
while (A_TickCount - t0) < 550 {
}
Critical "Off"

Sleep 200
wd.Stop()

DemonLog.Log("INFO", "[demo_basic] stopping")
DemonLog.Shutdown()

if FileExist(logPath)
    Run('explorer.exe /select,"' logPath '"')
else
    MsgBox "Log file NOT found:`n" logPath
