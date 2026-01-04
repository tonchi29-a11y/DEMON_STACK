#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

#Include ..\..\DemonHUD\src\DemonHUD.ahk
#Include ..\..\DemonHotkeys\src\DemonHotkeys.ahk
#Include ..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonContextDetect\src\DemonContextDetect.ahk
#Include ..\..\DemonPredict\src\DemonPredict.ahk
#Include ..\..\DemonNeuromorphic\src\DemonNeuromorphic.ahk
#Include ..\..\DemonChaos\src\DemonChaos.ahk
#Include ..\..\DemonQuantumBuffer\src\DemonQuantumBuffer.ahk

NowMs() {
    return DllCall("kernel32.dll\GetTickCount", "UInt")
}
GetPid() {
    return DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
}

Clamp01(x) {
    if (x < 0)
        return 0.0
    if (x > 1)
        return 1.0
    return x + 0.0
}

; -------- state --------
pid := GetPid()

g := Map(
    "pid", pid,
    "lane", "Timer",
    "samples", 0,

    "enableChaos", true,
    "enableNeuro", true,
    "enableQuantum", true,

    "marker", 0,
    "lastAction", "boot",
    "lastActionMs", NowMs(),

    "ctx", "Idle",
    "conf", 0.0,
    "avgSpeed", 0.0,
    "hvRatio", 0.0,
    "spike", 0.0,

    "baseProb", 0.0,
    "adjProb", 0.0,
    "desired", "HPR",
    "reason", "",

    "chaosScore", 0.0,
    "chaosBias", 0.0,
    "chaosCd", 0,

    "neuroSpiked", false,
    "neuroBoost", 0.0,
    "neuroSpikes", 0,

    "q", 0.0,
    "collapsed", false
)

; -------- safety exit GUI (mouse exit works even if hotkeys die) --------
exitGui := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -MaximizeBox", "GOLD_Brain_Predict Exit")
exitGui.AddText("", "pid=" pid)
btnExit := exitGui.AddButton("w140 h34", "EXIT")
btnExit.OnEvent("Click", (*) => ExitApp())
exitGui.Show("NoActivate x20 y20")

; -------- HUD --------
hud := DemonHUD(Map(
    "Width", 560,
    "Height", 380,
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
    txt .= "GOLD_Brain_Predict`n"
    txt .= "pid=" g["pid"] " samples=" g["samples"] " lane=" g["lane"] "`n"
    txt .= "ctx=" g["ctx"] " conf=" Round(g["conf"], 2)
        . " avg=" Round(g["avgSpeed"], 3)
        . " hv=" Round(g["hvRatio"], 2)
        . " spike=" Round(g["spike"], 2) "`n"
    txt .= "predict: base=" Round(g["baseProb"], 2)
        . " adj=" Round(g["adjProb"], 2)
        . " desired=" g["desired"]
        . " reason=" g["reason"] "`n"
    txt .= "chaos: " (g["enableChaos"] ? "ON" : "OFF")
        . " score=" Round(g["chaosScore"], 2)
        . " bias=" Round(g["chaosBias"], 3)
        . " cd=" g["chaosCd"] "`n"
    txt .= "neuro: " (g["enableNeuro"] ? "ON" : "OFF")
        . " spiked=" (g["neuroSpiked"] ? "Y" : "N")
        . " boost=" Round(g["neuroBoost"], 2)
        . " spikes=" g["neuroSpikes"] "`n"
    txt .= "quantum: " (g["enableQuantum"] ? "ON" : "OFF")
        . " q=" Round(g["q"], 3)
        . " collapsed=" (g["collapsed"] ? "Y" : "N") "`n"
    txt .= "marker=" g["marker"] " last=" g["lastAction"] " (" age "ms)`n"
    txt .= "`nHotkeys:`n"
    txt .= "  Ctrl+Alt+K  toggle chaos`n"
    txt .= "  Ctrl+Alt+N  toggle neuro`n"
    txt .= "  Ctrl+Alt+Q  toggle quantum`n"
    txt .= "  Ctrl+Alt+L  marker`n"
    txt .= "  Esc / F12   exit`n"
    return txt
}
hud.Start(HudProvider, 250)

; -------- pipeline --------
q := DemonSpscRing(4096)
ctx := DemonContextDetect(Map("HoldMs", 120))
pred := DemonPredict()
chaos := DemonChaos()
neuro := DemonNeuromorphic(Map("Count", 3))
quant := DemonQuantumBuffer(Map("NoiseAmp", 0.0)) ; deterministic feel

lastT := 0

OnSample(dx, dy, tMs, source) {
    global q, g
    q.Push(dx, dy, tMs)
    g["samples"] += 1
}

inp := DemonInput(OnSample)
inp.StartTimerLane(4)

SetTimer(Drain, 8)
SetTimer(Compute, 60)

Drain(*) {
    global q, ctx, lastT, g
    while q.Pop(&dx, &dy, &tMs) {
        dt := 4
        if (lastT != 0) {
            d := (tMs - lastT)
            if (d < 1)
                d := 1
            if (d > 16)
                d := 16
            dt := d
        }
        lastT := tMs

        ctx.Update(dx, dy, dt, tMs)
        g["samples"] += 1
    }
}

Compute(*) {
    global ctx, pred, chaos, neuro, quant, g

    st := ctx.GetState()

    g["ctx"] := st["context"]
    g["conf"] := st["confidence"]
    g["avgSpeed"] := st["avgSpeed"]
    g["hvRatio"] := st["hvRatio"]
    g["spike"] := st["spike"]

    now := NowMs()
    dt := 60

    ; Quantum gate (optional): drive with avgSpeed
    g["collapsed"] := false
    if g["enableQuantum"] {
        rQ := quant.Update(g["avgSpeed"], dt, now)
        g["q"] := rQ["q"]
        g["collapsed"] := rQ["collapsed"]
    } else {
        g["q"] := 0.0
    }

    ; Chaos bias (optional)
    if g["enableChaos"] {
        drive := g["avgSpeed"] * g["conf"] * 10.0
        rC := chaos.Step(drive, dt, now)
        g["chaosScore"] := rC["score"]
        g["chaosBias"] := rC["bias"]
        g["chaosCd"] := rC["cooldownLeftMs"]
    } else {
        g["chaosScore"] := 0.0
        g["chaosBias"] := 0.0
        g["chaosCd"] := 0
    }

    ; Neuromorphic boost (optional)
    if g["enableNeuro"] {
        inten := g["avgSpeed"] * g["conf"]
        rN := neuro.Update([inten, 0.0, 0.0], dt, now)
        g["neuroSpiked"] := rN["spiked"]
        g["neuroBoost"] := rN["boost"]
        g["neuroSpikes"] := rN["spikesTotal"]
    } else {
        g["neuroSpiked"] := false
        g["neuroBoost"] := 0.0
        g["neuroSpikes"] := 0
    }

    ; Base predictor
    rP := pred.Update(
        g["ctx"], g["conf"],
        st["vel"], g["avgSpeed"], g["hvRatio"], g["spike"],
        false, dt, now
    )

    base := rP["adsProb"]
    adj := Clamp01(base + g["chaosBias"] + g["neuroBoost"])

    ; If quantum enabled and NOT collapsed, reduce probability a bit (demo behavior)
    if g["enableQuantum"] && !g["collapsed"]
        adj := Clamp01(adj * 0.85)

    g["baseProb"] := base
    g["adjProb"] := adj
    g["desired"] := rP["desired"]
    g["reason"] := rP["reason"]
}

; -------- hotkeys --------
hk := DemonHotkeys()
hk.Add("^!k", (*) => Toggle("enableChaos"))
hk.Add("^!n", (*) => Toggle("enableNeuro"))
hk.Add("^!q", (*) => Toggle("enableQuantum"))
hk.Add("^!l", (*) => Marker())
hk.Enable()

Toggle(field) {
    global g
    g[field] := !g[field]
    g["lastAction"] := "toggle " field "=" (g[field] ? "ON" : "OFF")
    g["lastActionMs"] := NowMs()
}

Marker() {
    global g
    g["marker"] += 1
    g["lastAction"] := "marker #" g["marker"]
    g["lastActionMs"] := NowMs()
}

*Esc::ExitApp
*F12::ExitApp

OnExit(Cleanup)
Cleanup(*) {
    global hk, hud, inp, exitGui
    try hk.Disable()
    catch {
    }
    try hud.Close()
    catch {
    }
    try inp.Stop()
    catch {
    }
    try exitGui.Destroy()
    catch {
    }
}
