# AYN Thor — Exhaustive Component IC & Silicon Inventory

> **Audit 2026-10-07 — partly unverified.** Rows tagged `[src:]` or `[observed]` were not individually re-checked this audit; the sysfs/devicetree values and the ICs without a tag have no citation, and the device has since been reset, so `[observed]` rows cannot be re-run until the Thor is reachable again. Part-number and manufacturer entries that rest on datasheets, not on a linked source, are `[UNVERIFIED]`. See `docs/reference/open-questions.md`.

> Scope: Component-level IC bill of materials, package types, bus topologies, power rails, and kernel drivers, compiled from device queries, devicetree bindings and datasheets · Researched: 2026-10-05 · Confidence: partly unverified (see banner)

## 1. Core Processing & Memory

| Subsystem / Function | Component / IC Part Number | Manufacturer | Package / Footprint | Bus / Interface | Details & Specifications |
|---|---|---|---|---|---|
| **Application Processor (SoC)** | **Qualcomm Snapdragon 8 Gen 2 / QCS8550** (SM8550, SoC ID 603, v2.0) | Qualcomm | BGA / PoP | System Bus | 4nm TSMC (N4). Octa-core Kryo CPU (1x Cortex-X3 prime @ 3.19 GHz, 2x Cortex-A715 @ 2.80 GHz, 2x Cortex-A710 @ 2.80 GHz, 3x Cortex-A510 @ 2.02 GHz). Adreno 740 GPU. Hexagon NPU (48 TOPS). [observed `soc0`, `lscpu`] [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts] |
| **Compute Base Reference** | **Quectel SA885G / SG885G-WF BSP** | Quectel Wireless | LGA Reference Architecture | System Bus | Motherboard power tree, pinout, and battery profile inherit Quectel SG885G-WF smart module reference design. [observed `/sys/class/power_supply/battery/model_name`] [src: Quectel SG885G-WF Hardware Design] |
| **System RAM** | **16 GB LPDDR5X-8533** | SK hynix / Micron | PoP (Package-on-Package over SoC) | 4x 16-bit LPDDR5X bus | Qualcomm DDR type `0x08` (LPDDR5X), clock up to 4266 MHz (8533 MT/s). [observed `/proc/device-tree/memory@a0000000/ddr_device_type`] |
| **Internal Storage** | **HN8T374ZJKX141** (1 TB UFS 4.0) | SK hynix | 153-ball BGA | UFS HC `1d84000.ufshc` (2-lane M-PHY Gear 1-4) | JEDEC UFS 4.0 spec (`0x0400`), Vendor ID `0x01AD` (SK hynix), Firmware Rev `X202`. Sequential read ~910 MB/s. [observed `/sys/block/sda/device/`, `string_descriptors`] |
| **microSD Storage Host** | **Qualcomm SDHCI MSM Controller** | Qualcomm | Integrated in SoC | `sdhc_2` (`/soc@0/mmc@8804000`) | Bound to `sdhci_msm`. Negotiates UHS-I SDR104 @ 202 MHz on 1.8V signalling. Measured throughput 89.5 MB/s. Card detect on PM8550 GPIO 12. [observed] [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi#L1453-L1468] |

---

## 2. Power Management ICs (Qualcomm PMIC Power Tree)

| PMIC Node | Part Number | Function | Key Rails & Managed Peripherals |
|---|---|---|---|
| **PMIC @ 0** | **Qualcomm PMK8550** | Master Housekeeping & Clock PMIC | 32.764 kHz master sleep clock (`pmk8550_sleep_clk`), SPMI NVRAM/SDAM (`0x9d00` holding `hap_cfg_sdam`), Power-on logic (`pon_pwrkey`, `pon_resin` / Vol-). [src: common.dtsi#L1181-L1203, L1418-L1437] |
| **PMIC @ 1** | **Qualcomm PM8550** | Main System Power Management IC | Primary buck/LDO regulators (`vreg_l2b`..`vreg_l17b`), 3-channel PWM generator (PWM3 controls fan speed, PWM1/2/3 drive RGB power LED), 12 GPIOs (GPIO 6 Vol+, GPIO 8 Fan PWM, GPIO 12 SD card detect). [src: common.dtsi#L573-L729, L1125-L1179] |
| **PMIC @ 5** | **Qualcomm PM8550VE** | High-Current Slave Buck PMIC | Dedicated low-voltage core power rail `vreg_s4f_0p5` (0.3V–0.7V) for prime CPU cluster / NPU. [src: common.dtsi#L825-L869] |
| **PMIC Slave Array** | **Qualcomm PM8550VS** (4 discrete ICs: IDs `c`, `d`, `e`, `g`) | Multiphase Buck Regulators | Ultra-low ripple power rails: `vreg_s4e_0p95`, `vreg_s5e_1p08`, `vreg_s1g_1p2`, `vreg_s2g_0p8`, `vreg_s3g_0p7`, `vreg_s4g_1p3`, `vreg_s5g_0p8` feeding Adreno 740 GPU, CPU big clusters, and memory buses. [src: common.dtsi#L731-L822, L871-L946] |
| **PMIC @ 7** | **Qualcomm PM8550B** | Battery Charger, Haptics & USB PMIC | Fast battery charging management (27W USB-PD, bypass charging), integrated High-Voltage LRA haptics driver (`qcom,hv-haptics`), integrated eUSB2 repeater (`pm8550b_eusb2_repeater`). [src: common.dtsi#L1188-L1394] |
| **PMU (Wireless)** | **Qualcomm WCN7850-PMU** | Dedicated RF/PCIe Power Management Unit | Supplies 10 discrete regulated rails: `vreg_pmu_rfa_cmn`, `aon_0p59`, `wlcx_0p8`, `wlmx_0p85`, `btcmx_0p85`, `rfa_0p8`, `rfa_1p2`, `rfa_1p8`, `pcie_0p9`, `pcie_1p8`. [src: common.dtsi#L512-L570] |

---

## 3. Display Subsystem & Display Driver ICs (DDICs)

| Display Component | DDIC Part Number | Manufacturer | Package / Type | Interface & Timings | Driver Binding |
|---|---|---|---|---|---|
| **Top Display Panel** (6.0" AMOLED) | **Chipone ICNA3520** | Chipone Technology (Beijing) | COP (Chip-on-Plastic) | 4-lane MIPI D-PHY on `mdss_dsi1` (`DSI-2`). Resolution: 1080×1920 @ 120Hz. Dual RAM framebuffer, LTPS/LTPO AMOLED backplane. | `panel-chipone-icna35xx` (`chipone,icna3520`) [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L167-L183] |
| **Bottom Display Panel** (3.92" AMOLED) | **Chipwealth CH13726A** | Chipwealth Microelectronics | COG / COF | 4-lane MIPI DSI on `mdss_dsi0` (`DSI-1`). Resolution: 1080×1240 @ 60Hz (pixel clock 87.34 MHz). Shared timing mode with Retroid Pocket Mini V2 (`rpminiv2`). | `panel-ddic-ch13726a` (`ch13726a,thor`) [src: refs/upstream/armada@574da80:packages/kernel/patches/0057_DDIC-CH13726A-panel.patch] |

---

## 4. Touchscreen Controllers

| Subsystem | Touch Controller IC | Manufacturer | Bus & Address | Interrupt & Reset | Details |
|---|---|---|---|---|---|
| **Top Touchscreen** | **FocalTech FT5426** | FocalTech Systems | I2C-4 @ `0x38` | IRQ: TLMM 25; RST: TLMM 24 | True multi-touch capacitive touch controller with embedded 16-bit MCU. Up to 10-point multi-touch, 1080×1920 coordinate plane. Driver: `edt-ft5x06`. [observed] [src: qcs8550-ayn-thor.dts#L257-L283] |
| **Bottom Touchscreen**| **FocalTech FT5452** | FocalTech Systems | I2C-1 @ `0x38` (via `i2c_hub_3`) | IRQ: TLMM 15; RST: TLMM 14 | Capacitive multi-touch controller, 1080×1240 coordinate plane. Hardware quirk: cannot tolerate standard poweroff/reset during sleep; requires `edt,retain-power-in-suspend`. Driver: `edt-ft5x06`. [observed] [src: qcs8550-ayn-thor.dts#L372-L403] |

---

## 5. Audio Subsystem

| Function | Component / IC Part Number | Manufacturer | Package | Interface / Bus | Key Specifications |
|---|---|---|---|---|---|
| **Audio Codec** | **Qualcomm WCD9385** | Qualcomm | WLCSP | SoundWire Master 2 (`0217:010d` RX) & Master 3 (`0217:010d` TX) | High-fidelity audio codec, 32-bit DAC/ADC, integrated low-noise headphone amplifier, DMIC/AMIC capture paths. Driver: `soundwire:wcd938x`. [observed] [src: common.dtsi#L1474-L1490] |
| **Speaker Amplifiers** | **Dual Awinic AW88166FCR** | Awinic Technology | FCQFN-22L (2.0×2.5×0.55mm) | I2S/TDM digital audio + I2C (`0x34` Left, `0x35` Right on `i2c_hub_2`) | Digital "Smart K" Class D audio amplifiers. Built-in 6.25V smart boost converter, 2.1W into 8Ω @ 1% THD+N, 10 µV noise floor. Reset: TLMM 103 (L), TLMM 100 (R). Firmware: `aw883xx_acf.bin`. Driver: `aw88166`. [observed] [src: common.dtsi#L988-L1007] |

---

## 6. Wireless Connectivity (Wi-Fi 7 / Bluetooth 5.3)

| Function | Component Part Number | Manufacturer | Bus Interface | Driver Module | Details |
|---|---|---|---|---|---|
| **Wi-Fi 7 (802.11be)** | **Qualcomm WCN7850** (FastConnect 7800) | Qualcomm | PCIe Gen3 x1 (`pci17cb,1107`, `pcie0`) | `ath12k_wifi7_pci` | Wi-Fi 7 2x2 MIMO, 320 MHz channels, 4K QAM, High Band Simultaneous Multi-Link (HBS MLO). Wake GPIO: TLMM 96, RST: TLMM 94. [observed] [src: common.dtsi#L1102-L1115] |
| **Bluetooth 5.3** | **Qualcomm WCN7850** | Qualcomm | High-speed UART14 (`serial@898000`) @ 3.2 Mbps | `hci_uart_qca` (`qcom,wcn7850-bt`, `hci0`) | Bluetooth 5.3, LE Audio, dual Bluetooth antennas, aptX Lossless / LE Audio codecs. Enable GPIO: TLMM 81. [observed] [src: common.dtsi#L1683-L1695] |

---

## 7. Controller MCU, Sensors, LEDs & Peripheral ICs

| Subsystem | Component / Part Number | Manufacturer / Origin | Bus / Node | Details & Protocol |
|---|---|---|---|---|
| **Controller MCU** | **AYN Custom Microcontroller** | AYN Technologies | UART15 (`serial1-0`, `serial@89c000`) @ 115200 baud | Embedded MCU handling button matrix, Hall stick ADCs, and trigger ADCs. Communicates via RSInput binary protocol (`0xA5 0xD3 0x5A 0x3D` sync header, XOR checksum, 22-byte packet). MCU power: 3.3V VDD on TLMM GPIO 99 (`joystick_vdd_reg`). Reset on TLMM GPIO 0, Boot on TLMM GPIO 1. Driver: `rsinput`. [observed] [src: patch `0031_input--Add-driver-for-RSInput-Gamepad.patch`] [src: `kalamap-moorechip-joystick.dtsi#L70-L102`] |
| **MCU Level Shifter** | **Awinic AW3911** | Awinic Technology | TLMM GPIO 12 (`joystick_levelshifter_reg`) | 1.8V bidirectional voltage level translator IC shifting 1.8V SoC I/O lines to 3.3V MCU logic levels. [src: `kalamap-moorechip-joystick.dtsi#L79-L88`] |
| **Custom AYN Key** | **Discrete Tactile Switch** | OEM | TLMM GPIO 41 (`msmgpio 41`) | Active-low system button mapped to `KEY_F24` (Linux scanCode 194). Wake-capable input device on `gpio-keys`. [src: `kalamap-ayn-odin2-thor.dtsi#L62-L70`] |
| **Stick RGB LED Drivers** | **Dual Heroic / Yongfukang HTR3212** | Jiaxing Heroic Electronic Technology | I2C-0 @ `0x3c` (Left) and I2C-12 @ `0x3c` (Right) | 12-channel constant-current LED PWM driver in QFN-20L (3×3mm). 256-step PWM brightness per channel, driving 4 RGB LEDs = 12 channels per stick ring. Hardware shutdown pin SDB on TLMM GPIO 55 (L) and GPIO 56 (R). Driver: `htr3212`. [observed] [src: qcs8550-ayn-thor.dts#L185-L255, L285-L355] [src: `kalamap-moorechip-leds-htr3212.dtsi`] |
| **Clamshell Lid Switch** | **Hall Effect Sensor** | Discrete Hall IC | TLMM GPIO 17 (`msmgpio 17`), IRQ 199 | Active-low magnetic switch detecting lid closure (`gpio-keys-lid`, `SW_LID`). Configured as system wakeup source (`s2idle` wake IRQ). [observed] [src: qcs8550-ayn-thor.dts#L31-L42] [src: `kalamap-ayn-odin2-thor.dtsi#L72-L79`] |
| **Haptics Transducer** | **Qualcomm High-Voltage LRA Motor** | PM8550B Integrated Driver | SPMI PMIC7 @ `0xf000` (`qcom,hv-haptics`) | Driven up to 5000 mV peak with sine waveform, 5880 µs resonant period (~170 Hz resonance frequency), closed-loop active braking. Driver: `qcom-hv-haptics`. [observed] [src: common.dtsi#L1189-L1386] |
| **Cooling Fan** | **5.0V Centrifugal Blower Fan** | OEM Centrifugal Fan | PM8550 PWM3 (GPIO 8) + TLMM GPIO 13 (Tach) | Active PWM cooling fan driven at 40 kHz PWM frequency, tachometer interrupt on TLMM 13 (4 pulses/rev). 5.0V fan regulator on TLMM GPIO 109 (`fan_reg`). Monitored via `hwmon43` `pwmfan`. [observed] [src: common.dtsi#L101-L116] [src: `kalamap-moorechip-thermal.dtsi#L1-L40`] |
| **USB-C SBU Crossbar Switch** | **Discrete Analog Crossbar Mux** (e.g. FSA4480 / PI3USB102 class) | Discrete IC | TLMM GPIO 140 (OE-N) & GPIO 141 (SEL) | High-speed analog switch routing Sideband Use (SBU1/SBU2) lines for USB-C DisplayPort Alt Mode. Driver: `gpio-sbu-mux`. [observed] [src: common.dtsi#L425-L432, L1643-L1658] |
| **Battery Cell Pack** | **6000 mAh Li-ion Pack** (`8110606`) | OEM Battery Manufacturer | Monitored by PM8550B fuel gauge via `pmic_glink` | Profile: `8110606_QUECTEL_SA885GLIVESTREAMING2025_6000MAH_AVERAGED_MASTERSLAVE_SEP18TH2025`. Dual-cell averaged master/slave configuration. Supports up to 27W USB-PD charging. [observed `/sys/class/power_supply/battery/`] |

---

## Sources
- [S1] Live device read-only hardware audit on `armada@<thor-ip>` (2026-10-05).
- [S2] `refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts`
- [S3] `refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi`
- [S4] `refs/upstream/armada@574da80:packages/kernel/patches/0031_input--Add-driver-for-RSInput-Gamepad.patch` (RSInput protocol & MCU framing)
- [S5] `refs/upstream/armada@574da80:packages/kernel/patches/0057_DDIC-CH13726A-panel.patch` (Chipwealth CH13726A DDIC)
- [S6] `refs/thor-linux/thorch/packages/linux-thorch/patches/0016-input-edt-ft5x06-retain-power-in-suspend.patch` (FocalTech FT5452 suspend behaviour)
- [S7] Quectel SG885G-WF Hardware Design Guide (Qualcomm QCS8550 + PM8550/B/VE/VS/K + WCN7850 + WCD9385 SOM architecture)
- [S8] Awinic AW88166FCR Datasheet (`DS_AW88166FCR_EN_V1.4`)
- [S9] Jiaxing Heroic HTR3212 12-channel LED Driver Datasheet
- [S10] Chipone ICNA3520 AMOLED DDIC Linux Kernel Bindings (`chipone,icna35xx.yaml`)
- [S11] FocalTech FT5426 CTPM Application Notes & Kernel Bindings (`edt-ft5x06`)
- [S12] SK hynix HN8T374ZJKX141 UFS 4.0 153-ball BGA Component Registry
