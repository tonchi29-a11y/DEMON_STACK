#Requires AutoHotkey v2.0
#Include ..\src\DemonFallback.ahk

Assert(cond, msg) {
    if !cond
        throw Error("ASSERT FAIL: " msg)
}

fb := DemonFallback(Map(
    "JitterP95_ThresholdMs", 0.60,
    "JitterTripLimit", 2,
    "BridgeFailTripLimit", 3,
    "WatchdogHiccupTripLimit", 1,
    "TripDecayOnOk", 1
))

now := 100000

; 1) start NORMAL
r := fb.Update(Map(), now)
Assert(r["mode"] = "NORMAL", "starts NORMAL")

; 2) feed jitter above threshold twice -> DEGRADED
now += 10
r := fb.Update(Map("jitterP95Ms", 0.90), now)
Assert(r["mode"] = "NORMAL", "jitter trip 1")

now += 10
r := fb.Update(Map("jitterP95Ms", 0.90), now)
Assert(r["mode"] = "DEGRADED", "jitter trip 2 => DEGRADED")

; 3) feed ok ticks until trips decay, then wait long enough -> NORMAL
now += 10
r := fb.Update(Map("jitterP95Ms", 0.10), now)
Assert(r["mode"] = "DEGRADED", "ok tick 1 (decay)")

now += 10
r := fb.Update(Map("jitterP95Ms", 0.10), now)
Assert(r["mode"] = "DEGRADED", "ok tick 2 (decay to zero, but gated)")

now += 1600
r := fb.Update(Map("jitterP95Ms", 0.10), now)
Assert(r["mode"] = "NORMAL", "recover to NORMAL after hold+cooldown")

; 4) feed bridgeFail=1 three times -> FALLBACK
now += 1600
now += 10
r := fb.Update(Map("bridgeFail", 1), now)
Assert(r["mode"] = "NORMAL", "bridge trip 1 (no mode change yet)")

now += 10
r := fb.Update(Map("bridgeFail", 1), now)
Assert(r["mode"] = "NORMAL", "bridge trip 2")

now += 10
r := fb.Update(Map("bridgeFail", 1), now)
Assert(r["mode"] = "FALLBACK", "bridge trip 3 => FALLBACK")

; 5) ok ticks long enough -> DEGRADED -> NORMAL (step-down)
now += 10
r := fb.Update(Map(), now)
Assert(r["mode"] = "FALLBACK", "ok tick 1 (decay)")

now += 10
r := fb.Update(Map(), now)
Assert(r["mode"] = "FALLBACK", "ok tick 2 (decay)")

now += 10
r := fb.Update(Map(), now)
Assert(r["mode"] = "FALLBACK", "ok tick 3 (decay to zero, but gated)")

now += 1600
r := fb.Update(Map(), now)
Assert(r["mode"] = "DEGRADED", "recover step 1: FALLBACK -> DEGRADED")

now += 1600
r := fb.Update(Map(), now)
Assert(r["mode"] = "NORMAL", "recover step 2: DEGRADED -> NORMAL")

MsgBox "DemonFallback selftest PASS"
