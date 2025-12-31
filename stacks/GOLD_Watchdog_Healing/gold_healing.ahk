#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\..\DemonWatchdog\src\DemonWatchdog.ahk
#Include ..\..\DemonLog\src\DemonLog.ahk

; --- Logging ---
logPath := A_Temp "\gold_healing.log"
DemonLog.Init({
    LogPath: logPath,
    Level: "DEBUG",
    AutoFlushMs: 1000,
    EnableRotation: true,
    MaxBytes: 256000
})
DemonLog.Log("INFO", "[stack] started, log=" logPath)
DemonLog.Flush()

; --- State ---
global gDegraded := false
global gOps := 0

global WORK_NORMAL_MS := 20
global WORK_DEGRADED_MS := 80

; --- Watchdog ---
; Enter degraded on first stall, exit when hiccups <= 0 again.
wd := DemonWatchdog(150, 60, 1, 0)
wd.OnStall := WD_OnStall
wd.OnDegradedChanged := WD_OnDegraded

OnExit((*) => ShutdownAll())

; Avoid false "startup stall" (MsgBox blocks timers).
MsgBox "GOLD_Watchdog_Healing ready.\nLog:\n" logPath "\n\nClose this MsgBox to begin."

; We'll adjust only the work timer interval in degraded mode.
SetTimer(DoWork, WORK_NORMAL_MS)
SetTimer(ShowStatus, 200)

; Trigger one intentional stall after 2 seconds.
SetTimer(TriggerStall, -2000)

wd.Start()
return

DoWork(*) {
    global gOps, gDegraded

    ; Simulated “work”: do less work in degraded mode.
    if gDegraded {
        Loop 200
            gOps += 1
    } else {
        Loop 2000
            gOps += 1
    }
}

ShowStatus(*) {
    global wd, gDegraded, gOps
    ToolTip "GOLD_Watchdog_Healing"
        . "`nDegraded: " (gDegraded ? "YES" : "NO")
        . "`nHiccups: " wd.hiccups
        . "`nLast delta: " Round(wd.lastDeltaMs, 1) " ms"
        . "`nOps: " gOps
}

TriggerStall(*) {
    global wd
    DemonLog.Log("WARN", "[stack] triggering intentional stall (~600ms)")
    DemonLog.Flush()

    ; Real stall: prevents timers and watchdog ticks.
    Critical "On"
    t0 := A_TickCount
    while ((A_TickCount - t0) < 600) {
    }
    Critical "Off"
    wd.Touch()
}

WD_OnStall(wd, deltaMs, thresholdMs) {
    ; Rate-limit to avoid log spam.
    DemonLog.SmartLog(
        "WARN",
        Format("[wd] stall dt={:.1f}ms threshold={:.1f} hiccups={}", deltaMs, thresholdMs, wd.hiccups),
        500,
        "stall"
    )
}

WD_OnDegraded(wd, isDegraded, reason := "") {
    global gDegraded, WORK_NORMAL_MS, WORK_DEGRADED_MS

    gDegraded := isDegraded

    if isDegraded {
        DemonLog.Log("WARN", "[wd] ENTER degraded (" reason ")")
        SetTimer(DoWork, WORK_DEGRADED_MS)
    } else {
        DemonLog.Log("INFO", "[wd] EXIT degraded (" reason ")")
        SetTimer(DoWork, WORK_NORMAL_MS)
    }
    DemonLog.Flush()
}

ShutdownAll() {
    global wd
    try wd.Stop()
    try SetTimer(DoWork, 0)
    try SetTimer(ShowStatus, 0)
    try DemonLog.Log("INFO", "[stack] shutdown")
    try DemonLog.Shutdown()
}
