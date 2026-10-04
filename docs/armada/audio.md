# Audio Architecture (Armada OS)
> Scope: ALSA UCM2 configurations and Audio topology · Researched: 2026-10-03 · Confidence: high

Armada handles audio routing natively using standard Linux ALSA topologies and WirePlumber/PipeWire. Due to the complexity of Qualcomm SoCs (which use specialized DSPs and audio routers), the OS provides extensive Use Case Manager (UCM2) configurations.

## ALSA UCM2 Configs
The system_files/usr/share/alsa/ucm2 directory contains device-specific mappings that tell PipeWire how to route audio streams (PCM) to the correct hardware endpoints (I2S, SoundWire, MI2S).
- **Thor Implementation**: The AYN Thor has its own ALSA profile (AYN-Thor.conf / yn-AYNThor-.conf). This profile maps the internal Awinic AW88166 SmartPA amplifier (identified in hardware gaps) to the correct Linux audio sink.
- **Microphone**: It also routes the internal digital mic arrays to the capture sinks.
- **Headphone Jack**: The UCM2 profiles include Jack detection logic to automatically switch from the Awinic SmartPA to the headphone Codec when a 3.5mm plug is inserted.

## Audio Topology
Certain newer SoCs (like SM8750) require explicit .m4 topology definitions to build binary .tplg files that the kernel ALSA driver loads at boot. For the Thor (SM8550), standard UCM2 configs suffice alongside the w88399 / w88166 kernel drivers.

## Quirks
Some devices (like Thor Lite) have their backends hard-fixed to S16_LE / 48000 / 2ch by the kernel (sm8250_be_hw_params_fixup()), requiring WirePlumber overrides (51-ayn-thor-lite.conf) to match this exact format, preventing resampling artifacts or silence. The Thor (SM8550) is generally more flexible.
