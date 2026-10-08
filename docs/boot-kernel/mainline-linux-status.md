# Mainline Linux Status (Armada OS)
> Scope: what Armada's kernel carries out of tree for the Thor · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: high, read from Armada's own patch index. The earlier version said Armada runs "typically 6.x" and named a charge-limit patch that is not in Armada's tree; both were wrong and are corrected below.

## Kernel base and patch stack
- Armada builds its own kernel from a pinned base: `VERSION=7.2.6`. The Thor surveyed 2026-10-07 runs `7.2.6`. [src: refs/upstream/armada@574da80:packages/kernel/BASE.env#L1; observed 2026-10-07: docs/hardware/device-observed.md]
- The patch directory holds 198 patch files; `PATCHES.md` indexes 177 entries, each with a `source` and an `upstream` field. Of those, 42 are marked `upstream: local` (Armada-authored, not submitted), 96 `upstream: unknown` (no equivalent submission found), 31 link to an upstream submission, and 8 carry no `upstream` line; 68 entries are `source: armada`. Counted from the file on 2026-10-07. [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L1-L8]
- Most entries come from ROCKNIX's SM8550/SM8250/SM8750 patch sets: 143 of the `source:` lines point at `ROCKNIX/distribution`. [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L9-L16]

## What the Thor needs that is not upstream (examples from the index)
| Area | Patch | Upstream status per the index |
|---|---|---|
| Top panel (Chipone ICNA35xx) | `0028-drm-panel-Add-panel-driver-for-Chipone-ICNA35XX-base` | submitted (lore v4); Armada's version differs from the submission and is ported to Linux 7.2 [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L59-L62] |
| Bottom panel (CH13726A) | `0057_DDIC-CH13726A-panel` | unknown [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L82-L84] |
| Touch (FocalTech ft5426/ft5452 via `edt-ft5x06`) | `0015` (input-name override), `0029` (`no_regmap_bulk_read`) | both have lore submissions [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L146-L148, #L182-L184] |
| Gamepad MCU | `0031_input--Add-driver-for-RSInput-Gamepad` | unknown; built as a module `CONFIG_JOYSTICK_RSINPUT=m` [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L204-L206; refs/upstream/armada@574da80:packages/kernel/config/armada-kernel.config.overrides#L127] |
| Stick LEDs | `0030-leds-Add-driver-for-HEROIC-HTR3212` | unknown; `CONFIG_LEDS_HTR3212=y` [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L280-L282; refs/upstream/armada@574da80:packages/kernel/config/armada-kernel.config.overrides#L144] |
| Speaker amps (Awinic AW88166) | `0032-ASoC-codecs-aw88166-AYN-Products-Specific-modificati` | unknown; `CONFIG_SND_SOC_AW88166=m` [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L277-L279; refs/upstream/armada@574da80:packages/kernel/config/armada-kernel.config.overrides#L182] |
| Battery manager | `0900`-`0903` (adapter type log, charge unit, `CHARGE_NOW`, charge-current limit as `constant_charge_current`) | two have upstream submissions; `0903` is Armada-local [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L389-L402] |
| Suspend | e.g. `0204` tsens IRQ mask across suspend, `0504` IPCC summary IRQ mask, `0523`/`0524` RPMh regulator suspend state and s2idle | `0204` local; `0523`/`0524` unknown [src: refs/upstream/armada@574da80:packages/kernel/PATCHES.md#L297, #L307, #L327-L333] |

## Not supported by a source here
The earlier claims that SM8250/SM8550 "enjoy robust mainline support thanks to Linaro" and that "ROCKNIX and Armada collaborate to upstream these drivers" have no source in `refs/` and are dropped. The index above is the evidence: many patches are marked "upstream unknown".

## Sources
- [S1] refs/upstream/armada@574da80:packages/kernel/{BASE.env,PATCHES.md,config/armada-kernel.config.overrides}
- [S2] On-device `uname -r`, 2026-10-07
