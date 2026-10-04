# Controller and Input (Armada on Thor)
> Scope: Input mapping from hardware to user space · Researched: 2026-10-03 · Confidence: high

The AYN Thor utilizes a central MCU to handle most inputs (joysticks, buttons, gyro), alongside direct GPIO buttons.

## Hardware Endpoints
1. **AYN Odin2 Gamepad (`rsinput-gamepad`)**:
   - `VID: 2020`, `PID: 3001`.
   - Exposed on the kernel level via the `rsinput` driver (likely a retro-serial/i2c internal bus).
   - Handles the analog sticks, d-pad, and face buttons.
2. **`gpio-keys-ayn`**:
   - Exposed directly via GPIO.
   - Handles the extra buttons like the `AYN` button, and the macro keys (`M1`/`M2`).
3. **Touchscreens (`focaltech,ft5426` / `ft5452`)**:
   - The top and bottom displays have dedicated FocalTech touch controllers.

## InputPlumber Abstraction
Armada relies on `InputPlumber` (a system service originally from the ChimeraOS/Bazzite ecosystem) to unify and map these hardware devices into virtual controllers.

**Configuration (`/usr/share/inputplumber/devices/50-ayn_thor.yaml`)**:
- Defines a `CompositeDevice` named "AYN Thor".
- Matches the device tree string `compatible: ayn,thor`.
- Consumes both `rsinput-gamepad` and `gpio-keys-ayn` and merges them.
- Emits a virtual `xbox-elite` controller event node (by default), which ensures 100% compatibility with Steam and Proton.

Because the `AYN` button is mapped directly through `InputPlumber`, community tools like `barry-launcher` use `InputPlumber` configuration overrides (in `/etc/inputplumber/devices.d/`) to release or remap the `AYN` button for their own uses.
