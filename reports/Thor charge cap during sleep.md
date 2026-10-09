# Pre-sleep clamping holds the Thor's cap

**No firmware or kernel mechanism is known to hold an 80 % cap on the AYN Thor while it sleeps with nothing running, so the cap has to be set before the CPU goes quiet.**

- **Threshold path:** The mainline `charge_control_end_threshold` path is accepted by the driver, but the Thor's ADSP firmware shows no sign of implementing it. The `0` readback is the firmware's own answer to a GET, not a stored copy of what was written.
- **Clamp:** `constant_charge_current` = 0 is a plain on/off clamp that the firmware keeps holding through s2idle (test A, 2026-10-08). Nothing flips it at 80 %, because the userspace poller is frozen in native s2idle (test B: slept at 78 % on a charger, reached 88-89 %).
- **Other projects:** Steam Deck, TLP, UPower, asusd and KDE all rely on a firmware threshold and at most re-send it on resume. None runs code during sleep.
- **Cheapest fix:** A clamp written in a `pre`-sleep hook (or a logind delay inhibitor), then re-evaluated on resume. The price is that the battery does not charge while asleep once clamped.
- **Other routes:** Fake sleep, an RTC wake backstop and AYN's `limit_capacity_charge` flag (property 16) are also testable and are ranked at the end.
- **The 0.91 A step:** The flat step near 89 % has no documented cause. Seven candidates are separable with one firmware-log capture.
- **Disagreements:** The four notes disagree in several places, listed in their own section.

*Evidence tags carried from the notes: **[V]** verified in source; **[S]** secondary (forum, README, summariser-read page, fork author's claim); **[U]** unverified; **[OBS]** local device observation. This synthesises four notes dated 2026-10-08 (`research_notes/Thor charge cap during sleep/`). Local citations read `refs/<dir>@<sha7>:path#Lnn`, relative to `G:/Projects/Hardware/AynThor/`. The report writer could not save this file; the main session saved its text unchanged.*

## The firmware threshold is ignored, and a readback of 0 is the firmware's answer

**What mainline claims.** Fenglin Wu of Qualcomm added the charge-control feature (opcode `BATTMGR_CHG_CTRL_LIMIT_EN`, 0x48, commit `cc3e883a0625`, 2025-09-17). A follow-up says SM8550 and X1E80100 "now include charge control functionality in battery management firmware" **[V]** ([commit](https://github.com/torvalds/linux/commit/cc3e883a06251ba835f15672dbe8724f2687971b), [compat commit](https://github.com/torvalds/linux/commit/b3c0f651b3cf4dfaf2e8210d7bb9b79471f6403b)).
- It was tested on a QRD8650 (SM8650 board, SM8550 driver variant), an X1E80100 CRD and a ThinkPad T14s OLED, never on an OEM SM8550 handheld. No thread names the firmware version **[V]** ([v3 thread](https://lkml.iu.edu/hypermail/linux/kernel/2509.0/04320.html)).
- On X1E80100 the thresholds live in PMIC SDAM and survive reboot ("won't be reset until battery is unplugged or completely drained"). The firmware sets bit 8 of notification 0x83 when it stops at the end threshold **[V]** ([Wu, 2025-11-17](https://lkml.iu.edu/2511.2/02578.html); [commit 41307ec](https://github.com/torvalds/linux/commit/41307ec7df057239aae3d0f089cc35a0d735cdf8)).
- That is the nearest analogue of a no-userspace cap, but no source tests it across suspend **[U]**.

**Why a "successful" write proves nothing.** The set functions return 0 unconditionally. The request waits one second and returns `-ETIMEDOUT` with no log line. The 0x48 reply handler sets `error = 0` without reading any result field, and there is no `dev_err` on the path **[V]** (`torvalds/linux@6c377d19d4a5:drivers/power/supply/qcom_battmgr.c#L344-L362, #L677-L728, #L1559-L1569`).
- On the SM8550 variant every read of `charge_control_end_threshold` issues a fresh GET of firmware property 26 and overwrites the cache with the reply. The readback therefore reflects the firmware **[V]** (same file, `#L451-L470, #L523-L527, #L1400-L1405, #L1472-L1476`).
- The Thor's device tree has no threshold `nvmem-cells`, so the driver cache starts at 0 **[V]** (`refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi#L58-L59`).
- A clean `0` rather than an errno means the GET succeeded and returned 0 **[U]**.
- Three explanations fit every observation and the source cannot separate them **[U]**:
  - (a) The firmware never answers 0x48, so each write silently costs one second.
  - (b) It accepts 0x48 but does not report property 26.
  - (c) It needs `BATT_CHG_CTRL_EN` (property 24) set first, as Qualcomm's downstream driver does and mainline never does.
- The downstream gate is in a Nothing (SM7635) tree, not AYN's **[V]** (`NothingOSS/android_kernel_msm-6.1_nothing_sm7635@d5f5f96:drivers/power/supply/qti_battery_charger.c#L2969-L2970, #L3048-L3061`).

**What the firmware image says.** A byte-level string search of the Thor's `adsp.mbn` finds no `battmngr_set_charging_limit::enable = %d, target soc = %d, delta soc = %d`. The Odin 3, KONKR Pocket Fit Elite and AYANEO PS2 blobs in the same tree do contain it **[V]** (`refs/upstream/armada@574da80:system_files/usr/lib/firmware/qcom/sm8550/ayn/thor/adsp.mbn`, sha256 `e771ab967310…`). This favours (a) or (b). The absence is circumstantial, because a handler can exist without a log line **[U]**.
- The Thor blob does contain an AYN-specific path: `usb_charge_now=%d, limit_capacity_charge=%d, bat_capacity = %d curr_cap_state = %d, last_cap_state = %d` (offset 0xc7358f). The Retroid Pocket 6 blob shares it and the Odin 2 blobs lack it **[V]**.
- Stock AYN Android writes "Stop at 80 %" to `/sys/class/qcom-battery/limit_capacity_charge`. It stops charging at 80 % and does not discharge a fuller battery, per the app author's check on a Thor on 2026-10-01 **[S]** (`refs/thor-android/thor-wayfinder@305d3ad:app/src/main/java/app/wayfinder/Charging.kt#L10-L22`).
- Whether that flag holds through s2idle on the Thor has not been shown by anyone **[U]**.

**Other devices and the firmware in sleep.**
- A Retroid Pocket Nova shows the same symptom: thresholds accepted, read back as 0.
- A threshold-only build let the Nova charge from 69 % to 96 % while asleep, while `constant_charge_current` = 0 held through sleep **[S]** ([nova-charge-limiter README](https://github.com/msmirle/nova-charge-limiter/blob/aa69f2896e3304396a8a4de86dc391df8f9a8394/README.md)).
- The firmware is alive during s2idle. Armada's commit message says the charger firmware pushes an unsolicited `BATTMGR_NOTIFICATION` about 0.5 s after suspend entry, and patch 0504 keeps the IPCC doorbell live in suspend-to-idle. These are the patch author's statements, not measured **[V]** for the quote, **[S]** for the behaviour (`refs/upstream/armada@574da80` commit `ee66da0`; `packages/kernel/patches/0504-…patch#L1-L22`).
- That matches test A: the clamp is firmware state and persists while the AP sleeps **[OBS]**.

**Hazards for any threshold experiment.**
- Val Packett reverted her own "disable" support because the disable bit "was acting rather strange" **[V]** ([lkml](https://lkml.iu.edu/2511.0/01157.html)).
- Wu warns a bad setting can leave a machine unable to charge until the battery is hot-unplugged **[V]**.
- One user says writing `charge_control_start_threshold` on a Thor "shuts off the screens until a hard reboot". This is a single unreproduced comment **[S]** ([issue 1](https://github.com/msmirle/nova-charge-limiter/issues/1)).
- If you experiment, write only the end threshold and expect nothing.

## The 0.91 A step near 89 % has no documented cause, but it is diagnosable

**The observation [OBS].**
- Replug at 89 %. Current starts at about 3.8-4.3 A, then steps down twice within about 20 s to about 0.91 A, flat for minutes.
- `voltage_now` is 4.296 V rising to 4.301 V. `voltage_max` is 4.4 V. Battery is 36 C.
- `constant_charge_current` still reads 9000000. `charge_type` is Fast. `time_to_full_avg` is about 2325 s. The PD contract is 9 V.

No source documents a step at 89 % for any 4.4 V pack. The Armada issue export (342 issues, 258 PRs) and web search show no Thor report of it. Armada's charging complaints are about a 4-9 W floor and firmware mix-ups. The one "stops at 85-94 %" report (issue #189) is a different device with the unit off **[V]** (`refs/_gh/issues.json`).

**What is documented is the shape such a step could take.**
- Qualcomm profiles express step charging as voltage-keyed FCC windows. A 4.4 V reference cell steps 8 A, 6 A and 4 A at 4.0 V and 4.2 V (OCV-based). A 4.35 V profile steps at 3.8 V and 4.3 V **[V]** (`refs/thor-android/android_kernel_ayn_qcs8550-devicetrees@9b2d195:qcom/qg-batterydata-atl466271_3300mAh.dtsi#L3-L26`, `qg-batterydata-alium-3600mah.dtsi#L3-L21`).
- On pmic_glink platforms this logic runs in ADSP firmware. The Thor's `adsp.mbn` carries step-charge, JEITA, top-off and "cv mode" code, with states `Fast_Charge`, `TopOff_Charge`, `Done`, `ReCharge` and `Not_Charging_Thermal` **[V]**.
- The Thor's `adsp_dtb.mbn` sets `en-stepchg-jeita = 1`, `iterm-ma = 100`, `en-linear-soc = 1`, `soc-conv-pt = 500` and `min-linear-soc = 750`. Its nominal float (4350 mV) and FCC (3000 mA) disagree with the 4.4 V and 4.3 A actually seen, and no step table is in the file **[V]** for the contents, **[U]** for the reason.
- Its decoded content is identical to the Odin 2 and RP6 copies and names the reference board `qcom,kailua-mtp` **[V]**.
- The kernel only passes values through (`charge_type`, `voltage_max` and `time_to_full_avg` are firmware integers). No Armada patch computes FCC or writes the node, so the step is firmware behaviour **[V]**.

**Candidates.** The predictions are assembled from the firmware strings and the observation, not from a source stating the cause **[U]**.

| Candidate | Predicts | Separating evidence |
|---|---|---|
| CV/top-off at a float below 4.4 V | Current decays continuously; voltage pins at the float | Firmware log `FV =` near 4.30 V and a TopOff entry line |
| Firmware step-charge stage (voltage, OCV or SOC keyed) | Flat within a stage; small dip of dI x R at the step; same threshold on repeat replugs; hysteresis | Log `StepChgJeitaParam ... Configured FCC=... FV=...`; replug at 85 % and 88 % |
| JEITA zone | Steps at 10/45/55 C battery temperature | 36 C is mid-zone, so unlikely |
| Thermal mask (skin, connector, die, SMB) | Tracks a sensor Linux may not report | Log `Change to state ... thermal mask`, `skin_adc`; cool the device and retest |
| Input-side limit (ICL/AICL) | Steps after renegotiation; load dependent | `qcom-battmgr-usb` `input_current_limit`, `current_now`, `voltage_now` across the step |
| HLOS vote (Gleipnir, old `thor-charge-limit`) | Node would read below max | Node reads 9000000, so unlikely; `journalctl -t gleipnir` rules it out |
| AYN capacity-limit flag | Stops or sharply cuts above 80 % | Current still flows at 89 %, which argues against a hard cap |

**Reading the plateau.** Flat current with a slowly rising 4.30 V reads more like a current-regulated limit than textbook CV. That is a reading of the data, not a finding **[U]**.
- One ambiguity decides how to read it: whether `constant_charge_current` returns the effective aggregate or only the HLOS vote.
- The node moved by itself (9.0, 5.46, 4.68 A) and read 5.46 A right after a write of its max **[OBS]**. That suggests an effective value.
- If so, 9000000 during the plateau means the FCC aggregate was not the limiter, and the cause is CV, an input limit, or something outside the FCC votes **[U]**.
- Derived arithmetic **[U]**: the remaining 11 % of 6.17 Ah is 0.68 Ah, about 2690 s at 0.91 A against the reported 2325 s.
- 5.46 A is exactly 0.91 x 6.0 Ah. That is a numeric coincidence with the plateau value, and nothing in the notes explains it.

**Cheapest evidence.**
- `sudo armada-charge-debug --ulog-only --watch 120` captures the firmware log from `PMIC_LOGS_ADSP_APPS`. It would show the `Config parameters changed, FCC … FV … iterm`, JEITA-zone, thermal-mask and `limit_capacity_charge=` lines **[V]** (`refs/upstream/armada@574da80:system_files/usr/bin/armada-charge-debug#L125-L155`).
- Whether the Thor exposes that channel is unverified. The script prints `ulog=channel-absent` if not.
- `tweaks/battery-monitor.py` logs already hold voltage and current across the step **[OBS]**.

**Bearing on the cap.** If a firmware plateau near 0.91 A begins around 89 %, the 88-89 % in test B may be where charging slowed, not where the daemon woke. The notes do not say which, and the sleep duration is not recorded **[U]**.

## Other projects trust firmware and only re-send the value on resume

**Steam Deck.** steamos-manager writes one sysfs attribute (`max_battery_charge_level` on `steamdeck_hwmon`, or standard `charge_control_end_threshold` on ROG Ally and MSI Claw).
- It has no suspend, logind or inhibitor code and no software fallback **[V]** (`refs/upstream/steamos-manager@08c45b5:steamos-manager/src/power.rs#L231-L239, #L664-L704`; `data/devices/steam-deck.toml#L40-L45`).
- That the Deck's EC enforces the number while asleep is inferred from the code shape. The driver source could not be retrieved **[U]**.
- Armada's `sm8550.toml` has no `battery_charge_limit` section, so the Thor gets no slider **[V]**.
- A Decky PowerTools user said the older plugin limit "only limits the charge when the Deck is turned on" **[S]**.

**Laptop tools.** They differ on resume, not on sleep.
- TLP's sleep hook does nothing for thresholds on `pre`. On `post` it reapplies only for ASUS, Huawei and LG, whose EC resets on resume **[V]** ([tlp.in](https://github.com/linrunner/TLP/blob/a4ea9ce/tlp.in#L448-L473)).
- asusd subscribes to logind `PrepareForSleep` and reapplies on wake **[V]** ([asusctl](https://gitlab.com/asus-linux/asusctl/-/blob/321b111/asusd/src/lib.rs#L205-L295)).
- UPower restores only when a battery appears and takes a delay inhibitor just to pause polling **[V]** ([up-device-battery.c](https://gitlab.freedesktop.org/upower/upower/-/blob/bb7af5f/src/up-device-battery.c#L536-L541)).
- KDE PowerDevil MR !621 proposes the same reapply-on-resume, and batlimit installs units on sleep targets **[S]**.
- The kernel ABI offers `inhibit-charge-awake` beside `inhibit-charge`, so it already distinguishes inhibition that persists in sleep from one that does not **[V]** ([sysfs-class-power](https://raw.githubusercontent.com/torvalds/linux/master/Documentation/ABI/testing/sysfs-class-power)).
- None of this is a precedent for enforcing the cap in software. All of it assumes hardware that enforces by itself.

**Closest matches to the Thor's failure.**
- A LineageOS 19 userspace limiter (writing `charging_enabled`) kept charging to 100 % after the display switched off **[S]** ([forum](https://www.android-hilfe.de/forum/root-custom-roms-modding-fuer-oneplus-6.3349/los-19-battery-charge-limiter-nicht-mehr-zuverlaessig.1003843.html)).
- The Nova project uses `constant_charge_current` = 0 and needs fake suspend so something can flip it at 80 % **[S]**.

**RTC precedents.**
- The in-tree Charger Manager wakes via an RTC alarm, restores any earlier alarm and suspends again. It monitors temperature rather than capping SOC **[V]** ([charger-manager.rst](https://raw.githubusercontent.com/torvalds/linux/master/Documentation/power/charger-manager.rst)).
- `bwake` suspends with `rtcwake` toward an 80 % target. It warns the result can land "~ 5%-10%" off, and it only sounds an alarm **[V]** ([README](https://raw.githubusercontent.com/helium18/bwake/master/README.md)).
- No ROCKNIX or postmarketOS cap was found. ROCKNIX PR 2840 (`charge_behaviour`, SM8750 bypass) is open and unmerged **[S]**.

**The one published Thor implementation** is in the MgeeeeK fork.
- Its `60-thor-charge-limit` hook, on `pre`, writes `1000` to `charge_control_limit` when `qcom-battmgr-usb/online` is 1 and capacity is at least 70.
- On `post` it restarts the 30 s `thor-charge-limit` service, whose `ExecStopPost` first releases the clamp **[V]** (`refs/upstream/armada@7e17352:system_files/usr/lib/systemd/system-sleep/60-thor-charge-limit#L1-L9`; `…/thor-charge-limit.service#L1-L13`).
- Nobody has reported how it behaves. The repo's own doc says which of the fork's two mechanisms holds the battery at 80 % is unverified **[V]**.
- By its code, a 78 % sleep falls inside its window, a sleep starting at 60-69 % on a charger is unprotected, and a clamped battery does not charge for the whole sleep **[U]** (derived from the code, not tested).

## s2idle freezes the daemon; fake sleep and RTC wakes are the only ways to run code

In native s2idle the kernel freezes all freezable userspace system-wide, so a `system.slice` service does not run between the write to `/sys/power/state` and a wake **[V]** ([sleep-states.rst](https://raw.githubusercontent.com/torvalds/linux/master/Documentation/admin-guide/pm/sleep-states.rst), [freezing-of-tasks.rst](https://raw.githubusercontent.com/torvalds/linux/master/Documentation/power/freezing-of-tasks.rst)). The rtc note read these through a summariser and tagged them **[S]**.
- Code can run via a boundary hook, in-kernel or firmware logic, a wake event, or a mode that never really suspends.
- Armada's fan work is in the kernel (patch 0532, a `power_supply_reg_notifier` reacting to `PSY_EVENT_PROP_CHANGED` while suspended). Its own text concedes an undelivered supply event leaves the fan as it was **[V]** (`refs/upstream/armada@574da80:packages/kernel/patches/0532-…patch#L10-L12, #L254-L258`).

**Boundary hooks.**
- `systemd-sleep` runs `pre` hooks in parallel, as root, ignoring errors, with `user.slice` already frozen. It then writes the kernel state and runs `post` hooks. Hooks can delay but not veto, and systemd calls them "hacks" **[V]** for the man page, **[S]** for the `sleep.c` detail ([man page](https://raw.githubusercontent.com/systemd/systemd/main/man/systemd-suspend.service.xml)).
- A hook must not wait on user services (user D-Bus, Steam, Decky). The per-hook timeout is unconfirmed **[U]**.
- A logind delay inhibitor holds the transition for at most `InhibitDelayMaxSec`, default 5 s **[V]** ([logind.conf](https://raw.githubusercontent.com/systemd/systemd/main/man/logind.conf.xml)).
- Hooks run only on the s2idle path. In fake mode `suspend-dispatch` execs `fake-suspend` and never calls `systemd-sleep` **[V]** (`refs/upstream/armada@574da80:system_files/usr/libexec/armada/suspend-dispatch#L10-L12, #L29-L35`).

**Fake sleep.**
- `fake-suspend` freezes only the session user's `app.slice` via `cgroup.freeze`, falling back to SIGSTOP on the gamescope cgroup. It turns the display off and pins CPU and GPU to minimum frequency via `armada-power suspend`. The kernel stays awake **[V]** (`fake-suspend#L209-L261`; `armada-powerd#L688-L748`).
- `system.slice` keeps running. `armada-powerd` has a 3 s `fan_tick` with an `if self.suspended:` branch, which is in-tree proof a system service runs during fake sleep **[V]**.
- Whether Gleipnir (a Decky plugin) sits outside `app.slice` was not checked **[U]**. `cat /proc/<pid>/cgroup` settles it. (Observed after the research: the Gleipnir daemon runs as a system service in `system.slice` per `systemctl show gleipnir -p Slice`; the Decky plugin that installs it is a separate process.)
- Radios are not blocked. The `suspend_radios`/`resume_radios` calls are commented out ("Radio suspend disabled until we can improve resume speed (currently takes 30+ seconds)"). `device-quirks` creates `/etc/NetworkManager/ignore-sleep` in fake mode **[V]** (`fake-suspend#L272-L273, L288-L289`; `device-quirks#L74-L83`).
- The cost is power. Armada's docs say s2idle draw "remains higher-than-ideal, though lower than 'fake sleep'", with no figure. Issue #3 calls fake sleep unreliable (idle sleep can break wake, clocks can stay pinned at minimum) **[V]**.
- Issue #264 shows radios left on are costly: Bluetooth left powered in s2idle drained 81 % to 56 % in 90 minutes, against about 1 %/h blocked. That issue concerns real suspend **[V]**.
- No fake-sleep drain number exists, and CPU idle depth in fake mode was not measured **[U]**.
- The Decky "Sleep type" toggle takes effect on the next suspend with no daemon restart. On build `20261006.9c7dd3e` `/etc/armada/sleep.conf` does not exist, so the default applies **[V]** for the code, **[OBS]** for the file (`docs/armada/sleep-battery.md`).

**RTC wake.**
- Armada has no wake-source discrimination, no "unexpected wake" handler and no auto re-sleep. An RTC wake is processed like a power-key wake: ledger line, a `powerbuttond` SIGUSR1 that does nothing without a key event, and `armada-powerd` re-applying the profile **[V]**.
- What lights the panel after an RTC wake (kernel DRM resume, gamescope or Steam) is unknown. Whether Steam re-suspends after a timer wake is closed-source and unread **[U]**.
- Armada's only RTC code was an off-by-default `rtcwake -m no -s $((N*60))` watchdog in the since-removed `50-armada-real-suspend`. That hook also wrote `0` to every `bl_power` after resume **[V]** (`git -C refs/upstream/armada show 17970ec:…/50-armada-real-suspend`).
- The rtc note records, as device facts passed to it, that 3-minute and 10-minute `rtcwake -m freeze` tests worked. It also says the wake ledger shows only `pmic_pwrkey` and IRQ 199 `Sensor` wakes **[OBS, second-hand here]**.
- Armada issues #274, #403 and PR #478 also use RTC s2idle cycles as a test method **[V]**.
- Sizing, derived **[U]**: 1 % of 6.17 Ah is about 62 mAh, so at the 4.3 A seen at 72-73 % the battery gains about 1 % per 52 s. Test B's 10-11 point overshoot is on the order of nine minutes of charging. A backstop would need to wake every few minutes to hold a 3-point margin.

## Where the notes disagree with each other or with earlier statements

| Topic | Statement A | Statement B | Resolution |
|---|---|---|---|
| Does fake suspend block Wi-Fi/Bluetooth? | An earlier working assumption, plus the repo doc's mention of "wifi rfkill around suspend (b584279)" (a real-suspend commit for RP5/Flip2/Mini V2), implies radios are blocked | rtc note: radio-suspend calls are commented out in `fake-suspend`; radios stay up and NetworkManager ignores sleep | The source wins **[V]**: in fake mode the radios stay on. The rfkill commit is on another device's real-suspend path, read only by commit title **[S]**. Whether HEAD's s2idle path blocks radios on the Thor was not checked |
| Default suspend mode | Software note: `suspend-dispatch#L8` defaults to `fake`. Firmware note: every SM8550 device ran `fake` as of 2026-08-05 | rtc note: `defaults.conf` defaults to `s2idle`, `device-env` forces `fake` only if `mem_sleep` lacks s2idle; `sleep.conf` absent on the device, s2idle confirmed | Compatible if dispatch's literal is overwritten by `device-env`, but untested. The Thor runs s2idle today **[OBS]** |
| Does the RTC alarm wake s2idle? | Software note: undocumented; the sibling `cq8725s` dtsi calls RTC registers "TZ-locked"; needs a device test | rtc note: 3-min and 10-min `rtcwake -m freeze` worked | The RTC results are second-hand here. Treat wake-by-RTC as likely, not proven for an unattended periodic backstop **[U]**. (First-hand, this session: both `rtcwake -m freeze` runs woke on time, 2026-10-08 10:43 and 10:58.) |
| Property 16 "verified live" | Software note records the fork's "Verified live on AYN Thor 2026-09-14: the firmware accepts SET property 16 (readback 1/0)" tagged **[V]** | Firmware note: that verifies only that the patch says it. Property 16 is `BATT_CHG_FULL_DESIGN` in mainline and QTI, the fork's "readback" prints `info.design_capacity`, and the fork never claims charging stopped | Treat as **[S]**, low confidence, not evidence of a working cap |
| What the fork clamps with | Fork: `charge_control_limit` = 1000 uA | Gleipnir / Armada 0903: `constant_charge_current` = 0 | Whether they are the same firmware control was never compared **[U]** |
| Nova firmware | Nova README: firmware "shared with the AYN Odin 2" | Armada's Odin 2 blobs lack the `limit_capacity_charge` strings that Thor and RP6 have | README claim unsupported by the blobs in the tree **[V]** |
| Per-device charger firmware | Maintainer: Thor got its own charger firmware 2026-08-02 (issue #89) | Thor, Odin 2 and RP6 `adsp_dtb.mbn` decode identically | Consistent only if the difference is in `adsp.mbn` (it is, for the `limit_capacity_charge` strings) **[V]** |
| Mainline line numbers | Firmware note cites `torvalds/linux@6c377d19d4a5` | Step note cites `@37689bc` | Same file, different revisions. Neither is the Thor's patched 7.2.6 tree, so line numbers do not transfer |
| Daemon keeps running in fake mode | rtc note: `system.slice` is untouched | Gleipnir's cgroup is unchecked | Holds only if Gleipnir is outside `app.slice`. Gleipnir's unit is in `system.slice` (observed 2026-10-08) |

## Conclusion

The notes change the question. A cap that "holds with nothing running" is not on offer from the kernel threshold path. The only firmware-held state known to survive s2idle on this Thor is the one Gleipnir already writes. The real design problem is when to write it. A clamp placed in the last moment before the CPU stops turns test A's hold into a cap, and what remains is policy, not mechanism.
- Clamp unconditionally and the battery never charges asleep.
- Clamp only near the cap and, at roughly 1 % per 52 s on this charger, a long sleep from lower down still overshoots unless something wakes the system to re-evaluate.

Two of the cheapest experiments are read-only and unlock several questions at once.
- The firmware log capture (`armada-charge-debug --ulog-only`) shows the `limit_capacity_charge` state, the step's FCC/FV/JEITA lines and any 0x48 handling in one run.
- `cat /proc/<pid>/cgroup` on Gleipnir decides whether fake sleep is a zero-code option.
- The unexplained 89 % step also matters for sizing the overshoot, since a firmware plateau near 0.91 A would bound how fast a long sleep can climb past the cap.

## Ranked fix options

| Rank | Option | Cost | Single cheapest test | Evidence it can work |
|---|---|---|---|---|
| 1 | **Pre-sleep clamp.** A root `pre` hook in `system-sleep`, or a daemon holding a logind delay inhibitor and clamping on `PrepareForSleep(true)` (release within 5 s), plus re-evaluation on `post`/resume. The hook covers s2idle only; the daemon variant also covers fake | A few lines. No charging while asleep once clamped. A policy floor (the fork uses 70 %) leaves lower sleeps unclamped. The hook must be short and not wait on user services. Install location on the OSTree image is unconfirmed (`/etc/systemd/system-sleep/` is a guess **[U]**) | Drop a `pre` script that logs a timestamp and writes `0` to `constant_charge_current`. Sleep from about 60-78 % on a charger for 15+ minutes. Confirm the log line, node 0 at wake, capacity unchanged within 1 % | Firmware holds the clamp through s2idle (test A) **[OBS]**; hook semantics **[V]**; the fork's hook exists but is untested in the field |
| 2 | **Fake sleep mode** (Decky Armada Control, Sleep type, Fake) so the existing 30 s daemon keeps polling | Zero code. Higher sleep drain (unmeasured), Wi-Fi/Bluetooth stay up, "unreliable" per issue #3, no system-sleep hooks run | `cat /proc/$(pgrep -f gleipnir)/cgroup` to confirm it is outside `app.slice`. Then sleep from 78 % on a charger for 15 minutes and check that capacity stops near 80 % and the daemon journal shows polls during sleep | `system.slice` keeps running **[V]**; `armada-powerd` fan-loop precedent **[V]**; the Nova project relies on it **[S]** |
| 3 | **RTC backstop.** Arm `wakealarm` (or a `WakeSystem=true` timer) every few minutes, poll, clamp or release, re-suspend. Can be combined with rank 1 so the clamp is released to top up below the floor | Wake power each cycle. Likely panel flash. Armada has no re-suspend handler, so the daemon must call `systemctl suspend`. Steam idle behaviour unknown. Charger Manager and `bwake` show 5-10 % scheduling error | `sudo rtcwake -m no -s 180`, then sleep normally. Read `/var/lib/armada/wake-ledger.log` for the RTC IRQ. Note whether the panel lights and whether the device re-sleeps | RTC freeze tests reported working **[OBS]**; no project uses it as a cap |
| 4 | **Property-16 `limit_capacity_charge` experiment.** The only route to a true no-userspace hold | A kernel patch (fork `0921`-style) built in Docker and flashed. Property 16 collides with `BATT_CHG_FULL_DESIGN`. Threshold, persistence and s2idle behaviour are unknown. SET errors are silent. A screen-off hazard is reported for threshold writes | Read-only first: `sudo armada-charge-debug --ulog-only --watch 120` on a charger, looking for `limit_capacity_charge=` and `curr_cap_state=` in the periodic line. Only then build the patch | Firmware strings exist **[V]**; the Android toggle works **[S]**; nobody has shown it holds through sleep **[U]** |
| 5 | **Kernel-side notifier** in `qcom_battmgr` that writes prop 10 = 0 on a battery event, like patch 0532 | Highest: kernel patch and rebuild. Works only if the firmware sends battery events during s2idle and the callback runs | A debug build whose notifier logs timestamps to the trace buffer. Sleep on a charger across a charge-state change and read `/sys/kernel/tracing` after wake | 0.5 s doorbell and notification **[V]** (patch author's claim); delivery during s2idle unobserved **[U]** |

Near-free diagnostics that prune the list, none a fix **[U]**:
- Time one write of `charge_control_end_threshold`. About 1.0 s indicates the `-ETIMEDOUT` case.
- Capture the firmware log during the write.
- Read dmesg for `unknown message`.
- Compare `journalctl -t gleipnir` across a sleep to see when the daemon wakes relative to the 88-89 % reading.

## Open questions

1. Does the 0x48 request reach the Thor firmware at all? Is the 0 readback cause (a) no answer, (b) accepted but unreported, or (c) missing `BATT_CHG_CTRL_EN`? No log, timing or rpmsg trace of a write exists.
2. What does `limit_capacity_charge` do on the Thor?
   - Which pmic_glink property or opcode sets it?
   - Does it fix the threshold at 80?
   - Does it persist in PMIC SDAM?
   - Is it applied while the AP is in s2idle?
   - AYN's `qti_battery_charger` source is not in `refs/`. Disassembling the Android module would settle the ID.
   - Does a toggle set in Android survive a reboot into Armada? An Odin 3 report shows Android-set 70/80 thresholds read under Linux **[S]**.
3. Is the 88-89 % in test B the moment the daemon woke or a firmware plateau, and how long was the sleep? Without that, the overshoot rate and the right wake interval are guesses. (Test B ran `rtcwake -m freeze -s 600`: 10:48:26 to 10:58:28, 78 % to 88 %, observed.)
4. What keys the 0.91 A step (voltage, OCV, SOC, thermal mask or input limit)?
   - Does `constant_charge_current` return the effective aggregate or only the HLOS vote?
   - Why do the decoded 4350 mV and 3000 mA defaults disagree with 4.4 V and 4.3 A?
   - Skin, connector and die temperatures during the plateau are unrecorded.
5. Does the Thor's on-device `adsp.mbn`/`adsp_dtb.mbn` match the clone's (`574da80`, 2026-10-02), given the device runs `20261006.9c7dd3e`? `refs/dts/thor_live.dts` is empty. `/etc/systemd/system-sleep/` and the sleep-debug drop-in on the device were not inspected, so "only two hooks" covers the clone only.
6. In which cgroup do Decky and the Gleipnir plugin process run? Does fake sleep leave Wi-Fi/Bluetooth up on the Thor, and what is its drain with CPUs in which idle states?
7. What lights the panel after an RTC wake? Does Steam re-suspend a plugged-in Thor after a timer wake? What causes the IRQ 199 `Sensor` wakes in the ledger?
8. What is systemd's per-hook timeout (`DEFAULT_TIMEOUT_SEC`)? How does `WatchdogSec=15` on `armada-powerd` behave across a long s2idle?
9. Would a kernel notifier get supply events in s2idle? Armada's own 0532 text leaves this open.
10. Does the Steam Deck EC retain `max_battery_charge_level` through suspend and EC reset? The driver source could not be retrieved, so the Deck precedent is inferred.
11. How does the fork's `60-thor-charge-limit` behave in practice? Does it race Armada's `armada-powerbutton-suspend` or wake-ledger hooks, which run in parallel with it?
12. Are the fork's `charge_control_limit` and Armada's `constant_charge_current` the same firmware control, and is a 1000 uA clamp equivalent to 0?
