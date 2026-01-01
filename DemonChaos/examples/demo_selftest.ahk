#Requires AutoHotkey v2.0
#Include ..\src\DemonChaos.ahk

c := DemonChaos(Map("Threshold", 2.0, "DriveGain", 2.0, "CooldownMs", 50))

dt := 4
now := 0

; Step1: no drive
trig1 := false
Loop 50 {
    now += dt
    r := c.Step(0.0, dt, now)
    trig1 := trig1 || r["triggered"]
}
ok1 := !trig1

; Step2: strong drive -> should trigger
trig2 := false
Loop 200 {
    now += dt
    r := c.Step(30.0, dt, now)
    if r["triggered"]
        trig2 := true
}
ok2 := trig2

; Step3: immediate repeat should be gated by cooldown
now += dt
r := c.Step(30.0, dt, now)
ok3 := (r["cooldownLeftMs"] > 0)

MsgBox (ok1 && ok2 && ok3 ? "PASS" : "FAIL")
    . "`nstep1(no trigger)=" ok1
    . "`nstep2(trigger)=" ok2
    . "`nstep3(cooldown)=" ok3
    . "`nscore=" Round(r["score"], 2) " bias=" Round(r["bias"], 3)
