# DemonChaos Overview

Integrates a Lorenz-like system with an external `drive`. Produces:
- `score`: magnitude of the state vector
- `triggered`: threshold crossing (with cooldown)
- `bias`: normalized excess and a cooldown floor

Use bias as an additive knob for prediction; use triggered to request short boosts.
