#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\..\DemonHUD\src\DemonHUD.ahk
#Include ..\..\DemonHotkeys\src\DemonHotkeys.ahk

g := Map(
    "hudVisible", true,
    "hudHeartbeat", true,
    "workerEnabled", true,
    "opacity", 220,
    "x", 20,
    "y", 20,
    "counter", 0,
    "markers", 0,
    "lastAction", "boot",
    "lastActionMs", A_TickCount
)

hud := DemonHUD(Map("Width", 360, "Height", 240, "Alpha", g["opacity"], "ClickThrough", true))
hud.Show(g["x"], g["y"])

HudProvider(h) {
    global g
    now := A_TickCount
    age := (now - g["lastActionMs"]) & 0xFFFFFFFF

    txt := ""
    txt .= "GOLD_HUD_Controls`n"
    txt .= "----------------`n"
    txt .= "HUD: " (g["hudVisible"] ? "ON" : "OFF")
        . " | HB: " (g["hudHeartbeat"] ? "ON" : "OFF")
        . " | Opacity: " g["opacity"] "`n"
    txt .= "Worker: " (g["workerEnabled"] ? "ON" : "OFF")
        . " | counter=" g["counter"] "`n"
    txt .= "Markers: " g["markers"] "`n"
    txt .= "Last: " g["lastAction"] " (" age " ms ago)`n"
    txt .= "`n"
    txt .= "Hotkeys:`n"
    txt .= "  Ctrl+Alt+H  toggle HUD`n"
    txt .= "  Ctrl+Alt+U  toggle HUD heartbeat`n"
    txt .= "  Ctrl+Alt+T  toggle worker timer`n"
    txt .= "  Ctrl+Alt+Up/Down  opacity +/-`n"
    txt .= "  Ctrl+Alt+Arrows   move HUD`n"
    txt .= "  Ctrl+Alt+L  marker`n"
    txt .= "  Esc         exit`n"
    return txt
}

hud.Start(HudProvider, 250)

SetTimer(WorkerTick, 100)
WorkerTick(*) {
    global g
    if !g["workerEnabled"]
        return
    g["counter"] += 1
}

hk := DemonHotkeys()
hk.Add("^!h", (*) => ToggleHud())
hk.Add("^!u", (*) => ToggleHudHeartbeat())
hk.Add("^!t", (*) => ToggleWorker())
hk.Add("^!l", (*) => AddMarker())
hk.Add("^!Up", (*) => AdjustOpacity(+10))
hk.Add("^!Down", (*) => AdjustOpacity(-10))
hk.Add("^!Left", (*) => MoveHud(-10, 0))
hk.Add("^!Right", (*) => MoveHud(+10, 0))
hk.Add("^!PgUp", (*) => MoveHud(0, -10))
hk.Add("^!PgDn", (*) => MoveHud(0, +10))
hk.Enable()

ToggleHud() {
    global g, hud
    g["hudVisible"] := !g["hudVisible"]
    g["lastAction"] := "toggle HUD=" (g["hudVisible"] ? "ON" : "OFF")
    g["lastActionMs"] := A_TickCount

    if g["hudVisible"] {
        hud.Show(g["x"], g["y"])
        hud.SetOpacity(g["opacity"])
    } else {
        hud.Hide()
    }
}

ToggleHudHeartbeat() {
    global g, hud
    g["hudHeartbeat"] := !g["hudHeartbeat"]
    g["lastAction"] := "toggle HUD HB=" (g["hudHeartbeat"] ? "ON" : "OFF")
    g["lastActionMs"] := A_TickCount

    if g["hudHeartbeat"] {
        hud.Start(HudProvider, 250)
    } else {
        hud.Stop()
    }
}

ToggleWorker() {
    global g
    g["workerEnabled"] := !g["workerEnabled"]
    g["lastAction"] := "toggle worker=" (g["workerEnabled"] ? "ON" : "OFF")
    g["lastActionMs"] := A_TickCount
}

AddMarker() {
    global g
    g["markers"] += 1
    g["lastAction"] := "marker #" g["markers"]
    g["lastActionMs"] := A_TickCount
}

AdjustOpacity(delta) {
    global g, hud
    a := g["opacity"] + delta
    if (a < 0)
        a := 0
    if (a > 255)
        a := 255
    g["opacity"] := a
    g["lastAction"] := "opacity=" a
    g["lastActionMs"] := A_TickCount
    hud.SetOpacity(a)
}

MoveHud(dx, dy) {
    global g, hud
    g["x"] += dx
    g["y"] += dy
    if (g["x"] < 0)
        g["x"] := 0
    if (g["y"] < 0)
        g["y"] := 0

    g["lastAction"] := "move HUD x=" g["x"] " y=" g["y"]
    g["lastActionMs"] := A_TickCount

    if g["hudVisible"] {
        hud.Show(g["x"], g["y"])
        hud.SetOpacity(g["opacity"])
    }
}

Esc::ExitApp
OnExit(Cleanup)

Cleanup(*) {
    global hk, hud
    try {
        hk.Disable()
    } catch {
    }
    try {
        hud.Close()
    } catch {
    }
}
