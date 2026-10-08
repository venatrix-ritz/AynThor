# Device Tree: AYN Thor Lite
> Scope: Hardware definition for the Thor Lite (`sm8250-ayn-thorlite.dts`) · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: high for the facts below, all read from the Armada source at `574da80`

The **AYN Thor Lite** is the SM8250 (Snapdragon 865) sibling of the Thor. Armada carries its own device tree for it. [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L19-L20]

## Facts from `sm8250-ayn-thorlite.dts`
- **Identity:** `model = "AYN Thor Lite"`, `compatible = "ayn,thor-lite", "qcom,sm8250"`. [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L19-L20]
- **Battery:** `simple-battery`, `charge-full-design-microamp-hours = <3850000>` (3850 mAh), 3.6 V to 4.4 V design voltage. [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L30-L34]
- **Fan:** `pwm-fan` with five steps, `cooling-levels = <0 32 64 128 255>`, driven from the PM8150L PWM (`pwms = <&pm8150l_lpg 4 40000>`). [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L41-L46]
- **Displays:** the same panel drivers as the Thor: `chipone,icna3520` (`panel@0`) and `ch13726a,thor`. [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L978-L980, #L1017-L1019] Thor for comparison. [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L168, #L411]
- **Touch:** FocalTech `ft5452` and `ft5426`, the same two parts the Thor uses. [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L721-L722, #L935-L936; refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L258-L259, #L376-L377]
- **LEDs:** eight `leds-group-multicolor` nodes, the same grouping scheme seen on the Thor (see `docs/hardware/device-observed.md`). [src: refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts#L79-L128]
- **Audio:** the SM8250 audio backends are fixed to S16_LE by the kernel's `sm8250_be_hw_params_fixup()`, so Armada ships a WirePlumber drop-in `51-ayn-thor-lite.conf` (scoped to the card `AYN Thor Lite`) that forces S16LE; rate 48000 and 2 channels come from the ALSA UCM config. [src: refs/upstream/armada@574da80:system_files/usr/share/wireplumber/wireplumber.conf.d/51-ayn-thor-lite.conf#L1-L22]
- **Armada device profile:** `ARMADA_DEVICE_ID=ayn-thor-lite`, `ARMADA_SOC_CLASS=SM8250`; top panel is DSI-1 and bottom DSI-2 (the reverse of the Thor), and Gamescope drives only the top panel. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor-lite.conf#L1-L11]

## Correction (2026-10-07)
An earlier version of this page said the Thor Lite uses "different driver stacks (e.g. t5x06)" for touch and display than the Thor. The device trees show the same panels and the same FocalTech parts on both. Armada's device table lists the Thor Lite as "Untested". [src: refs/upstream/armadaos.dev@26dcfc3:docs/devices/ayn/index.md#L9]

## Sources
- [S1] refs/upstream/armada@574da80:packages/kernel/dts/sm8250-ayn-thorlite.dts
- [S2] refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts
- [S3] refs/upstream/armada@574da80:system_files/usr/share/wireplumber/wireplumber.conf.d/51-ayn-thor-lite.conf
- [S4] refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor-lite.conf
