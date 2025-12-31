#Requires AutoHotkey v2.0
#Include ..\src\DemonEma.ahk

ema := DemonEma(0, 0.5) ; fixed alpha 0.5
ema.Reset(0, 0)

; step input dx=10 repeated 4 times should converge:
; x0=0
; x1=5
; x2=7.5
; x3=8.75
; x4=9.375
Loop 4
    ema.Update(10, 0, 1)

MsgBox "Expected X≈9.375`nGot X=" Round(ema.X(), 6)
