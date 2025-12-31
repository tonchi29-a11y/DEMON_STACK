#Requires AutoHotkey v2.0
#Include ..\src\DemonConfigLoader.ahk

iniPath := A_Temp "\demon_configloader_selftest.ini"

; write some values
loader := DemonConfigLoader(iniPath, "ini")
loader.IniSet("General", "Enabled", "true")
loader.IniSet("General", "Rate", "12")
loader.IniSet("General", "Scale", "0.75")
loader.IniSet("Limits", "Min", "5")
loader.IniSet("Limits", "Max", "20")

enabled := loader.GetBool("General", "Enabled", false)
rate := loader.GetInt("General", "Rate", 0, 0, 100)
scale := loader.GetFloat("General", "Scale", 1.0, 0.0, 10.0)

minV := loader.GetInt("Limits", "Min", 0)
maxV := loader.GetInt("Limits", "Max", 0)

cfg := loader.Load()

MsgBox "PASS"
    . "`nfile=" iniPath
    . "`nEnabled=" (enabled ? "true" : "false")
    . "`nRate=" rate
    . "`nScale=" scale
    . "`nMin/Max=" minV "/" maxV
    . "`nSections loaded=" cfg.Count
