#Requires AutoHotkey v2.0

class DemonBridge {
    static _barInited := false
    static _barFn := ""

    __New(name := "Local\DemonBridge", payloadSize := 64, slots := 3, crcEnabled := true) {
        if payloadSize != 64
            throw Error("payloadSize must be 64 for DemonBridge v1")
        if slots < 2
            throw Error("slots must be >= 2")

        this._name := name
        this._payloadSize := Integer(payloadSize)
        this._slots := Integer(slots)
        this._crcEnabled := !!crcEnabled

        ; "Elite" layout:
        ; - 64-byte header (one cache line)
        ; - slot content is 80 bytes: seq(8) + payload(64) + crc32(4) + pad(4)
        ; - slot stride is 128 bytes (pad to reduce false sharing)
        this._headerSize := 64
        this._slotContentSize := 8 + this._payloadSize + 8
        this._slotStride := 128
        if this._slotContentSize > this._slotStride
            throw Error("slotContentSize must be <= slotStride")

        this._mapSize := this._headerSize + (this._slots * this._slotStride)

        this._hMap := 0
        this._pView := 0

        ; Stats
        this._writeCount := 0
        this._readOk := 0
        this._readRetries := 0
        this._crcFails := 0

        this._OpenOrCreate()
        this._InitIfNew()
    }

    Close() {
        if this._pView {
            DllCall("kernel32.dll\UnmapViewOfFile", "Ptr", this._pView, "Int")
            this._pView := 0
        }
        if this._hMap {
            DllCall("kernel32.dll\CloseHandle", "Ptr", this._hMap, "Int")
            this._hMap := 0
        }
    }

    __Delete() {
        try {
            this.Close()
        } catch {
        }
    }

    ; Writer: write a payload Buffer (must be exactly payloadSize bytes)
    Write(payloadBuf) {
        if !(payloadBuf is Buffer)
            throw TypeError("payloadBuf must be a Buffer")
        if payloadBuf.Size != this._payloadSize
            throw Error("payloadBuf.Size must be " this._payloadSize)

        ; Choose next slot (single-writer assumption)
        hdr := this._ReadHeader()
        wc := hdr.writeCounter + 1
        slot := Mod(wc - 1, this._slots)

        slotOff := this._headerSize + (slot * this._slotStride)
        seqOff := slotOff
        payOff := slotOff + 8
        crcOff := payOff + this._payloadSize

        seq := NumGet(this._pView, seqOff, "UInt64")

        ; seqlock: odd = writing
        NumPut("UInt64", seq + 1, this._pView, seqOff)

        ; copy payload
        DllCall("kernel32.dll\RtlMoveMemory", "Ptr", this._pView + payOff, "Ptr", payloadBuf.Ptr, "UPtr", this._payloadSize)

        crc := this._crcEnabled ? DemonBridge.Crc32(payloadBuf) : 0
        NumPut("UInt", crc, this._pView, crcOff)

        ; memory barrier to reduce reorder surprises across cores
        DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")

        ; seqlock: even = done
        NumPut("UInt64", seq + 2, this._pView, seqOff)

        DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")

        ; publish header (with header seqlock)
        this._WriteHeader(wc, slot)

        this._writeCount += 1
        return true
    }

    ; Reader: reads latest payload into outBuf (must be payloadSize).
    ; Returns true if a consistent payload was read.
    ReadLatest(&outBuf, retries := 8) {
        if !(outBuf is Buffer) || outBuf.Size != this._payloadSize
            outBuf := Buffer(this._payloadSize, 0)

        loop retries {
            hdr := this._ReadHeader()
            slot := hdr.lastSlot
            if slot < 0 || slot >= this._slots {
                this._readRetries += 1
                continue
            }

            slotOff := this._headerSize + (slot * this._slotStride)
            seqOff := slotOff
            payOff := slotOff + 8
            crcOff := payOff + this._payloadSize

            seq1 := NumGet(this._pView, seqOff, "UInt64")
            if (seq1 & 1) {
                ; odd = writer in progress
                this._readRetries += 1
                continue
            }

            ; copy payload out
            DllCall("kernel32.dll\RtlMoveMemory", "Ptr", outBuf.Ptr, "Ptr", this._pView + payOff, "UPtr", this._payloadSize)
            crcRead := NumGet(this._pView, crcOff, "UInt")

            DemonBridge._ReadBarrier()
            seq2 := NumGet(this._pView, seqOff, "UInt64")
            if (seq1 != seq2) || (seq2 & 1) {
                this._readRetries += 1
                continue
            }

            if this._crcEnabled {
                crcCalc := DemonBridge.Crc32(outBuf)
                if (crcCalc != crcRead) {
                    this._crcFails += 1
                    this._readRetries += 1
                    continue
                }
            }

            this._readOk += 1
            return true
        }

        return false
    }

    GetState() {
        return Map(
            "name", this._name,
            "payloadSize", this._payloadSize,
            "slots", this._slots,
            "writeCount", this._writeCount,
            "readOk", this._readOk,
            "readRetries", this._readRetries,
            "crcFails", this._crcFails
        )
    }

    ; ---------------- internals ----------------

    static _ReadBarrier() {
        static dummy := Buffer(4, 0)

        if !DemonBridge._barInited {
            DemonBridge._barInited := true
            DemonBridge._barFn := DemonBridge._PickBarrierFn(dummy)
        }

        if (DemonBridge._barFn != "") {
            DllCall(DemonBridge._barFn, "Ptr", dummy.Ptr, "Int", 0, "Int")
            return
        }

        ; slow fallback but always available
        DllCall("kernel32.dll\FlushProcessWriteBuffers")
    }

    static _PickBarrierFn(dummy) {
        candidates := [
            "KernelBase.dll\InterlockedExchangeAdd",
            "kernel32.dll\InterlockedExchangeAdd",
            "ntdll.dll\RtlInterlockedExchangeAdd"
        ]
        for _, fn in candidates {
            try {
                DllCall(fn, "Ptr", dummy.Ptr, "Int", 0, "Int")
                return fn
            } catch {
            }
        }
        return ""
    }

    _OpenOrCreate() {
        FILE_MAP_ALL_ACCESS := 0xF001F
        PAGE_READWRITE := 0x04
        INVALID_HANDLE_VALUE := -1

        hMap := DllCall("kernel32.dll\OpenFileMappingW", "UInt", FILE_MAP_ALL_ACCESS, "Int", 0, "WStr", this._name, "Ptr")
        if !hMap {
            hMap := DllCall(
            "kernel32.dll\CreateFileMappingW"
                , "Ptr", INVALID_HANDLE_VALUE
                , "Ptr", 0
                , "UInt", PAGE_READWRITE
                , "UInt", 0
                , "UInt", this._mapSize
                , "WStr", this._name
                , "Ptr"
            )
            if !hMap
                throw Error("CreateFileMapping failed. LastError=" A_LastError)
        }

        pView := DllCall("kernel32.dll\MapViewOfFile", "Ptr", hMap, "UInt", FILE_MAP_ALL_ACCESS, "UInt", 0, "UInt", 0, "UPtr", this._mapSize, "Ptr")
        if !pView {
            DllCall("kernel32.dll\CloseHandle", "Ptr", hMap, "Int")
            throw Error("MapViewOfFile failed. LastError=" A_LastError)
        }

        this._hMap := hMap
        this._pView := pView
    }

    _InitIfNew() {
        ; If header payloadSize mismatches, initialize header.
        hdr := this._ReadHeader(false)
        if (hdr.payloadSize != this._payloadSize) || (hdr.slots != this._slots) {
            ; zero memory
            DllCall("kernel32.dll\RtlZeroMemory", "Ptr", this._pView, "UPtr", this._mapSize)

            ; header publish
            this._WriteHeader(0, 0, true)

            ; init slot seq to 0
            loop this._slots {
                slot := A_Index - 1
                slotOff := this._headerSize + (slot * this._slotStride)
                NumPut("UInt64", 0, this._pView, slotOff)
            }
            DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")
        }
    }

    _ReadHeader(strict := true) {
        base := this._pView
        loop 8 {
            hseq1 := NumGet(base, 0, "UInt64")
            if strict && (hseq1 & 1) {
                continue
            }
            wc := NumGet(base, 8, "UInt64")
            lastSlot := NumGet(base, 16, "UInt")
            psz := NumGet(base, 20, "UInt")
            slots := NumGet(base, 24, "UInt")
            DemonBridge._ReadBarrier()
            hseq2 := NumGet(base, 0, "UInt64")
            if (hseq1 = hseq2) && (!(hseq2 & 1) || !strict) {
                return {writeCounter: wc, lastSlot: lastSlot, payloadSize: psz, slots: slots}
            }
        }
        return {writeCounter: 0, lastSlot: 0, payloadSize: 0, slots: 0}
    }

    _WriteHeader(writeCounter, lastSlot, force := false) {
        base := this._pView
        hseq := NumGet(base, 0, "UInt64")

        ; header seqlock
        NumPut("UInt64", hseq + 1, base, 0) ; odd
        NumPut("UInt64", writeCounter, base, 8)
        NumPut("UInt", lastSlot, base, 16)
        NumPut("UInt", this._payloadSize, base, 20)
        NumPut("UInt", this._slots, base, 24)
        NumPut("UInt", 0, base, 28)
        DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")
        NumPut("UInt64", hseq + 2, base, 0) ; even
        DllCall("kernel32.dll\FlushProcessWriteBuffers", "Int")
    }

    ; ---------------- CRC32 ----------------

    static Crc32(buf) {
        static table := DemonBridge._CrcTable()
        crc := 0xFFFFFFFF
        p := buf.Ptr
        sz := buf.Size
        Loop sz {
            b := NumGet(p, A_Index - 1, "UChar")
            crc := (crc >> 8) ^ table[((crc ^ b) & 0xFF) + 1]
        }
        return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF
    }

    static _CrcTable() {
        static t := ""
        if IsObject(t)
            return t
        t := []
        poly := 0xEDB88320
        Loop 256 {
            c := A_Index - 1
            Loop 8 {
                if (c & 1)
                    c := (c >> 1) ^ poly
                else
                    c >>= 1
            }
            t.Push(c & 0xFFFFFFFF)
        }
        return t
    }
}
