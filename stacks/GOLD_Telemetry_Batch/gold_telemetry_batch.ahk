#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

#Include ..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonEMA\src\DemonEma.ahk
#Include ..\..\DemonBatchTelemetry\src\csv_jsonl\DemonBatchTelemetryCsvJsonl.ahk
#Include ..\..\DemonHUD\src\DemonHUD.ahk
#Include ..\..\DemonHotkeys\src\DemonHotkeys.ahk

NowMs() {
    return DllCall("kernel32.dll\GetTickCount", "UInt")
}
GetPid() {
    return DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
}

; ---------- paths ----------

pid := GetPid()
tick := NowMs()

csvPath := A_Temp "\demon_telemetry_" pid "_" tick ".csv"
jsonPath := A_Temp "\demon_telemetry_" pid "_" tick ".jsonl"

; ---------- pipeline ----------
q := DemonSpscRing(4096)
ema := DemonEma(25, 0.12)

bt := DemonBatchTelemetryCsvJsonl(csvPath, jsonPath, 4096, 256)

g := Map(
    "pid", pid,
    "startMs", tick,
    "lastMs", tick,
    "samplesIn", 0,
    "samplesOut", 0,
    "paused", false,
    "marker", 0,
    "lastAction", "boot",
    "lastActionMs", tick,
    "csvPath", csvPath,
    "jsonPath", jsonPath
)

; Exit button (mouse-safe shutdown)
exitGui := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -MaximizeBox", "GOLD_Telemetry_Batch")
exitGui.AddText("", "pid=" pid)
btnExit := exitGui.AddButton("w120 h32", "EXIT")
btnExit.OnEvent("Click", (*) => ExitApp())
exitGui.Show("NoActivate x20 y20")

; HUD
hud := DemonHUD(Map(
    "Width", 620,
    "Height", 340,
    "Alpha", 235,
    "ClickThrough", true,
    "FontName", "Consolas",
    "FontSize", 10
))
hud.Show(20, 70)

HudProvider(h) {
    global g
    now := NowMs()
    age := (now - g["lastActionMs"]) & 0xFFFFFFFF

    txt := ""
    txt .= "GOLD_Telemetry_Batch`n"
    txt .= "pid=" g["pid"] " paused=" (g["paused"] ? "YES" : "NO") "`n"
    txt .= "in=" g["samplesIn"] " out=" g["samplesOut"] "`n"
    txt .= "marker=" g["marker"] " last=" g["lastAction"] " (" age "ms)`n"
    txt .= "`nCSV:`n" g["csvPath"] "`n"
    txt .= "`nJSONL:`n" g["jsonPath"] "`n"
    txt .= "`nHotkeys:`n"
    txt .= "  Ctrl+Alt+P  pause/resume`n"
    txt .= "  Ctrl+Alt+F  flush now`n"
    txt .= "  Ctrl+Alt+L  marker line`n"
    txt .= "  Esc / F12   exit`n"
    return txt
}
hud.Start(HudProvider, 250)

; ---------- input callback ----------
OnSample(dx, dy, tMs, source) {
    global q, g
    q.Push(dx, dy, tMs)
    g["samplesIn"] += 1
}

inp := DemonInput(OnSample)
inp.StartTimerLane(4) ; portable lane

; ---------- consumer ----------
lastT := 0

SetTimer(Drain, 8)
SetTimer(PeriodicFlush, 2000)

Drain(*) {
    global q, ema, bt, g, lastT

    while q.Pop(&dx, &dy, &tMs) {
        dt := 4
        if (lastT != 0) {
            d := tMs - lastT
            if (d < 1)
                d := 1
            if (d > 16)
                d := 16
            dt := d
        }
        lastT := tMs

        ema.UpdateSample(dx, dy, tMs)

        if g["paused"]
            continue

        ex := dx + 0.0
        ey := dy + 0.0
        try {
            ex := ema.X()
            ey := ema.Y()
        } catch {
        }

        bt.Add(tMs, ex, ey, "ema")
        g["samplesOut"] += 1
        g["lastMs"] := tMs
    }
}

PeriodicFlush(*) {
    global bt, g
    if g["paused"]
        return
    try {
        bt.Flush()
    } catch {
    }
}

; ---------- hotkeys ----------
hk := DemonHotkeys()
hk.Add("^!p", (*) => TogglePause())
hk.Add("^!f", (*) => DoFlush())
hk.Add("^!l", (*) => DoMarker())
hk.Enable()

TogglePause() {
    global g
    g["paused"] := !g["paused"]
    g["lastAction"] := "pause=" (g["paused"] ? "ON" : "OFF")
    g["lastActionMs"] := NowMs()
}

DoFlush() {
    global bt, g
    try {
        bt.Flush()
    } catch {
    }
    g["lastAction"] := "flush"
    g["lastActionMs"] := NowMs()
}

DoMarker() {
    global bt, g
    g["marker"] += 1
    now := NowMs()
    try {
        bt.Add(now, 0.0, 0.0, "marker#" g["marker"])
        bt.Flush()
    } catch {
    }
    g["lastAction"] := "marker#" g["marker"]
    g["lastActionMs"] := now
}

; HARD exits independent of hotkey manager
*Esc::ExitApp
*F12::ExitApp

OnExit(Cleanup)

Cleanup(*) {
    global hk, hud, inp, bt, exitGui
    try hk.Disable()
    catch {
    }
    try hud.Close()
    catch {
    }
    try inp.Stop()
    catch {
    }
    try {
        bt.Flush()
    } catch {
    }
    try exitGui.Destroy()
    catch {
    }
}
