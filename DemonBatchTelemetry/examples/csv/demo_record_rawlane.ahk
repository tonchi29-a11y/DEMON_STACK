#Requires AutoHotkey v2.0
#Include ..\..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\src\csv\DemonBatchTelemetryCsv.ahk

path := A_Temp "\demon_batch_rawlane.csv"
bt := DemonBatchTelemetryCsv(path, 4096, 256, true)
bt.StartAutoFlush(1000)

OnSample(dx, dy, tMs, src) {
    global bt
    bt.Add(tMs, dx, dy, src)
}

inp := DemonInput(OnSample)
inp.StartRawInputLane(A_ScriptHwnd, true, true)

MsgBox "Recording RAW lane for 3 seconds...`n" path
Sleep 3000
inp.Stop()
bt.StopAutoFlush()
bt.Flush()

Run('explorer.exe /select,"' path '"')
ExitApp
