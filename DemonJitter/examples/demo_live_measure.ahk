#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\src\DemonJitter.ahk

j := DemonJitter(256)

Loop 200 {
    t0 := DemonTime.NowQpc()
    Sleep 10
    ms := DemonTime.MsSince(t0)
    j.Add(ms)
}

st := j.GetStats()
MsgBox "Live measure (Sleep 10)"
    . "`ncount=" st["count"]
    . "`nmin=" Round(st["min"], 3)
    . "`nmean=" Round(st["mean"], 3)
    . "`np95=" Round(st["p95"], 3)
    . "`np99=" Round(st["p99"], 3)
