#Requires AutoHotkey v2.0
#Include ..\src\DemonQuantumBuffer.ahk

q := DemonQuantumBuffer(Map(
    "Threshold", 1.0,
    "Gain", 0.25,
    "Decay", 0.95,
    "NoiseAmp", 0.0,
    "Uncertainty", 1.0
))
q.SetSeed(12345)

dt := 4
now := 0

; Step1: tiny magnitudes -> no collapse (even though q may accumulate)
ok1 := true
Loop 20 {
    now += dt
    r := q.Update(0.1, dt, now)
    if r["collapsed"]
        ok1 := false
}

; Reset to make Step2/3 deterministic (start from q=0)
q.Reset()

; Step2: drive until first collapse, then stop
ok2 := false
qAfterCollapse := -1.0

Loop 80 {
    now += dt
    r := q.Update(0.6, dt, now)
    if r["collapsed"] {
        ok2 := true
        qAfterCollapse := r["q"]
        break
    }
}

; After collapse, q must be reset to 0
ok2b := ok2 && (qAfterCollapse = 0.0)

; Step3: after collapse, small magnitude should grow from ~0
now += dt
r := q.Update(0.1, dt, now)
ok3 := (r["q"] > 0.0) && (r["q"] < 0.1)

MsgBox (ok1 && ok2b && ok3 ? "PASS" : "FAIL")
    . "`nstep1(no collapse)=" ok1
    . "`nstep2(collapsed)=" ok2b
    . "`nstep3(reset/grow)=" ok3
    . "`nq=" Round(r["q"], 3)
