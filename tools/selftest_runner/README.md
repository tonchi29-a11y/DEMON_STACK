# Selftest runner (interactive)

Runs `examples/demo_selftest.ahk` across all libraries under `DEMON_STACK/` and writes a Markdown report.

## Screenshot
![Selftest runner](./run_all_selftests.png)

## Run
- `tools/selftest_runner/run_all_selftests.ahk`

## Output
- `reports/selftest_report.md`

## Notes
- v1 is interactive: many selftests show `MsgBox`, so you may need to click OK for each.
- The report records exit code + duration, but PASS/FAIL becomes fully automatable once selftests avoid UI and use `ExitApp(0/1)`.
