#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\src\DemonWatchdog.ahk

wd := DemonWatchdog(200, 80)
wd.Start()

Sleep 3000
wd.Stop()

msg := "Watchdog self-test complete." . "`nHiccups: " . wd.hiccups . "`nLast delta: " . Round(wd.lastDeltaMs, 2) . " ms" . "`nDegraded: " . (wd.IsDegraded() ? "YES" : "NO")
MsgBox msg
