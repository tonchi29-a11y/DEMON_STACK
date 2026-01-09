#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\src\DemonBridge.ahk

; DemonBridge benchmark (two-process)
;
; Default: run sender and auto-spawn receiver.
;   - `demo_benchmark.ahk`
;
; Receiver-only:
;   - `demo_benchmark.ahk receiver`
;
; Sender-only (does not spawn receiver):
;   - `demo_benchmark.ahk sender --no-spawn`
;
; Options (both modes):
;   --name Local\DemonBridgeBench
;   --secs 5
;   --hz 0                ; 0 = as fast as possible
;   --crc 1               ; 1 = CRC enabled, 0 = disabled
;
; Output is printed to stdout when launched from a terminal.

global g_outText := ""
global g_hasStdout := false

main()

main() {
  args := A_Args

  mode := "sender"
  if args.Length >= 1 {
    if (args[1] = "sender") || (args[1] = "receiver")
      mode := args[1]
  }

  cfg := ParseArgs(args)

  if (mode = "sender") {
    if cfg["spawnReceiver"] {
      SpawnReceiver(cfg)
      Sleep 200
    }
    RunSender(cfg)
    return
  }

  RunReceiver(cfg)
}

ParseArgs(args) {
  cfg := Map(
    "name", "Local\DemonBridgeBench",
    "secs", 5.0,
    "hz", 0.0,
    "crc", true,
    "spawnReceiver", true
  )

  i := 1
  while (i <= args.Length) {
    a := args[i]

    if (a = "sender") || (a = "receiver") {
      i += 1
      continue
    }

    if (a = "--no-spawn") {
      cfg["spawnReceiver"] := false
      i += 1
      continue
    }

    if (a = "--name") && (i + 1 <= args.Length) {
      cfg["name"] := args[i + 1]
      i += 2
      continue
    }

    if (a = "--secs") && (i + 1 <= args.Length) {
      cfg["secs"] := Float(args[i + 1])
      i += 2
      continue
    }

    if (a = "--hz") && (i + 1 <= args.Length) {
      cfg["hz"] := Float(args[i + 1])
      i += 2
      continue
    }

    if (a = "--crc") && (i + 1 <= args.Length) {
      cfg["crc"] := !!Integer(args[i + 1])
      i += 2
      continue
    }

    i += 1
  }

  return cfg
}

SpawnReceiver(cfg) {
  exe := A_AhkPath
  script := A_ScriptFullPath

  cmd := '"' exe '" "' script '" receiver --name "' cfg["name"] '" --secs ' cfg["secs"] ' --crc ' (cfg["crc"] ? 1 : 0)
  Run cmd
}

RunSender(cfg) {
  name := cfg["name"]
  secs := cfg["secs"]
  hz := cfg["hz"]
  crcEnabled := cfg["crc"]

  br := DemonBridge(name, 64, 3, crcEnabled)

  payload := Buffer(64, 0)
  runningOff := 16
  NumPut("UInt", 1, payload, runningOff)

  qpf := QpcFreq()
  startQpc := QpcNow()
  endQpc := startQpc + Round(secs * qpf)

  writes := 0
  seq := 0

  nextQpc := startQpc
  periodQpc := 0
  if (hz > 0)
    periodQpc := Round(qpf / hz)

  ; warmup publish
  NumPut("UInt64", seq, payload, 0)
  NumPut("Int64", startQpc, payload, 8)
  br.Write(payload)

  while (QpcNow() < endQpc) {
    seq += 1

    now := QpcNow()
    NumPut("UInt64", seq, payload, 0)
    NumPut("Int64", now, payload, 8)

    br.Write(payload)
    writes += 1

    if (periodQpc > 0) {
      nextQpc += periodQpc
      SleepUntilQpc(nextQpc)
    }
  }

  ; signal stop
  NumPut("UInt", 0, payload, runningOff)
  NumPut("UInt64", seq + 1, payload, 0)
  NumPut("Int64", QpcNow(), payload, 8)
  br.Write(payload)

  dtSec := (QpcNow() - startQpc) / qpf
  rate := (dtSec > 0) ? (writes / dtSec) : 0

  Println("DemonBridge benchmark — sender")
  Println("name=" name)
  Println("crc=" (crcEnabled ? "1" : "0") " secs=" secs " hz=" hz)
  Println("writes=" writes " rate=" Format("{:.1f}", rate) " /sec")
  MaybeShowOutput("DemonBridge benchmark — sender")
}

RunReceiver(cfg) {
  name := cfg["name"]
  secs := cfg["secs"]
  crcEnabled := cfg["crc"]

  br := DemonBridge(name, 64, 3, crcEnabled)
  buf := Buffer(64, 0)

  qpf := QpcFreq()
  startQpc := QpcNow()
  endQpc := startQpc + Round((secs + 2.0) * qpf)

  lastSeq := -1
  samples := 0
  readOk := 0

  minUs := 0.0
  maxUs := 0.0
  meanUs := 0.0

  loop {
    now := QpcNow()
    if (now >= endQpc)
      break

    if br.ReadLatest(&buf) {
      readOk += 1

      seq := NumGet(buf, 0, "UInt64")
      sentQpc := NumGet(buf, 8, "Int64")
      running := NumGet(buf, 16, "UInt")

      if (seq != lastSeq) {
        lastSeq := seq
        latUs := ((now - sentQpc) / qpf) * 1000000.0

        samples += 1
        if (samples = 1) {
          minUs := latUs
          maxUs := latUs
          meanUs := latUs
        } else {
          if (latUs < minUs)
            minUs := latUs
          if (latUs > maxUs)
            maxUs := latUs
          meanUs += (latUs - meanUs) / samples
        }

        if (running = 0) && (samples >= 10)
          break
      }
    } else {
      Sleep 0
    }
  }

  Println("DemonBridge benchmark — receiver")
  Println("name=" name)
  Println("crc=" (crcEnabled ? "1" : "0") " secs=" secs)
  Println("readOk=" readOk " uniqueSamples=" samples)
  if (samples > 0)
    Println("latency_us: min=" Format("{:.1f}", minUs) " avg=" Format("{:.1f}", meanUs) " max=" Format("{:.1f}", maxUs))
  else
    Println("latency_us: (no samples)")

  MaybeShowOutput("DemonBridge benchmark — receiver")
}

QpcFreq() {
  static qpf := 0
  if (qpf != 0)
    return qpf

  freq := 0
  DllCall("kernel32.dll\QueryPerformanceFrequency", "Int64*", &freq)
  qpf := freq
  return qpf
}

QpcNow() {
  c := 0
  DllCall("kernel32.dll\QueryPerformanceCounter", "Int64*", &c)
  return c
}

SleepUntilQpc(targetQpc) {
  ; best-effort: coarse sleep until we're close, then spin
  qpf := QpcFreq()

  loop {
    now := QpcNow()
    dt := targetQpc - now
    if (dt <= 0)
      break

    ms := Floor((dt / qpf) * 1000.0)
    if (ms > 2) {
      Sleep ms - 1
      continue
    }

    ; spin for sub-ms
  }
}

Println(s) {
  try {
    FileAppend(s "`r`n", "*")
    global g_hasStdout := true
  } catch {
    ; fallback for non-console launches
    global g_outText
    g_outText .= s "`r`n"
    OutputDebug s
  }
}

MaybeShowOutput(title) {
  global g_hasStdout
  global g_outText

  if g_hasStdout
    return

  if (g_outText = "")
    return

  try {
    MsgBox g_outText, title
  } catch {
  }
}
