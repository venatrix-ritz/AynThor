# Teardown and Internal Hardware
> Scope: Physical internal construction and FCC filing details · Researched: 2026-10-04 · Confidence: high

## Regulatory and FCC Details
The AYN Thor is registered under the FCC ID **2BDXN-BASE** (with alternative manual references to 2BDW-BASE). The FCC documentation and community teardown videos provide a clear look at the internal assembly.

## Disassembly and Internals
Because the Thor is a dual-screen clamshell device, its internal construction is more complex than standard slab handhelds like the Odin 2.
- **Cooling Assembly**: Opening the bottom shell requires removing standard screws. Inside, the active cooling fan and a copper heat pipe assembly sit above the main motherboard. Removing the fan is often required for deep cleaning or replacement.
- **Ribbon Cables**: The hinge houses delicate ribbon cables connecting the top OLED panel (Chipone ICNA3520) and top components to the mainboard in the bottom half. Care must be taken during teardowns not to stress these cables.
- **Vibration Motors**: The haptics are secured via brackets in the bottom shell grips.

## Battery and Charging
- **Capacity**: The internal battery requires significant thermal management.
- **Charging Protocol**: The device supports a maximum of **27W** fast charging via USB-C PD.
- **Heat Management**: During 27W fast charging, the device can become quite warm. The Android firmware and Armada's rmada-powerd both include mechanisms to manage this, such as spinning up the fan while charging or allowing software limits (like 80% maximum charge) to protect battery longevity.
