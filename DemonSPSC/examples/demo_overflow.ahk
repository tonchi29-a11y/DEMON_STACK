#Requires AutoHotkey v2.0
#Include ..\src\DemonSpscRing.ahk

q := DemonSpscRing(4) ; actual cap becomes 4

; Push 10 items without popping to force drops
Loop 10
    q.Push(1.0, 2.0, A_Index)

h := q.GetHealth()
MsgBox "After overflow:"
    . "`nfill=" h["fill"] " (should be 4)"
    . "`ndrops=" h["drops"] " (should be 6)"
    . "`ncap=" h["cap"]
