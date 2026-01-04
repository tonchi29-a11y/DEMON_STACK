# DemonAtomicFile — API

## `class DemonAtomicFile`

### `static WriteTextAtomic(path, text, encoding := "UTF-8")`
Writes `text` to `path` using a temp file in the same directory, then replaces the target.

- `path`: destination file path
- `text`: any value; converted to string via `text ""`
- `encoding`: passed to `FileOpen()` and `FileRead()` (e.g. `"UTF-8"`, `"UTF-8-RAW"`)

Returns `true` on success; throws on failure.

### Internals
- `_DirOf(path)` returns the directory portion.
- `_TmpPath(path)` builds a unique temp path in the same directory.
