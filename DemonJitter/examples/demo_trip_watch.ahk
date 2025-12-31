#Requires AutoHotkey v2.0
#Include ..\src\DemonJitter.ahk

j := DemonJitter(64)

; Simulate mostly-good samples, then spikes
Loop 40
    j.Add(0.2)

Loop 10
    j.Add(2.5)

w1 := j.WatchP95(0.6, 2, 0)
w2 := j.WatchP95(0.6, 2, 0)

MsgBox "WatchP95"
    . "`np95=" Round(w2["p95"], 3)
    . "`ntrips=" w2["trips"]
    . "`ntriggered=" (w2["triggered"] ? "YES" : "NO")
