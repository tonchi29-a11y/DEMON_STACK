#Requires AutoHotkey v2.0
#Include ..\..\src\jsonl\DemonBatchTelemetryJsonl.ahk

path := A_Temp "\demon_batch_jsonl_selftest.jsonl"
bt := DemonBatchTelemetryJsonl(path, 256, 64)

Loop 200
    bt.Add(A_TickCount, Random(-10, 10), Random(-10, 10), "self")

bt.Flush()

MsgBox "PASS=" (FileExist(path) ? "YES" : "NO") "`nfile=" path
