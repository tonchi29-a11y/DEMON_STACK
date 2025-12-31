#Requires AutoHotkey v2.0
#Include ..\src\DemonSpscRing.ahk

q := DemonSpscRing(8)

; Push 3 items, pop 3 items
Loop 3
    q.Push(A_Index * 1.0, -A_Index * 1.0, A_Index)

okAll := true
Loop 3 {
    if !q.Pop(&dx, &dy, &t) {
        okAll := false
        break
    }
}

h := q.GetHealth()
MsgBox "PASS=" (okAll ? "YES" : "NO")
    . "`nfill=" h["fill"]
    . "`ndrops=" h["drops"]
    . "`ncap=" h["cap"]
