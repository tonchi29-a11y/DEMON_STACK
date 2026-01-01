#Requires AutoHotkey v2.0
#Include ..\src\DemonContextDetect.ahk

; Selftest (deterministic) per v1 spec
; 1) 50x (0,0,4) -> Idle
; 2) moderate motion -> LongRange
; 3) strong motion -> CloseRange
; 4) moderate motion -> LongRange
; 5) 80x (0,0,4) -> Idle

ctx := DemonContextDetect(Map(
    "HoldMs", 120
))

Expect(label, want) {
    global ctx
    got := ctx.GetState()["context"]
    if (got != want)
        return label ": expected " want ", got " got
    return ""
}

RunBlock(count, dx, dy, dt) {
    global ctx
    global nowMs
    Loop count {
        nowMs += dt
        ctx.Update(dx, dy, dt, nowMs)
    }
}

fail := ""

dt := 4
nowMs := 0

RunBlock(50, 0, 0, dt)
fail := (fail != "") ? fail : Expect("step1", "Idle")

; Step 2: should become LongRange (strong enough + enough time for EMA)
RunBlock(120, 2, 0, dt)
fail := (fail != "") ? fail : Expect("step2", "LongRange")

; Allow hold to expire after any transition.
RunBlock(40, 2, 0, dt)

; Step 3: should become CloseRange
RunBlock(60, 8, 0, dt)
fail := (fail != "") ? fail : Expect("step3", "CloseRange")

; Allow hold to expire after any transition.
RunBlock(40, 8, 0, dt)

; Step 4: should return to LongRange
RunBlock(120, 2, 0, dt)
fail := (fail != "") ? fail : Expect("step4", "LongRange")

; Allow hold to expire after any transition.
RunBlock(40, 2, 0, dt)

RunBlock(80, 0, 0, dt)
fail := (fail != "") ? fail : Expect("step5", "Idle")

st := ctx.GetState()
pass := (fail = "")

MsgBox (pass ? "PASS" : "FAIL")
    . "`n" (pass ? "" : fail)
    . "`nlast=" st["context"]
    . "`nconfidence=" Round(st["confidence"], 2)
    . "`nvel=" Round(st["vel"], 4) " avgSpeed=" Round(st["avgSpeed"], 4)
