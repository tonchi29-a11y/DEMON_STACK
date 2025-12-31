#Requires AutoHotkey v2.0
#Include ..\src\DemonSpscRing.ahk

q := DemonSpscRing(16)

; Producer simulation
Loop 10
    q.Push(Random(-10, 10), Random(-10, 10), A_TickCount)

; Consumer simulation
out := ""
while q.Pop(&dx, &dy, &t)
    out .= Format("dx={:.2f} dy={:.2f} t={}`n", dx, dy, t)

MsgBox out
