#Requires AutoHotkey v2.0
#Include ..\src\DemonPredict.ahk

p := DemonPredict(Map("CooldownMs", 0, "RmbOverrides", false))

dt := 4
now := 0

; Start idle -> should remain HPR
r := p.Update("Idle", 1.0, 0, 0, 1.0, 0, false, dt, now)
ok1 := (r["desired"] = "HPR")

; Feed close-range + strong spike long enough to trigger tau_on
Loop 20 {
    now += dt
    r := p.Update("CloseRange", 1.0, 1.0, 1.0, 2.0, 3.0, false, dt, now)
}
ok2 := (r["desired"] = "ADS")

; Feed idle long enough to trigger tau_off
Loop 40 {
    now += dt
    r := p.Update("Idle", 1.0, 0.0, 0.0, 1.0, 0.0, false, dt, now)
}
ok3 := (r["desired"] = "HPR")

MsgBox (ok1 && ok2 && ok3 ? "PASS" : "FAIL")
    . "`nstep1(HPR)=" ok1
    . "`nstep2(ADS)=" ok2
    . "`nstep3(HPR)=" ok3
    . "`nfinal desired=" r["desired"]
    . "`nadsProb=" Round(r["adsProb"], 3)
