#Requires AutoHotkey v2.0
#Include ..\src\DemonAffinity.ahk

m1 := DemonAffinity.MakeMask(2, 4)
m2 := DemonAffinity.MaskFromList([0, 2, 4])

MsgBox "MakeMask(2,4)=0x" Format("{:X}", m1)
    . "`nMaskFromList([0,2,4])=0x" Format("{:X}", m2)
