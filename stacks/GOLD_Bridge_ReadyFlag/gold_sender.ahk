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

exitGui := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -MaximizeBox", "Sender Exit")
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
hud.Show(20, 300)

; wait up to 5s for receiver
start := NowMs()
ready := false
while !ready {
    ready := rf.IsReady()
    if (((NowMs() - start) & 0xFFFFFFFF) > 5000)
        break
    Sleep 50
}

buf := Buffer(64, 0)
counter := 0

SetTimer(Tick, 200)

Tick(*) {
    global br, buf, counter, rf, hud
    counter += 1
    NumPut("UInt", NowMs(), buf, 0)
    NumPut("UInt", counter, buf, 4)
    br.Write(buf)

    hud.SetText("Sender`nready=" (rf.IsReady() ? "YES" : "NO") "`ncount=" counter)
}

*Esc::ExitApp
*F12::ExitApp
OnExit(Cleanup)
Cleanup(*) {
    global rf, br, hud, exitGui
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
