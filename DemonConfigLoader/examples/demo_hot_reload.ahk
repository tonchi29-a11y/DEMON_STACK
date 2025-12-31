#Requires AutoHotkey v2.0
#Include ..\src\DemonConfigLoader.ahk

iniPath := A_Temp "\demon_configloader_watch.ini"
loader := DemonConfigLoader(iniPath, "ini")

; Create file if missing
if !loader.Exists() {
    loader.IniSet("General", "Value", "1")
}

OnChange(loaderObj, ok, cfg, errMsg) {
    if !ok {
        ToolTip "Config reload error:`n" errMsg
        return
    }
    v := ""
    try {
        v := cfg.Has("General") && cfg["General"].Has("Value") ? cfg["General"]["Value"] : "(missing)"
    } catch {
        v := "(missing)"
    }
    ToolTip "Reloaded " loaderObj.filePath "`nGeneral.Value=" v
}

loader.Watch(OnChange, 300)

MsgBox "Watching config file:`n" iniPath "`n`nEdit [General] Value=... and save."
Esc::ExitApp
