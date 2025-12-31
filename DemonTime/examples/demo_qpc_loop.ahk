#Requires AutoHotkey v2.0
#Include ..\src\DemonTime.ahk

t0 := DemonTime.NowQpc()
sum := 0

Loop 2000000 {
    sum += A_Index
}

elapsed := DemonTime.MsSince(t0)
MsgBox "Loop done.`nSum=" sum "`nElapsed: " Round(elapsed, 3) " ms"
