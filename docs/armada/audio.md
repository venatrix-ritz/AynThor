# Audio Architecture (Armada OS)
> Scope: ALSA UCM2 configs and speaker amplifiers on the Thor · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high where tagged. The earlier version also named a second amplifier driver (`aw88399`) and described SM8550 topology handling without a source; those lines were removed.

Armada routes audio through ALSA UCM2 profiles and PipeWire/WirePlumber. The Thor has its own profile set.

## UCM2 profiles for the Thor
- Use-case files: `ucm2/AYN/Thor/AYN-Thor.conf` (declares the `HiFi` use case and a boot sequence of mixer defaults) and `ucm2/AYN/Thor/HiFi.conf`; the SM8550 card is matched through `ucm2/conf.d/sm8550/AYN-Thor.conf` and `ayn-AYNThor-.conf`. [src: refs/upstream/armada@574da80:system_files/usr/share/alsa/ucm2/AYN/Thor/AYN-Thor.conf#L1-L18; refs/upstream/armada@574da80:system_files/usr/share/alsa/ucm2/conf.d/sm8550/AYN-Thor.conf]
- `HiFi.conf` defines three devices: **Speaker**, **Headphones** (using the WCD938x and LPASS RX-macro enable/disable sequences) and an internal **Mic** routed through `SWR_MIC`. The headphone device sets `JackControl "Headphone Jack"` and `JackHWMute "Speaker"`, so the speaker is muted when a plug is detected. [src: refs/upstream/armada@574da80:system_files/usr/share/alsa/ucm2/AYN/Thor/HiFi.conf#L23-L57]
- On the Thor running Armada `20261006.9c7dd3e` PipeWire exposes `alsa_output.platform-sound.HiFi__Speaker__sink` and `...HiFi__Headphones__sink`. [observed 2026-10-07]

## Speaker amplifiers
The Thor's device tree describes two Awinic `aw88166` amplifiers on I2C (addresses `0x34` and `0x35`, sound prefixes `SPK_L` and `SPK_R`), with tuning firmware `qcom/sm8550/ayn/thor/aw883xx_acf.bin`. [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi#L985-L1001; refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L462-L469]

## Topology blobs
Armada's `audio_topology/` directory holds AudioReach `.m4` sources only for SM8750 (`SM8750-AYN.m4`, `SM8750-KONKR.m4`) and only the generated blobs under `usr/lib/firmware/qcom/sm8750/` are shipped. There is no SM8550 topology source in that directory. [src: refs/upstream/armada@574da80:audio_topology/README.md#L1-L11]

## Thor Lite quirk
On the Thor Lite (SM8250) the kernel fixes the audio backends to S16_LE, so Armada ships a WirePlumber rule for the card `AYN Thor Lite`. [src: refs/upstream/armada@574da80:system_files/usr/share/wireplumber/wireplumber.conf.d/51-ayn-thor-lite.conf#L8-L11] See `docs/boot-kernel/devicetree-thorlite.md`.

## Sources
- [S1] refs/upstream/armada@574da80 (paths above)
- [S2] On-device `pactl list short sinks`, 2026-10-07
