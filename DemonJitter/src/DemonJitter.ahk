#Requires AutoHotkey v2.0

class DemonJitter {
    __New(capacity := 256) {
        cap := Max(8, Integer(capacity))
        this.cap := cap
        this.buf := []         ; ring storage (floats)
        this.buf.Length := cap ; pre-size
        this.idx := 1
        this._count := 0
    }

    Clear() {
        this.idx := 1
        this._count := 0
    }

    Add(ms) {
        v := ms + 0.0
        if (v < 0)
            v := 0.0

        this.buf[this.idx] := v
        this.idx += 1
        if (this.idx > this.cap)
            this.idx := 1

        if (this._count < this.cap)
            this._count += 1

        return v
    }

    Count() => this._count
    Capacity() => this.cap

    ; Returns Map with:
    ; count, min, max, mean, p50, p95, p99
    ; Percentiles use "nearest-rank" method: rank = Ceil(p/100*n)
    GetStats() {
        n := this._count
        if (n <= 0) {
            return Map(
                "count", 0,
                "min", 0.0,
                "max", 0.0,
                "mean", 0.0,
                "p50", 0.0,
                "p95", 0.0,
                "p99", 0.0
            )
        }

        arr := this._Snapshot()       ; copy current samples
        DemonJitter._Sort(arr)        ; numeric sort ascending

        minVal := arr[1]
        maxVal := arr[n]

        sum := 0.0
        for _, v in arr
            sum += v
        meanVal := sum / n

        p50 := DemonJitter._PercentileNearestRank(arr, 50)
        p95 := DemonJitter._PercentileNearestRank(arr, 95)
        p99 := DemonJitter._PercentileNearestRank(arr, 99)

        return Map(
            "count", n,
            "min", minVal,
            "max", maxVal,
            "mean", meanVal,
            "p50", p50,
            "p95", p95,
            "p99", p99
        )
    }

    ; --- Optional helper: "trip" watcher for p95 threshold ---
    ; Tracks consecutive threshold breaches with decay.
    ; Returns Map("p95", <float>, "trips", <int>, "triggered", <bool>)
    WatchP95(thresholdMs, tripLimit := 2, decayOnOk := 1) {
        if !this.HasOwnProp("_trips")
            this._trips := 0

        st := this.GetStats()
        p95 := st["p95"]

        if (p95 > (thresholdMs + 0.0)) {
            this._trips += 1
        } else {
            ; decay trips on ok
            this._trips := Max(0, this._trips - Max(0, Integer(decayOnOk)))
        }

        trig := (this._trips >= Integer(tripLimit))

        return Map("p95", p95, "trips", this._trips, "triggered", trig)
    }

    ResetTrips() {
        this._trips := 0
    }

    ; Debug/export hook: returns samples in chronological order (oldest -> newest).
    ; Allocates a new Array; do not call in hot loops.
    Snapshot() => this._Snapshot()

    ; ---------------- internals ----------------

    _Snapshot() {
        n := this._count
        out := []
        out.Length := n

        ; ring contains valid values in 1..count, but may wrap.
        ; simplest: read sequentially from ring oldest->newest:
        ; oldest index = idx if buffer full, else 1
        if (n < this.cap) {
            ; not full, values are in 1..n in insert order
            Loop n
                out[A_Index] := this.buf[A_Index] + 0.0
            return out
        }

        ; full: idx points to next write position (oldest element)
        start := this.idx
        Loop n {
            j := start + (A_Index - 1)
            if (j > this.cap)
                j -= this.cap
            out[A_Index] := this.buf[j] + 0.0
        }
        return out
    }

    static _PercentileNearestRank(sortedArr, p) {
        n := sortedArr.Length
        if (n <= 0)
            return 0.0
        pct := p + 0.0
        if (pct <= 0)
            return sortedArr[1]
        if (pct >= 100)
            return sortedArr[n]

        rank := Ceil((pct / 100.0) * n) ; 1..n
        rank := Max(1, Min(n, rank))
        return sortedArr[rank] + 0.0
    }

    ; In-place numeric quicksort
    static _Sort(arr) {
        if arr.Length <= 1
            return
        DemonJitter._QSort(arr, 1, arr.Length)
    }

    static _QSort(arr, lo, hi) {
        i := lo
        j := hi
        pivot := arr[(lo + hi) // 2]

        while (i <= j) {
            while (arr[i] < pivot)
                i += 1
            while (arr[j] > pivot)
                j -= 1
            if (i <= j) {
                tmp := arr[i]
                arr[i] := arr[j]
                arr[j] := tmp
                i += 1
                j -= 1
            }
        }
        if (lo < j)
            DemonJitter._QSort(arr, lo, j)
        if (i < hi)
            DemonJitter._QSort(arr, i, hi)
    }
}
