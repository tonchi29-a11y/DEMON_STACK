#Requires AutoHotkey v2.0
#Include ..\src\DemonContextDetect.ahk

; Selftest (deterministic) per v1 spec
; 1) 50x (0,0,4) -> Idle
; 2) 60x (1,0,4) -> LongRange
; 3) 20x (8,0,4) -> CloseRange
; 4) 80x (1,0,4) -> LongRange
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
    Loop count
        ctx.Update(dx, dy, dt)
}

fail := ""

RunBlock(50, 0, 0, 4)
fail := (fail != "") ? fail : Expect("step1", "Idle")

RunBlock(60, 1, 0, 4)
fail := (fail != "") ? fail : Expect("step2", "LongRange")

RunBlock(20, 8, 0, 4)
fail := (fail != "") ? fail : Expect("step3", "CloseRange")

RunBlock(80, 1, 0, 4)
fail := (fail != "") ? fail : Expect("step4", "LongRange")

RunBlock(80, 0, 0, 4)
fail := (fail != "") ? fail : Expect("step5", "Idle")

st := ctx.GetState()
pass := (fail = "")

MsgBox (pass ? "PASS" : "FAIL")
    . "`n" (pass ? "" : fail)
    . "`nlast=" st["context"]
    . "`nconfidence=" Round(st["confidence"], 2)
    . "`nvel=" Round(st["vel"], 4) " avgSpeed=" Round(st["avgSpeed"], 4)
