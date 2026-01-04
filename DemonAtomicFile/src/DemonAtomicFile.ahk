#Requires AutoHotkey v2.0

class DemonAtomicFile {
    ; Writes text to a temp file in the SAME directory, then replaces the target.
    ; Keeping temp in the same directory ensures the rename/move stays on the same volume.
    static WriteTextAtomic(path, text, encoding := "UTF-8") {
        if !(path is String) || (path = "")
            throw ValueError("path must be non-empty string")

        dir := DemonAtomicFile._DirOf(path)
        if (dir = "")
            dir := A_WorkingDir

        if !DirExist(dir)
            DirCreate(dir)

        tmp := DemonAtomicFile._TmpPath(path)

        ; Write temp
        try {
            f := FileOpen(tmp, "w", encoding)
            if !IsObject(f)
                throw Error("FileOpen failed")
            f.Write(text "")
            f.Close()
        } catch as e {
            ; best-effort cleanup
            try {
                FileDelete(tmp)
            } catch {
            }
            throw e
        }

        ; Replace target (same directory => same volume)
        try {
            FileMove(tmp, path, true)
        } catch as e {
            ; cleanup temp if move failed
            try {
                FileDelete(tmp)
            } catch {
            }
            throw e
        }

        return true
    }

    static _DirOf(path) {
        ; AHK v2: SplitPath gives dir in OutDir
        SplitPath(path, , &outDir)
        return outDir
    }

    static _TmpPath(path) {
        ; unique temp file name in same dir
        SplitPath(path, &outFileName, &outDir)
        if (outDir = "")
            outDir := A_WorkingDir

        pid := DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
        tick := A_TickCount
        return outDir "\" outFileName ".tmp." pid "." tick
    }
}
