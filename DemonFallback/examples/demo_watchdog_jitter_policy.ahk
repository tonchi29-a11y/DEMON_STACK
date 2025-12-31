#Requires AutoHotkey v2.0
#Include ..\src\DemonFallback.ahk

; Demo: show jitter trips pushing NORMAL -> DEGRADED
; Override cooldown/hold so the demo flips immediately.
fb := DemonFallback(Map(
    "CooldownMs", 0,
    "MinHoldMs", 0,
    "JitterP95_ThresholdMs", 0.6,
    "JitterTripLimit", 2
))

p95 := 1.34

sig := Map("jitterP95Ms", p95)

r1 := fb.Update(sig)
r2 := fb.Update(sig)

st := fb.GetState()

p95Disp := Round(p95, 2)

MsgBox "p95=" p95Disp
    . "`nmode=" r2["mode"]
    . "`nchanged=" (r2["changed"] ? "YES" : "NO")
    . "`nreason=" r2["reason"]
    . "`ntrips=" r2["trips"]["jitter"] "/" r2["trips"]["wd"] "/" r2["trips"]["bridge"]
