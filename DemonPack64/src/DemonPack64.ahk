#Requires AutoHotkey v2.0

class DemonPack64 {
    static SIZE := 64

    ; Offsets
    static OFF_TS    := 0   ; u64
    static OFF_FLAGS := 8   ; u32
    static OFF_ACCEL := 12  ; float[4]
    static OFF_SENS  := 28  ; float[4]
    static OFF_EMAX  := 44  ; float
    static OFF_EMAY  := 48  ; float
    static OFF_R0    := 52  ; u32
    static OFF_R1    := 56  ; u64

    static New() => Buffer(DemonPack64.SIZE, 0)

    static Zero(buf) {
        DemonPack64._Ensure(buf)
        DllCall("kernel32.dll\RtlZeroMemory", "Ptr", buf.Ptr, "UPtr", buf.Size)
    }

    ; Minimal pack: ts + flags + emaX/Y, everything else zero
    static PackBasic(buf, ts, flags, emaX, emaY) {
        DemonPack64._Ensure(buf)
        DemonPack64.Zero(buf)

        NumPut("UInt64", ts, buf, DemonPack64.OFF_TS)
        NumPut("UInt", flags, buf, DemonPack64.OFF_FLAGS)
        NumPut("Float", emaX + 0.0, buf, DemonPack64.OFF_EMAX)
        NumPut("Float", emaY + 0.0, buf, DemonPack64.OFF_EMAY)
        return buf
    }

    ; Full pack: ts + flags + accel[4] + sens[4] + emaX/Y
    ; accel/sens can be Arrays (Length>=4) or omitted (defaults to zeros).
    static PackFull(buf, ts, flags, emaX, emaY, accel?, sens?) {
        DemonPack64._Ensure(buf)
        DemonPack64.Zero(buf)

        NumPut("UInt64", ts, buf, DemonPack64.OFF_TS)
        NumPut("UInt", flags, buf, DemonPack64.OFF_FLAGS)

        if IsSet(accel)
            DemonPack64._PutF4(buf, DemonPack64.OFF_ACCEL, accel)
        if IsSet(sens)
            DemonPack64._PutF4(buf, DemonPack64.OFF_SENS, sens)

        NumPut("Float", emaX + 0.0, buf, DemonPack64.OFF_EMAX)
        NumPut("Float", emaY + 0.0, buf, DemonPack64.OFF_EMAY)
        return buf
    }

    static Unpack(buf) {
        DemonPack64._Ensure(buf)

        ts := NumGet(buf, DemonPack64.OFF_TS, "UInt64")
        flags := NumGet(buf, DemonPack64.OFF_FLAGS, "UInt")

        accel := [
            NumGet(buf, DemonPack64.OFF_ACCEL + 0, "Float"),
            NumGet(buf, DemonPack64.OFF_ACCEL + 4, "Float"),
            NumGet(buf, DemonPack64.OFF_ACCEL + 8, "Float"),
            NumGet(buf, DemonPack64.OFF_ACCEL + 12, "Float")
        ]

        sens := [
            NumGet(buf, DemonPack64.OFF_SENS + 0, "Float"),
            NumGet(buf, DemonPack64.OFF_SENS + 4, "Float"),
            NumGet(buf, DemonPack64.OFF_SENS + 8, "Float"),
            NumGet(buf, DemonPack64.OFF_SENS + 12, "Float")
        ]

        emaX := NumGet(buf, DemonPack64.OFF_EMAX, "Float")
        emaY := NumGet(buf, DemonPack64.OFF_EMAY, "Float")

        r0 := NumGet(buf, DemonPack64.OFF_R0, "UInt")
        r1 := NumGet(buf, DemonPack64.OFF_R1, "UInt64")

        return Map(
            "ts", ts,
            "flags", flags,
            "accel", accel,
            "sens", sens,
            "emaX", emaX,
            "emaY", emaY,
            "reserved0", r0,
            "reserved1", r1
        )
    }

    ; Fast path: unpack only what most pipelines need, no allocations.
    ; Returns values via ByRef to avoid Map/Array creation.
    static UnpackBasic(buf, &ts, &flags, &emaX, &emaY) {
        DemonPack64._Ensure(buf)
        ts := NumGet(buf, DemonPack64.OFF_TS, "UInt64")
        flags := NumGet(buf, DemonPack64.OFF_FLAGS, "UInt")
        emaX := NumGet(buf, DemonPack64.OFF_EMAX, "Float")
        emaY := NumGet(buf, DemonPack64.OFF_EMAY, "Float")
        return true
    }

    static ReadTs(buf) {
        DemonPack64._Ensure(buf)
        return NumGet(buf, DemonPack64.OFF_TS, "UInt64")
    }

    ; ---------- internals ----------
    static _Ensure(buf) {
        if !(buf is Buffer) || buf.Size != DemonPack64.SIZE
            throw Error("DemonPack64: Buffer(64) required")
    }

    static _PutF4(buf, off, arr) {
        NumPut("Float", DemonPack64._SafeIndex(arr, 1), buf, off + 0)
        NumPut("Float", DemonPack64._SafeIndex(arr, 2), buf, off + 4)
        NumPut("Float", DemonPack64._SafeIndex(arr, 3), buf, off + 8)
        NumPut("Float", DemonPack64._SafeIndex(arr, 4), buf, off + 12)
    }

    static _SafeIndex(arr, idx) {
        ; Works with Arrays, Maps, objects with [] access, etc.
        try {
            return arr[idx] + 0.0
        } catch {
            return 0.0
        }
    }
}
