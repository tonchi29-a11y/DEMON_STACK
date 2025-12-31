#Requires AutoHotkey v2.0
#Include ..\..\DemonPack64\src\DemonPack64.ahk
#Include ..\..\DemonBridge\src\DemonBridge.ahk

; Gold Standard receiver pipeline:
; Bridge.Read -> Unpack -> ToolTip

BRIDGE_NAME := "Local\DemonBridgeDemo"

br := DemonBridge(BRIDGE_NAME, 64, 3, true)
out := Buffer(64, 0)

OnExit((*) => br.Close())

SetTimer(Poll, 50)

Poll() {
    global br, out
    if !br.ReadLatest(&out) {
        ToolTip "receiver: no data"
        return
    }

    DemonPack64.UnpackBasic(out, &ts, &flags, &emaX, &emaY)

    ; Demo polish: consider sender stale if ts is too old.
    ; ts is a u64, but the sender uses A_TickCount (u32). Handle wrap safely.
    tNow := A_TickCount
    tSent := (ts & 0xFFFFFFFF)
    age := (tNow - tSent) & 0xFFFFFFFF
    if (age > 500) {
        ToolTip "receiver: stale/no sender"
            . "`nageMs=" age
            . "`nlastTs=" ts
        return
    }

    ToolTip "receiver: ts=" ts
        . "`nflags=0x" Format("{:X}", flags)
        . "`nemaX=" Round(emaX, 2)
        . " emaY=" Round(emaY, 2)
}

Esc::ExitApp
