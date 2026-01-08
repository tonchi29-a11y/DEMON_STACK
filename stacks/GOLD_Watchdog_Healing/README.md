# GOLD_Watchdog_Healing

Opinionated “recipe” showing how the base libraries combine:

## Screenshot
![GOLD_Watchdog_Healing](./gold_healing.png)

- DemonTime (QPC timing)
- DemonWatchdog (stall detection + degraded-mode signal)
- DemonLog (persistent logging + SmartLog rate limiting)

## What it demonstrates
- Detect a real stall (timer starvation)
- Enter degraded mode (widen timers / reduce work)
- Exit degraded mode automatically on recovery
- Persist diagnostics to a log file in `A_Temp`

## Run
- `gold_healing.ahk`

Log output:
- `%TEMP%\gold_healing.log`
