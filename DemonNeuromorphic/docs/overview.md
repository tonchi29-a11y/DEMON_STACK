# DemonNeuromorphic Overview

Simplified spiking neuron layer to augment confidence or thresholds.
- Inputs: per-neuron intensities (e.g., velocity * confidence).
- Outputs: spike events and a bounded `boost` suitable for context/predict.

Pure AHK v2, no timers or I/O. Caller controls cadence (dtMs/nowMs).
