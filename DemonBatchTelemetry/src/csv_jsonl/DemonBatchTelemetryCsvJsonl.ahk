#Requires AutoHotkey v2.0
#Include ..\csv\DemonBatchTelemetryCsv.ahk
#Include ..\jsonl\DemonBatchTelemetryJsonl.ahk

class DemonBatchTelemetryCsvJsonl {
    __New(csvPath, jsonlPath, capacity := 4096, flushEvery := 256) {
        this.csv := DemonBatchTelemetryCsv(csvPath, capacity, flushEvery, true)
        this.jsonl := DemonBatchTelemetryJsonl(jsonlPath, capacity, flushEvery)
    }

    Add(tMs, dx, dy, source := "") {
        this.csv.Add(tMs, dx, dy, source)
        this.jsonl.Add(tMs, dx, dy, source)
        return true
    }

    Flush() {
        a := this.csv.Flush()
        b := this.jsonl.Flush()
        return a || b
    }

    StartAutoFlush(intervalMs := 1000) {
        this.csv.StartAutoFlush(intervalMs)
        this.jsonl.StartAutoFlush(intervalMs)
    }

    StopAutoFlush() {
        this.csv.StopAutoFlush()
        this.jsonl.StopAutoFlush()
    }

    GetState() {
        return Map(
            "csv", this.csv.GetState(),
            "jsonl", this.jsonl.GetState()
        )
    }

    __Delete() {
        try {
            this.StopAutoFlush()
        } catch {
        }
        try {
            this.Flush()
        } catch {
        }
    }
}
