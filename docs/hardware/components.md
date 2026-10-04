# AYN Thor - internal components
> Scope: Component ICs derived from device tree, system files, and on-device observation · Researched: 2026-10-03 · Confidence: high (derived from live device paths and kernel driver bindings)

| Subsystem | Component / IC | Details / Kernel Driver |
|---|---|---|
| Top screen | Chipone ICNA3520 | Handled by icna3520 (driver: icna35xx) |
| Bottom screen | CH13726A | Handled by ch13726a (compatible: ch13726a,thor) |
| Touch (top) | FocalTech FT5426 | Driver ocaltech,ft5426 |
| Touch (bottom) | FocalTech FT5452 | Driver ocaltech,ft5452 |
| Audio | Awinic AW88166 | SmartPA amplifier |
| Wi-Fi / Bluetooth | Qualcomm WCN7850 | Wi-Fi 7 / BT 5.3 (FastConnect 7800) |
| Controller MCU | "AYN Odin2 Gamepad" | Exposed via sinput-gamepad (VID 2020 PID 3001) |
| Extra buttons | gpio-keys-ayn | AYN, M1, M2 buttons |

[src: device tree blob (	hor.dtb) strings match] [src: efs/upstream/armada/packages/kernel/patches] [src: /usr/share/inputplumber/devices/50-ayn_thor.yaml]
