#Requires AutoHotkey v2.0
#Include ..\src\DemonEma.ahk

dtEma := DemonEma(25, 0.12) ; dt-based
fxEma := DemonEma(0, 0.12)  ; fixed alpha

dtEma.Reset(), fxEma.Reset()

; Same input, varying dt
dts := [1, 4, 16, 40]
out := "dt-based vs fixed alpha`n"
for dt in dts {
    dtEma.Update(10, 0, dt)
    fxEma.Update(10, 0, dt)
    out .= "dt=" dt "ms -> dtX=" Round(dtEma.X(), 4) " fixedX=" Round(fxEma.X(), 4) "`n"
}
MsgBox out
