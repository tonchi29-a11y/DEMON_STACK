#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

#Include ..\..\DemonBridge\src\DemonBridge.ahk
#Include ..\..\DemonReadyFlag\src\DemonReadyFlag.ahk
#Include ..\..\DemonHUD\src\DemonHUD.ahk

NowMs() {
    return DllCall("kernel32.dll\GetTickCount", "UInt")
}
GetPid() {
    return DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
}

pid := GetPid()

bridgeName := "Local\DemonBridgeReadyDemo"
readyName := "Local\DemonBridgeReadyDemo_ready"

br := DemonBridge(bridgeName, 64, 3, true)
rf := DemonReadyFlag(readyName)

exitGui := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -MaximizeBox", "Receiver Exit")
exitGui.AddText("", "pid=" pid)
btnExit := exitGui.AddButton("w120 h32", "EXIT")
btnExit.OnEvent("Click", (*) => ExitApp())
exitGui.Show("NoActivate x20 y20")

hud := DemonHUD(Map(
    "Width", 480,
    "Height", 200,
    "Alpha", 235,
    "ClickThrough", false,
    "FontName", "Consolas",
    "FontSize", 10
))
hud.Show(20, 70)

rf.SetReady(true)

out := Buffer(64, 0)
SetTimer(Tick, 120)

Tick(*) {
    global br, out, hud
    if br.ReadLatest(&out) {
        t := NumGet(out, 0, "UInt")
        v := NumGet(out, 4, "UInt")
        hud.SetText("Receiver READY`n`t=" t "`n`nv=" v)
    } else {
        hud.SetText("Receiver READY`n(no data yet)")
    }
}

*Esc::ExitApp
*F12::ExitApp
OnExit(Cleanup)
Cleanup(*) {
    global rf, br, hud, exitGui
    try rf.SetReady(false)
    catch {
    }
    try rf.Close()
    catch {
    }
    try br.Close()
    catch {
    }
    try hud.Close()
    catch {
    }
    try exitGui.Destroy()
    catch {
    }
}
