#Requires AutoHotkey v2.0
#Include ..\src\DemonJitter.ahk

j := DemonJitter(100)
Loop 100
    j.Add(A_Index) ; 1..100

st := j.GetStats()

MsgBox "PASS selftest"
    . "`ncount=" st["count"]
    . "`nmin=" st["min"] " max=" st["max"]
    . "`nmean=" Round(st["mean"], 2)
    . "`np50=" st["p50"] " (expect 50)"
    . "`np95=" st["p95"] " (expect 95)"
    . "`np99=" st["p99"] " (expect 99)"
