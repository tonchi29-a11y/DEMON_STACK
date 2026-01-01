#Requires AutoHotkey v2.0
#Include ..\src\DemonHUD.ahk

hud := DemonHUD(Map("ClickThrough", true, "Alpha", 230))
hud.SetText("DemonHUD selftest`nline2`nline3")
hud.Show(20, 20)

ok := true
ok := ok && hud.IsVisible()
ok := ok && hud.SetOpacity(200)
ok := ok && hud.SetText("DemonHUD selftest updated`nOK")

SetTimer(End, -250)
End(*) {
    global hud, ok
    try {
        hud.Close()
    } catch {
    }
    ExitApp(ok ? 0 : 1)
}
