# Teardown and Internal Hardware
> Scope: what is known about the Thor's internals and charging · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: low for the physical teardown (no source found), medium for specs. The earlier version described the cooling assembly, hinge ribbon cables and haptic brackets as if from a teardown; no teardown source exists in `refs/` or turned up in search, so those lines were removed.

## Regulatory ID — unverified
An earlier version gave the FCC ID as `2BDXN-BASE` ("alternatively `2BDW-BASE`"). `[UNVERIFIED]`: fccid.io returned HTTP 403 and a web search found no FCC filing for the Thor on 2026-10-07. Check the FCC Equipment Authorization database directly before relying on it.

## Battery and charging (secondary sources)
- 6000 mAh battery on every model, with "27W charging" in AYN's published spec sheet as reproduced by RetroHandhelds. [src: https://retrohandhelds.gg/?p=25568 — via search summary, secondary]
- All Thor models share the 6,000 mAh capacity and a USB 3.1 Type-C port. [src: https://liliputing.com/?p=184654 — via search summary, secondary]
- No charger is included, only the cable; reviewers say reputable USB-PD chargers that meet the requested profile work. [src: https://techtactician.com/ayn-thor-hands-on-impressions-and-tests/ — via search summary, secondary]
- Size and weight: 150 × 94 × 25.6 mm, about 380 g. [src: https://www.notebookcheck-ru.com/AYN-Thor-Novyi-konkurent-Ayaneo-Pocket-DS-vykhodit-v-prodazhu-po-vsemu-miru-po-cene-ot-249.1097226.0.html — via search summary, secondary]
- On the device the battery reports the model string `…QUECTEL_SA885G…6000MAH…` and `constant_charge_current` 9000000 µA. [observed 2026-10-07: docs/hardware/device-observed.md]

## Cooling and heat
- The Thor has a fan: on the surveyed unit a fan hwmon was readable at about 2044 RPM. [observed 2026-10-03/04: docs/hardware/device-observed.md]
- While charging, `armada-powerd` can hold a minimum fan PWM (`charging_pwm`, default 0). [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-powerd#L835-L837] See `docs/armada/sleep-battery.md`.
- The 80 % charge cap question is covered in `docs/armada/sleep-battery.md` and `tweaks/README.md`.

## Panels and ICs
Display panel ICs (Chipone ICNA3520 top, CH13726A bottom) and the touch controllers come from the device tree, not a teardown. [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L168, #L411, #L259, #L377] A component-level list is in `docs/hardware/components.md` (partly verified).

## Not found anywhere
Disassembly steps, cooling-assembly layout, hinge cabling and haptics mounting: `[UNVERIFIED]`, add a source before restoring any of it.

## Sources
- [S1] retrohandhelds.gg, liliputing.com, techtactician.com, notebookcheck-ru.com (secondary, via web search 2026-10-07)
- [S2] refs/upstream/armada@574da80 (armada-powerd, qcs8550-ayn-thor.dts)
- [S3] docs/hardware/device-observed.md
