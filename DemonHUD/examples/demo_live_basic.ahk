#Requires AutoHotkey v2.0
#Include ..\src\DemonHUD.ahk

hud := DemonHUD()
hud.Show(20, 20)

counter := 0
hud.Start((h) => "DemonHUD live`ncount=" (++counter) "`ntime=" A_TickCount, 250)

Esc::ExitApp
OnExit((*) => hud.Close())
