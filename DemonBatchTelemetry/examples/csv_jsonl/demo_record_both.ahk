#Requires AutoHotkey v2.0
#Include ..\..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\src\csv_jsonl\DemonBatchTelemetryCsvJsonl.ahk

csvPath := A_Temp "\demon_batch_both.csv"
jsonlPath := A_Temp "\demon_batch_both.jsonl"

bt := DemonBatchTelemetryCsvJsonl(csvPath, jsonlPath, 4096, 256)
bt.StartAutoFlush(1000)

OnSample(dx, dy, tMs, src) {
    global bt
    bt.Add(tMs, dx, dy, src)
}

inp := DemonInput(OnSample)
inp.StartTimerLane(4)

MsgBox "Recording BOTH (CSV+JSONL) for 3 seconds...`nCSV: " csvPath "`nJSONL: " jsonlPath
Sleep 3000
inp.Stop()
bt.StopAutoFlush()
bt.Flush()

Run('explorer.exe /select,"' csvPath '"')
ExitApp
