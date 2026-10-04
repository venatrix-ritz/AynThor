# Tuning recommendations for Ven's Thor (Armada 20260926)
> Scope: what is worth changing for battery/heat/performance, with evidence · Researched: 2026-10-03 · Confidence: medium — based on the device's live state and Armada's shipped profile definitions; **no setting was changed** (see "Why nothing was applied")

## Summary
The Thor is mostly well tuned out of the box (zram swap, tuned VM settings, native s2idle sleep, ABL matches the shipped version). The one big lever is the **power profile**: it was on **Performance**, which pins CPU and GPU at maximum regardless of load.

## What the profiles do (shipped definitions)
| Profile | CPU governor | CPU cap / underclock | GPU | Fan curve (°C:pwm) |
|---|---|---|---|---|
| Eco | conservative | 65 % max, underclock *large* (SM8550: 1.459 / 1.786 / 1.843 GHz little/mid/prime) | max 80 %, min 0 | relaxed (98:255 … 65:51) |
| **Balanced** (default) | conservative | 100 %, underclock *medium* (1.555 / 2.054 / 2.093 GHz) | 0–100 % | moderate (96:255 … 55:51) |
| **Performance** (current) | **performance** | 100 %, no underclock (2.016 / 2.803 / 2.957 GHz) | **min = max = 100 %** | aggressive (90:255 … 45:51) |
Fan: floor pwm 51 (~20 %), ramp up 36 / down 6, `charging_pwm=0`. [src: refs/upstream/armada@574da80:system_files/usr/share/armada/power-profiles.conf#L1-L56] On the device: `profile=Performance`, CPUs at max clocks and GPU **manual 680 MHz (min=max)** while idle, fan 2885 RPM at 73 °C. [observed — [device-observed](device-observed.md)]

## Recommendations (safest/highest value first)
1. **Use Balanced (or Eco) unless a game needs Performance.** Performance's `gpu_min=1.0` and `governor=performance` keep the GPU at 680 MHz and CPUs at max even in menus — the likely reason for heat/fan noise reports (#57) and battery drain. Switch in Steam QAM → Performance → Performance Profile (Armada Control's Power tab only *edits* profiles — [faq](../armada/faq.md)); the device CLI also lists `armada-power profile [name]` [exact accepted names not tested]. Use Performance per-session for demanding titles only.
2. **For stutter in specific games, pin cores instead of raising the profile.** Issue #449 reports Dark Souls 1–3, Psychonauts, Valheim, Lies of P etc. stabilise when Armada Control cores are set to **Big**; per-game, saved in Armada Control. [src: refs/_gh/issues.json#449]
3. **Leave the memory and storage settings alone** — zram 15.1 G, swappiness 180, `page-cluster=0`, `min_free_kbytes=45056` are already the gaming-oriented set (PR #277). UFS 4.0 internal and SDR104 on the SD card are both in effect.
4. **Optional cleanup:** `rpm-ostree-countme.service` (weekly "count me" reporting) is the only failed unit; masking its timer silences it. [observed `systemctl --failed`] `sudo systemctl mask --now rpm-ostree-countme.timer` [timer name not verified on device].
5. **Optional decision — ABL auto-update:** `/etc/armada/abl.conf` has `auto_update_enabled=1` while the image build default is `ARMADA_ABL_AUTO=0`. The flashed ABL (1.1.8) already equals the shipped one; if you prefer ABL (the bootloader stage) to change only when you choose, set it to `0`. What auto-update does exactly was not read [UNVERIFIED].
6. **Battery longevity:** upstream has no charge limit (`charge_control_end_threshold=0`; issue #363 asks for one on Odin 3). The Thor-specific 80 % limit exists only in the community `MgeeeeK/thor-armada` image — not recommended without reviewing it ([forks-and-related](../armada/forks-and-related.md)).
7. **Do not chase these kernel messages as tuning:** `arm-smmu` context faults (unidentified master), `a740_sqe.fw` early-boot load error, `dwc3 HS-PHY not in L2` (possible sleep-power cost), haptics debug lines — report-worthy upstream, not user-tunable. The `pmic-glink … device link` line is not diagnostic of the monitor freeze (it appears with no monitor).

## Why nothing was applied
Ven said "do what you think is best." Changing power profiles, services, or bootloader config on the device is a system-settings change that I should not make on my own authority, so these are proposals with the evidence above. Items 1 and 2 are normal UI toggles; 4–5 need `sudo` and are optional.

## Sources
- [S1] refs/upstream/armada@574da80:system_files/usr/share/armada/power-profiles.conf
- [S2] [device-observed](device-observed.md) (live state, 2026-10-03); refs/_gh/issues.json (#57, #363, #449)
