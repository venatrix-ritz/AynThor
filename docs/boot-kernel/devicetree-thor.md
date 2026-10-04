# AYN Thor devicetree
> Scope: what `qcs8550-ayn-thor.dts` declares (hardware inventory) and how Armada patches it · Researched: 2026-10-03 · Confidence: high for DT contents; behaviour/driver status not verified on hardware

Files: `refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts` (469 lines) + `qcs8550-ayn-common.dtsi` (shared AYN base) + Armada's delta `qcs8550-ayn-thor.dts.patch`. The Armada base copies are **byte-identical** to ROCKNIX's `projects/ROCKNIX/devices/SM8550/linux/dts/qcom/` copies at the cloned SHAs (`diff -q`: IDENTICAL for the Thor dts and common dtsi). [src: refs/upstream/rocknix@9f8c79dc12:projects/ROCKNIX/devices/SM8550/linux/dts/qcom/qcs8550-ayn-thor.dts]

## Identity
- `model = "AYN Thor"`, `compatible = "ayn,thor", "qcom,qcs8550", "qcom,sm8550"`, `qcom,msm-id = <603 0x20000>`, `qcom,board-id = <0x1001f 0>`. So upstream calls the SoC **QCS8550** (the Armada docs say SM8550 — same die family, different marketing label). [src: packages/kernel/dts/qcs8550-ayn-thor.dts#L10-L14]
- License header on the ROCKNIX copy: BSD-3-Clause, "Copyright (c) 2025, Teguh Sobirin". [src: refs/upstream/rocknix@9f8c79dc12:projects/ROCKNIX/devices/SM8550/linux/dts/qcom/qcs8550-ayn-thor.dts#L1-L3]

## Displays (two DSI links)
| Role (per Armada device conf) | DT location | Panel compatible | Touch | Size |
|---|---|---|---|---|
| **Top** (DSI-2, primary) | `&mdss_dsi1` → `display_panel: panel@0` in `qcs8550-ayn-common.dtsi#L1066-L1086`; Thor overrides it | `chipone,icna3520` (reset GPIO 137, `rotation = <90>`) | `focaltech,ft5426` @0x38 on `&i2c4`, label `top_touchscreen` | 1080×1920 |
| **Bottom** (DSI-1, secondary) | `&mdss_dsi0` → `panel@0` | `ch13726a,thor` (reset GPIO 133, `rotation = <90>`, 4 data lanes) | `focaltech,ft5452` @0x38 on `&i2c_hub_3`, label `bottom_touchscreen` | 1080×1240 |
[src: packages/kernel/dts/qcs8550-ayn-thor.dts#L167-L183, #L258-L281, #L376-L399, #L405-L437] [src: system_files/usr/lib/armada/devices/ayn-thor.conf (DSI-2 top / DSI-1 bottom)]
- The DT's pin names call the `mdss_dsi0` link "primary" (`dsi_p_*`) and the `mdss_dsi1` link "secondary" (`dsi_s_*`); Armada's conf maps the **top** screen to `mdss_dsi1`. The naming is therefore DT-internal, not top/bottom. [src: packages/kernel/dts/qcs8550-ayn-thor.dts#L170-L172, #L412-L414]
- Panel resolutions match the commonly quoted specs (6" 1080×1920; 3.92" 1080×1240) — see [specs](../hardware/specs.md) if present.

## Input, LEDs, sensors
- `gpio-keys-ayn`: "AYN Key" on tlmm GPIO 41, `KEY_F24`. `gpio-keys-lid`: "Hall Lid Sensor" on GPIO 17, `SW_LID`, `wakeup-source` — the clamshell lid switch. [src: packages/kernel/dts/qcs8550-ayn-thor.dts#L17-L41]
- Two **Heroic HTR3212** LED controllers (`&i2c0` @0x3c, `&i2c12`) feeding eight `leds-group-multicolor` groups (labels like `l:r1`) — the stick RGB rings. [src: packages/kernel/dts/qcs8550-ayn-thor.dts#L111-L165, #L185-L190, #L285-L290]
- Fixed regulators for backlight 5 V (`vdd_bl_5v0`, GPIO 52), display 1.8 V, 2.8 V rails etc.; audio: sound model `"AYN-Thor"`, WCD938x codec routing, left/right speaker amps (`&spk_amp_l/r`), ADSP remoteproc enabled. [src: packages/kernel/dts/qcs8550-ayn-thor.dts#L45-L108, #L357-L370, #L457-L469]

## What Armada changes (`qcs8550-ayn-thor.dts.patch`, "hall wake, touch orientation, DPU dithering")
1. Hall lid sensor: adds a pull-up pinctrl (`hall_lid_n`, GPIO 17) because the open-drain output level is undefined when released, and `wakeup-event-action = <EV_ACT_DEASSERTED>` so opening the lid wakes the device.
2. Touch: removes `touchscreen-swapped-x-y` and `touchscreen-inverted-x` from both touchscreens (orientation now handled elsewhere in the stack).
3. Top panel: adds `armada,dpu-8bpc-dither` — "8bpc DSI link; dither the DPU 10-bit downconvert to hide banding" (a custom property implemented by Armada's kernel patches).
[src: packages/kernel/dts/qcs8550-ayn-thor.dts.patch#L1-L74]

## ROCKNIX history of the Thor dts
Recent ROCKNIX commits touching the file: AYN-key button registration (2026-04-10), Thor audio support (2026-05-09), touchscreen fix for gamescope/Steam (2026-05-18), lid split into its own input device (2026-06-18), volume-up fix by splitting the AYN key into a separate gpio-keys node (2026-06-29). [src: `git -C refs/upstream/rocknix log -- …/qcs8550-ayn-thor.dts`]

## Open questions
- Which panel vendor/driver patches (ICNA3520, CH13726A) exist in Armada's kernel patches and in mainline? → see kernel-patches-sm8550 (not written yet) (not yet researched) [UNVERIFIED].
- Thor Lite (SM8250) DT: `sm8250-ayn-thorlite.dts` exists in both trees; not analysed yet.

## Sources
- [S1] refs/upstream/armada@574da80:packages/kernel/dts/{qcs8550-ayn-thor.dts, qcs8550-ayn-thor.dts.patch, qcs8550-ayn-common.dtsi}
- [S2] refs/upstream/rocknix@9f8c79dc12:projects/ROCKNIX/devices/SM8550/linux/dts/qcom/ and its `git log`
