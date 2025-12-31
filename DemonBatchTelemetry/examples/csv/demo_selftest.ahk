#Requires AutoHotkey v2.0
#Include ..\..\src\csv\DemonBatchTelemetryCsv.ahk

path := A_Temp "\demon_batch_csv_selftest.csv"
bt := DemonBatchTelemetryCsv(path, 256, 64, true)

Loop 200
    bt.Add(A_TickCount, Random(-10, 10), Random(-10, 10), "self")

bt.Flush()

MsgBox "PASS=" (FileExist(path) ? "YES" : "NO") "`nfile=" path
