#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\src\DemonWatchdog.ahk

; degradedAfter=1, recoverBelow=-1 => once degraded, it stays degraded for the demo
wd := DemonWatchdog(150, 60, 1, -1)

; Collect evidence without blocking in callbacks
global gStallCount := 0
global gFirstStallMs := 0.0
global gFirstThresholdMs := 0.0
global gDegradedEntered := false
global gDegradedReason := ""

wd.OnStall := WD_OnStall
wd.OnDegradedChanged := WD_OnDegraded
wd.Start()

; Give the watchdog one normal tick
Sleep 200

; Real stall: block timers for ~600ms
Critical "On"
t0 := A_TickCount
while (A_TickCount - t0) < 600 {
}
Critical "Off"

; Allow one more tick after stall
Sleep 200
wd.Stop()

summary := "DemonWatchdog stall demo (non-blocking callbacks)"
    . "`nStalls detected: " gStallCount
    . "`nFirst stall: " Round(gFirstStallMs, 1) " ms"
    . "`nThreshold: " Round(gFirstThresholdMs, 1) " ms"
    . "`nDegraded entered: " (gDegradedEntered ? "YES" : "NO")
    . (gDegradedReason ? "`nReason: " gDegradedReason : "")
    . "`nFinal hiccups: " wd.hiccups
    . "`nLast delta: " Round(wd.lastDeltaMs, 1) " ms"

MsgBox summary
ExitApp

WD_OnStall(wd, deltaMs, thresholdMs) {
    global gStallCount, gFirstStallMs, gFirstThresholdMs
    gStallCount += 1
    if (gStallCount = 1) {
        gFirstStallMs := deltaMs
        gFirstThresholdMs := thresholdMs
    }
}

WD_OnDegraded(wd, isDegraded, reason := "") {
    global gDegradedEntered, gDegradedReason
    if isDegraded {
        gDegradedEntered := true
        gDegradedReason := reason
    }
}
