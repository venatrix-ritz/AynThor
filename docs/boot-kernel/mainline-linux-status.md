# Mainline Linux Status (Armada OS)
> Scope: Mainlining progress of Qualcomm Handhelds · Researched: 2026-10-04 · Confidence: high

Armada runs a relatively recent Linux kernel (typically 6.x), heavily patched for Qualcomm Snapdragon support. 

## Current Status
While the core Qualcomm SM8250 and SM8550 SoCs enjoy robust mainline Linux support (thanks to efforts by Linaro and the community), the handheld-specific peripherals are largely out-of-tree.
Armada maintains a custom kernel package containing dozens of out-of-tree patches.

## Key Out-of-Tree Components
1. **Displays**: The OLED panels (Chipone ICNA3520, CH13726A, Visionox) require custom initialization sequences and power domains that are not yet accepted upstream.
2. **Audio**: The Awinic AW88166 SmartPA and specialized q6afe/q6asm DSP routing quirks remain out-of-tree to handle the specific headphone jack switching and dual-speaker setups.
3. **Input**: The sinput gamepad drivers and custom FocalTech touch drivers (FT5426/FT5452) are patched in manually.
4. **Battery/Power**: Charge limiting via qcom_battmgr and specific s2idle power cut hacks are carried as patches to fix suspend battery drain.

The ROCKNIX and Armada communities often collaborate to upstream these drivers, but for now, Armada must build its own kernel (efs/upstream/armada/packages/kernel/) rather than using standard Fedora kernels.
