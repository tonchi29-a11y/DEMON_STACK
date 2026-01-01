#Requires AutoHotkey v2.0
#Include ..\src\csv\DemonBatchTelemetryCsv.ahk
#Include ..\src\jsonl\DemonBatchTelemetryJsonl.ahk

csvPath := A_Temp "\demon_batch_root_selftest.csv"
jsonlPath := A_Temp "\demon_batch_root_selftest.jsonl"

try FileDelete(csvPath)
try FileDelete(jsonlPath)

csv := DemonBatchTelemetryCsv(csvPath, 256, 64, true)
jsonl := DemonBatchTelemetryJsonl(jsonlPath, 256, 64)

Loop 200 {
    t := A_TickCount
    dx := Random(-10, 10)
    dy := Random(-10, 10)
    csv.Add(t, dx, dy, "self")
    jsonl.Add(t, dx, dy, "self")
}

okCsv := csv.Flush()
okJsonl := jsonl.Flush()

okFiles := FileExist(csvPath) && FileExist(jsonlPath)

jsonOk := false
try {
    s := FileRead(jsonlPath, "UTF-8")
    ; Sanity: ensure we did not emit the old over-escaped pattern.
    jsonOk := InStr(s, '{"tMs":') && !InStr(s, '{{') && !InStr(s, '""tMs""')
} catch {
    jsonOk := false
}

pass := okCsv && okJsonl && okFiles && jsonOk

MsgBox "PASS=" (pass ? "YES" : "NO")
    . "`nCSV=" csvPath
    . "`nJSONL=" jsonlPath
    . (jsonOk ? "" : "`n(note) JSONL sanity check failed")
