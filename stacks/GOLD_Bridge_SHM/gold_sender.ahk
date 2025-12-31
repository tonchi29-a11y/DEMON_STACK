#Requires AutoHotkey v2.0
#Include ..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonEMA\src\DemonEma.ahk
#Include ..\..\DemonPack64\src\DemonPack64.ahk
#Include ..\..\DemonBridge\src\DemonBridge.ahk

; Gold Standard sender pipeline:
; Input -> SPSC -> EMA -> Pack64 -> Bridge.Write

BRIDGE_NAME := "Local\DemonBridgeDemo"
FLAGS := 0

q := DemonSpscRing(2048)
ema := DemonEma(25, 0.12)
ema.Reset(0, 0)

br := DemonBridge(BRIDGE_NAME, 64, 3, true)
payload := DemonPack64.New()

OnSample(dx, dy, tMs, source) {
    global q
    q.Push(dx, dy, tMs)
}

inp := DemonInput(OnSample)
; Minimal + reliable: timer lane
inp.StartTimerLane(4)

OnExit((*) => (inp.Stop(), br.Close()))

SetTimer(DrainAndPublish, 8)
SetTimer(UpdateTip, 250)

DrainAndPublish() {
    global q, ema, br, payload

    lastT := 0
    while q.Pop(&dx, &dy, &tMs) {
        ema.UpdateSample(dx, dy, tMs)
        lastT := tMs
    }

    if (lastT = 0)
        return

    DemonPack64.PackBasic(payload, lastT, FLAGS, ema.X(), ema.Y())
    br.Write(payload)
}

UpdateTip() {
    global ema
    ToolTip "sender: emaX=" Round(ema.X(), 2) " emaY=" Round(ema.Y(), 2)
}

Esc::ExitApp
