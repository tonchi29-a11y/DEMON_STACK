#Requires AutoHotkey v2.0
#Include ..\src\DemonNeuromorphic.ahk

n := DemonNeuromorphic(Map(
    "Count", 3,
    "LearningRate", 0.30,
    "Decay", 0.990,
    "Threshold", 0.5,
    "RefractoryMs", 12
))

dt := 4
now := 0

; Step1: idle inputs -> no spikes
Loop 30 {
    now += dt
    r := n.Update([0.0, 0.0, 0.0], dt, now)
}
ok1 := (r["spikeCount"] = 0)

; Step2: drive neuron #2 hard -> should spike
Loop 10 {
    now += dt
    r := n.Update([0.0, 0.9, 0.0], dt, now)
}
ok2 := (r["spikeCount"] > 0) && r["spiked"]

; Step3: refractory guard -> immediate re-drive should not spike
Loop 2 {
    now += dt
    r := n.Update([0.0, 0.9, 0.0], dt, now)
}
ok3 := (r["spikeCount"] = 0)

MsgBox (ok1 && ok2 && ok3 ? "PASS" : "FAIL")
    . "`nstep1(no spike)=" ok1
    . "`nstep2(spike)=" ok2
    . "`nstep3(refractory)=" ok3
    . "`nboost=" Round(r["boost"], 3)
