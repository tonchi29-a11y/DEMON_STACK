#Requires AutoHotkey v2.0

class DemonSpscRing {
    __New(capacity := 1024) {
        cap := this._NextPow2(Max(2, Integer(capacity)))
        this.cap := cap
        this.mask := cap - 1
        this.head := 0
        this.tail := 0
        this.drops := 0

        ; Item = float dx (4) + float dy (4) + int64 t (8) = 16 bytes
        this.itemSize := 16
        this.buf := Buffer(cap * this.itemSize, 0)
    }

    Clear() {
        this.head := 0
        this.tail := 0
        this.drops := 0
        ; buffer contents not cleared (not needed)
    }

    Push(dx, dy, t64) {
        h := this.head
        t := this.tail
        if (h - t) >= this.cap {
            this.drops += 1
            return false
        }

        idx := (h & this.mask) * this.itemSize
        NumPut("Float", dx, this.buf, idx)
        NumPut("Float", dy, this.buf, idx + 4)
        NumPut("Int64", t64, this.buf, idx + 8)

        this.head := h + 1
        return true
    }

    Pop(&dx, &dy, &t64) {
        t := this.tail
        h := this.head
        if t = h
            return false

        idx := (t & this.mask) * this.itemSize
        dx := NumGet(this.buf, idx, "Float")
        dy := NumGet(this.buf, idx + 4, "Float")
        t64 := NumGet(this.buf, idx + 8, "Int64")

        this.tail := t + 1
        return true
    }

    Fill() => this.head - this.tail

    GetHealth() {
        return Map(
            "fill", this.head - this.tail,
            "cap", this.cap,
            "drops", this.drops
        )
    }

    _NextPow2(n) {
        n := Integer(n)
        p := 1
        while p < n
            p <<= 1
        return p
    }
}
