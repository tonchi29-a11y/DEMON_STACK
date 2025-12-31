#Requires AutoHotkey v2.0
#Include ..\src\DemonTime.ahk

measured := DemonTime.MeasureSleep(100)
MsgBox "Requested Sleep(100)`nMeasured: " Round(measured, 3) " ms"
