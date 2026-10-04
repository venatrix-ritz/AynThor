# Device Tree: AYN Thor Lite
> Scope: Hardware definition for the Thor Lite (sm8250-ayn-thorlite.dts) · Researched: 2026-10-04 · Confidence: high

The **AYN Thor Lite** is a lower-tier sibling to the main Thor, powered by the older Qualcomm SM8250 (Snapdragon 865) SoC rather than the SM8550 (Snapdragon 8 Gen 2). Its hardware components are significantly different and require a dedicated Device Tree configuration in the Armada kernel.

## Hardware Findings (from sm8250-ayn-thorlite.dts)
- **SoC**: Qualcomm SM8250 (Snapdragon 865)
- **Battery**: Designed for 3850 mAh (charge-full-design-microamp-hours = <3850000>), operating between 3.6V and 4.4V.
- **Fan**: PWM-controlled active cooling fan with 5 speed steps (cooling-levels = <0 32 64 128 255>) driven by the pm8150l PMIC.
- **Touch & Display**: Uses different driver stacks (e.g., t5x06) compared to the main Thor's newer ICs.
- **Audio**: Audio backend hardware parameters are strictly hardcoded to S16_LE / 48000 / 2ch, necessitating the PipeWire 51-ayn-thor-lite.conf fixup documented in udio.md.
