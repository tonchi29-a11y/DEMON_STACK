#Requires AutoHotkey v2.0

; Selftest runner (interactive)
; - Discovers: DEMON_STACK\*\examples\demo_selftest.ahk
; - Runs each via RunWait (MsgBoxes may require clicking OK)
; - Writes: DEMON_STACK\reports\selftest_report.md

root := A_ScriptDir
SplitPath(root, , &root)  ; parent of tools/selftest_runner
SplitPath(root, , &root)  ; parent of tools
root := RTrim(root, "\\/")
reportPath := root "\reports\selftest_report.md"
ahkExe := A_AhkPath

tests := FindSelftests(root)
report := RunAll(tests, root, ahkExe)
WriteMarkdownReport(reportPath, report)

MsgBox "Done.`nReport written to:`n" reportPath

; ---------------- helpers ----------------

FindSelftests(rootDir) {
    root := RTrim(rootDir, "\/")
    tests := []

    skip := Map(
        ".git", 1,
        "reports", 1,
        "stacks", 1,
        "tools", 1
    )

    ; One level deep: <root>\<Library>\examples\demo_selftest.ahk
    ; Enumerate candidate folders and probe the expected selftest path.
    Loop Files, root "\*", "D" {
        name := A_LoopFileName
        if skip.Has(name)
            continue

        ; Treat it as a library folder if it has src\
        if !DirExist(A_LoopFileFullPath "\src")
            continue

        p := A_LoopFileFullPath "\examples\demo_selftest.ahk"
        if FileExist(p)
            tests.Push(p)
    }

    ; Array.Sort() is not available in all AHK v2 builds.
    ; Use string Sort() for stable ordering.
    if (tests.Length <= 1)
        return tests

    list := ""
    for _, p in tests
        list .= p "`n"
    list := RTrim(list, "`n")
    list := Sort(list, "D`n")
    return StrSplit(list, "`n")
}

RunAll(tests, rootDir, ahkExe) {
    root := RTrim(rootDir, "\/")

    reportDir := root "\reports"
    if !DirExist(reportDir)
        DirCreate(reportDir)

    started := A_Now
    results := []

    for _, testPath in tests {
        SplitPath(testPath, , &workDir)
        libName := LibraryNameFromPath(root, testPath)

        t0 := A_TickCount
        exitCode := RunOne(ahkExe, testPath, workDir)
        t1 := A_TickCount
        ms := (t1 - t0) & 0xFFFFFFFF

        results.Push(Map(
            "lib", libName,
            "path", testPath,
            "exitCode", exitCode,
            "ms", ms
        ))
    }

    return Map(
        "rootDir", root,
        "ahkExe", ahkExe,
        "started", started,
        "ended", A_Now,
        "count", results.Length,
        "results", results
    )
}

WriteMarkdownReport(reportPath, report) {
    lines := []
    lines.Push("# DEMON_STACK Selftest Report")
    lines.Push("")
    lines.Push("- Root: `"" report["rootDir"] "`"")
    lines.Push("- AHK: `"" report["ahkExe"] "`"")
    lines.Push("- Started: `"" report["started"] "`"")
    lines.Push("- Ended: `"" report["ended"] "`"")
    lines.Push("- Count: `"" report["count"] "`"")
    lines.Push("")
    lines.Push("## Results")
    lines.Push("")
    lines.Push("| Library | ExitCode | Duration (ms) | Selftest |")
    lines.Push("|---|---:|---:|---|")

    for _, r in report["results"] {
        ; ExitCode 0 usually means OK. With MsgBox-based tests, PASS/FAIL is not machine-readable yet.
        lines.Push("| " r["lib"] " | " r["exitCode"] " | " r["ms"] " | `"" r["path"] "`" |")
    }

    lines.Push("")
    lines.Push("## Notes")
    lines.Push("")
    lines.Push("- Interactive runner (MsgBoxes may require clicking OK).")
    lines.Push("- ExitCode is collected from the AutoHotkey process.")
    lines.Push("- For fully automated CI-style testing, standardize selftests to set ExitApp(0/1) and avoid UI.")

    text := ""
    for _, ln in lines
        text .= ln "`r`n"

    try FileDelete(reportPath)
    FileAppend(text, reportPath, "UTF-8")
}

RunOne(ahkExe, scriptPath, workDir) {
    cmd := '"' ahkExe '" "' scriptPath '"'
    try {
        return RunWait(cmd, workDir)
    } catch {
        return 999
    }
}

LibraryNameFromPath(root, testPath) {
    p := testPath
    rootN := root
    if !InStr(p, rootN)
        return "(unknown)"

    rel := SubStr(p, StrLen(rootN) + 2) ; skip "\\"
    parts := StrSplit(rel, "\\")
    return parts.Length >= 1 ? parts[1] : "(unknown)"
}
