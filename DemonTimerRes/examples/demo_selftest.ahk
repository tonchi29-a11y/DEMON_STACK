#Requires AutoHotkey v2.0
#Include ..\..\DemonTime\src\DemonTime.ahk
#Include ..\src\DemonTimerRes.ahk

t0 := DemonTime.NowQpc()
Sleep 10
base := DemonTime.MsSince(t0)

ok := DemonTimerRes.Acquire(1)

t1 := DemonTime.NowQpc()
Sleep 10
hi := DemonTime.MsSince(t1)

DemonTimerRes.Release()

st := DemonTimerRes.GetState()
MsgBox "Acquire(1ms) ok=" ok
    . "`nSleep(10) baseline: " Round(base, 3) " ms"
    . "`nSleep(10) with request: " Round(hi, 3) " ms"
    . "`nState: refs=" st["refs"] " ms=" st["ms"]

; Notes:
; - This does not guarantee perfect 1ms sleeps; it’s a request and Windows scheduling still applies.
; - timeBeginPeriod affects the system timer resolution while held.
