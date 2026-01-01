# DemonQuantumBuffer Overview

Implements a "superposition → collapse" gate:
- q = q * decay^factor + gain * magnitude + noise
- If q ≥ threshold: collapse → pass sample and reset q

Pure math; caller decides how to use `allow/collapsed`.
