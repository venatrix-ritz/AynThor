# Controller and Input (Armada on Thor)
> Scope: how the Thor's buttons, sticks and touch reach user space · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high where tagged. Removed: "M1/M2 macro keys on gpio-keys-ayn", "gyro on the MCU", and the claim that InputPlumber comes from the ChimeraOS/Bazzite ecosystem (none are in the sources).

## Hardware endpoints (from the device tree)
- **Gamepad MCU:** a node `compatible = "gamepad,rsinput"` named `AYN Odin2 Gamepad` (bus `0x0003`, VID `0x2020`, PID `0x3001`, rev 1), powered from `vreg_bob2` and enabled by TLMM GPIO 12. Armada builds the driver as a module (`CONFIG_JOYSTICK_RSINPUT=m`) from the ROCKNIX `RSInput` patch. [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi#L1701-L1713; refs/upstream/armada@574da80:packages/kernel/config/armada-kernel.config.overrides#L127; refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L204-L206]
- **AYN key:** `gpio-keys-ayn` with one key, label "AYN Key", TLMM GPIO 41, `KEY_F24`. [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L16-L28]
- **Lid:** `gpio-keys-lid` "Hall Lid Sensor", `SW_LID`. [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L31-L38]
- **Volume keys and others:** a shared `gpio-keys` node in the common AYN dtsi (e.g. "Volume Up"). [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi#L42-L51]
- **Touch:** FocalTech `ft5426` and `ft5452` on the two panels (labels `top_touchscreen`, `bottom_touchscreen`). [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L259, #L281, #L377]

## InputPlumber
- Armada packages [ShadowBlip/InputPlumber](https://github.com/ShadowBlip/InputPlumber) pinned at version `0.79.0` (commit `1822d1e`), with Armada's patches (including one adding the Thor Lite). [src: refs/upstream/armada@574da80:packages/inputplumber/BASE.env#L1-L2; refs/upstream/armada@574da80:packages/inputplumber/patches/0004-feat-Hardware-Support-Add-AYN-Thor-Lite.patch]
- The Thor profile in InputPlumber (read from the upstream clone at `main`, `ea60d87`; Armada pins an earlier version) is `devices/50-ayn_thor.yaml`: a `CompositeDevice` named "AYN Thor", matched on devicetree `compatible: ayn,thor`, merging the evdev `AYN Odin2 Gamepad` (`rsinput-gamepad/input0`, VID 2020 / PID 3001) and `gpio-keys-ayn` through capability map `ayn2`, and emitting an `xbox-elite` target device. [src: refs/upstream/inputplumber@ea60d87:rootfs/usr/share/inputplumber/devices/50-ayn_thor.yaml#L1-L34]
- Armada ships a helper `inputplumber-intercept` that sets the composite device's `InterceptMode` over D-Bus: `overlay` (2), `gamepad` (3), `reset` (0). [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/inputplumber-intercept#L1-L25]
- Barry Launcher takes the AYN button by installing an InputPlumber override (Thor only) plus a udev rule; reboot afterwards to return it. [src: refs/community/barry-launcher@13ab555:README.md#L105-L108, #L136-L137]
- Armada also ships a Waydroid keylayout for the same VID/PID (`Vendor_2020_Product_3001.kl`) and a service that shares InputPlumber controllers with Waydroid. [src: refs/upstream/armada@574da80:system_files/usr/share/armada/waydroid/keylayout/Vendor_2020_Product_3001.kl]

## Sources
- [S1] refs/upstream/armada@574da80 (dts, kernel config, PATCHES.md, inputplumber package, inputplumber-intercept)
- [S2] refs/upstream/inputplumber@ea60d87
- [S3] refs/community/barry-launcher@13ab555:README.md
