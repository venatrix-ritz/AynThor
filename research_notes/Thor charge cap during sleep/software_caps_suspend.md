# Software battery charge caps across system suspend on Linux handhelds and laptops

Research date: 2026-10-08. Scope: how other projects keep a charge cap (for example 80 %) working across suspend, what each approach does while the system is suspended, and the documented failure modes.

Tags used on every claim:
- **[V]** verified in source: I opened the raw file this turn (raw upstream files were curled to the scratchpad and the quoted phrases grepped, so `#Lnn` refers to that raw file as read on 2026-10-08, master/main). HTML-only pages and pages read through a summarising fetch tool are tagged **[S]**, not [V]. Local clones are cited as `refs/<dir>@<sha7>:path#Lnn`. Clones I made in the scratchpad (not under `refs/`) are cited as a GitHub/GitLab permalink at the short SHA I read.
- **[S]** secondary: forum post, blog, search-result summary or a tool-summarised page. Not read as raw source.
- **[U]** unverified: stated as a gap or an inference, not backed by a source I read.

Local facts taken as given (not re-derived): the Thor (Armada OS, systemd, s2idle) clamps with a 30 s userspace poll writing `0` to a battery current-limit node; the daemon is frozen in native s2idle; a Thor sleeping at 78 % on a charger reached 88-89 % before the daemon woke.

Clone SHAs read: `refs/upstream/steamos-manager@08c45b5`, `refs/upstream/armada@574da80` (and fork branch `mgeeeek-thor@7e17352` inside the same clone), `refs/upstream/rocknix@9f8c79d`, `refs/upstream/jupiter-hw-support@3bd126b`, `refs/thor-android/thor-wayfinder@305d3ad`, `refs/thor-android/android_device_ayn_qcs8550-common@d5e669d`. Scratchpad clones: TLP `a4ea9ce`, UPower `bb7af5f`, asusctl `321b111`.

---

## Q1. SteamOS / Steam Deck: how does steamos-manager implement "max charge level", is the cap enforced by firmware/EC with nothing running in suspend, and is there a software fallback?

### Takeaway
steamos-manager does nothing more than write one sysfs attribute (`max_battery_charge_level` on the Deck's `steamdeck_hwmon`, or the standard `charge_control_end_threshold` on ACPI-battery devices such as ROG Ally and MSI Claw). It has no suspend/resume code and no software fallback, so the cap can only survive sleep if the firmware/EC holds it. That the EC does hold it on the Deck is plausible but I found no source that states it.

### Cited Findings
- The D-Bus property is `BatteryChargeLimit1.MaxChargeLevel` ("maximum allowable percentage for battery charging"; `-1` resets to default). [V] `refs/upstream/steamos-manager@08c45b5:data/interfaces/com.steampowered.SteamOSManager1.xml#L37-L45`
- Setting it calls `set_max_charge_level`, which validates 0-100 and queues one sysfs write to the resolved path. `-1` is mapped to `0`. [V] `refs/upstream/steamos-manager@08c45b5:steamos-manager/src/power.rs#L723-L728`; `…/src/manager/root.rs#L687-L698`
- The write target comes from per-device config. The enum `BatteryChargeLimitMethod` has exactly two variants: `AcpiSb` (default) and `HwmonAttribute{hwmon, attribute}`. [V] `refs/upstream/steamos-manager@08c45b5:steamos-manager/src/power.rs#L231-L239`
  - `AcpiSb` scans `/sys/bus/platform/drivers/acpi-battery/PNP0C0A:00/firmware_node/power_supply` (and the legacy ACPI path) for a `type == Battery` supply and uses its `charge_control_end_threshold`. [V] `…/power.rs#L64-L76`, `#L664-L704`
  - `HwmonAttribute` finds the named hwmon and writes the named attribute. [V] `…/power.rs#L695-L701`
- Steam Deck: `hwmon = "steamdeck_hwmon"`, `attribute = "max_battery_charge_level"`, `suggested_minimum_limit = 10`. [V] `refs/upstream/steamos-manager@08c45b5:data/devices/steam-deck.toml#L40-L45`
- ROG Ally series, ROG Xbox Ally and MSI Claw configs use `method = "acpi_sb"`, i.e. the generic kernel `charge_control_end_threshold`. [V] `refs/upstream/steamos-manager@08c45b5:data/devices/rog-ally-series.toml#L41-L42`, `data/devices/msi-claw-intel.toml#L39-L40`
- If a device has no `[battery_charge_limit]` section, the call fails with "No battery charge limit configured". There is no polling or userspace-clamp code path. [V] `…/power.rs#L664-L671`
- A grep for `suspend|sleep|resume|logind|login1|PrepareForSleep` over the `.rs`, `.xml`, `.toml`, `.md` and `.service` files, excluding CEC and tokio sleep lines, returned only: the HDMI-CEC `SuspendTv`/`SuspendDevice` properties, job pause/resume property docs, a `README.md#L26` line saying `org.freedesktop.login1` is a bus the Steam *client* uses, and `sleep(Duration...)` timeouts in `daemon/user.rs#L181` and `ds_inhibit.rs#L254`. I saw no `PrepareForSleep` subscription, inhibitor or reapply code. [V] grep run this turn over `refs/upstream/steamos-manager@08c45b5`
- Armada's SM8550 steamos-manager device config (`packages/steamos-manager/devices/sm8550.toml`, and the other SoC files) has no `battery_charge_limit` section, so Armada's Steam UI has no charge-limit slider path to the Thor's battery. [V] grep of `refs/upstream/armada@574da80:packages/steamos-manager/devices/` returned no match
- Valve's release note (as quoted by the article): "Added Battery Charge Limit control to Settings->Power … Limiting the charge limit to 80% can be beneficial for long term battery health." A reader asked whether it works suspended or powered off; the only reply was a guess, unconfirmed. One reader reported the battery charging past 80 % while gaming plugged in. [S] https://www.gamingonlinux.com/2025/05/steam-deck-gets-a-battery-charge-limit-control-in-the-latest-beta/ (read through a summarising fetch)
- A Decky Loader user said the older PowerTools plugin's limit "only limits the charge when the Deck is turned on" (userspace plugin behaviour, contrasted with the firmware-backed one). [S] search-result summary, Steam Community thread https://steamcommunity.com/app/1675200/discussions/2/4029096129889623076

### Inferences
- Because the manager never reapplies the value and has no sleep hook, the Deck design depends on the EC/firmware retaining and enforcing the number (the same assumption as the kernel `charge_control_end_threshold` ABI). The attribute lives in a hwmon driver that talks to the EC; I could not retrieve that driver source, so "EC enforces with nothing running" is the design intent inferred from the code shape, not a quoted statement. [U]
- There is no software fallback anywhere in steamos-manager. A device without a firmware threshold simply gets no slider. The Thor's own situation (firmware `charge_control_end_threshold` ignored) is exactly the case Valve's code does not cover.

### Gaps
- The Valve/mainline kernel driver that implements `max_battery_charge_level` (my fetches of `drivers/hwmon/steamdeck-hwmon.c`, `drivers/platform/x86/steamdeck.c`, `drivers/mfd/steamdeck.c` and `Documentation/hwmon/steamdeck-hwmon.rst` on torvalds/linux master all returned 404; `refs/upstream/jupiter-hw-support@3bd126b` has no reference to the attribute). So where the value is stored (EC RAM vs flash), whether it survives suspend, and whether it survives a full EC reset are unverified.
- Where Steam persists the user's chosen percentage and whether the Steam client re-sends it after resume: not found in the manager code (the client is closed source).

---

## Q2. TLP, UPower, GNOME/KDE, asusctl, ideapad_laptop / thinkpad_acpi: firmware threshold vs userspace; any use of systemd-sleep hooks or logind inhibitors?

### Takeaway
Every one of these tools only writes the standard firmware-backed `charge_control_{start,end}_threshold` attributes. None polls charge level to enforce a cap. What differs is whether they reapply after resume: TLP and asusd do (because ASUS, Huawei and LG firmware is known to lose the value across suspend), UPower does not (it restores only at battery attach/daemon start), and KDE PowerDevil is still proposing it. The kernel ABI itself says nothing about persistence.

### Cited Findings
**Kernel ABI**
- `charge_control_end_threshold`: "Represents a battery percentage level, above which charging will stop"; not all hardware can use arbitrary values; drivers round; reading back shows the value actually set. The ABI file does not say who enforces it or whether it persists. [V] https://raw.githubusercontent.com/torvalds/linux/master/Documentation/ABI/testing/sysfs-class-power#L362-L370 (raw file, grepped)
- `charge_behaviour` offers `auto`, `inhibit-charge`, `inhibit-charge-awake` ("inhibit-charge only when device is awake", line 514) and `force-discharge`. [V] same file. The existence of an "awake-only" variant shows the kernel ABI distinguishes charge inhibition that persists in sleep from one that does not.
- `charge_control_limit` (maximum charging current) and `charge_control_limit_max` are documented from line 335 as charge-rate throttling; `constant_charge_current` is not described in that file. [V] same file
- thinkpad_acpi documents `charge_control_start_threshold` (0-99) and `charge_control_end_threshold` (1-100) and refers to the ABI file; the section I grepped says nothing about firmware storage or persistence. [V] https://raw.githubusercontent.com/torvalds/linux/master/Documentation/admin-guide/laptops/thinkpad-acpi.rst#L1616-L1620
- asus-wmi: the comment says "There isn't any method in the DSDT to read the threshold", so the driver caches the written value (L1600); `asus_wmi_battery_add()` resets the threshold to 100 with the comment "The charge threshold is only reset when the system is power cycled, and we can't read the current threshold, however the majority of platforms retains it" (L1638-L1640). [V] https://raw.githubusercontent.com/torvalds/linux/master/drivers/platform/x86/asus-wmi.c#L1600-L1640 (full file curled; a grep for resume/restore lines mentioning charge/battery/threshold matched nothing)

**TLP**
- TLP installs a systemd-sleep hook: `case $1 in pre) tlp suspend ;; post) tlp resume ;; esac`, installed to `/usr/lib/systemd/system-sleep/tlp` (elogind variant `49-tlp-sleep`). [V] https://github.com/linrunner/TLP/blob/a4ea9ce/tlp-sleep#L7-L10, https://github.com/linrunner/TLP/blob/a4ea9ce/Makefile#L213-L216
- On `resume`, TLP reapplies thresholds only for specific hardware: `init_batteries_thresholds "asus huawei lg"`, with the code comment "Specific hardware which resets the EC when resuming … apply charge thresholds". For other vendors it reapplies only when the power source changed to battery and `RESTORE_THRESHOLDS_ON_BAT=1`. [V] https://github.com/linrunner/TLP/blob/a4ea9ce/tlp.in#L448-L473
- The `suspend` branch contains no threshold handling (it saves rfkill state and applies a few settings). [V] https://github.com/linrunner/TLP/blob/a4ea9ce/tlp.in#L411-L446
- TLP's ASUS plugin notes that the ASUS EC threshold "cannot be read" and, since kernel 7.1, reading after boot returns `-ENODATA` until the first write. [V] https://github.com/linrunner/TLP/blob/a4ea9ce/bat.d/89-asus#L96-L100
- TLP docs: "Charging stops when the battery level reaches or exceeds the stop charge threshold"; after `tlp fullcharge`/`recalibrate` the thresholds "stay at the vendor specific defaults until the next reboot". [V] https://linrunner.de/tlp/settings/battery.html
- The ThinkPad plugin reads the threshold sysfile a second time to mitigate "the annoying firmware issue on ThinkPad A/E/L/S/X series" (TLP issue #369). [V] https://github.com/linrunner/TLP/blob/a4ea9ce/bat.d/05-thinkpad#L397-L399

**UPower (the D-Bus service desktop battery-health UIs call; GNOME's own UI code was not read)**
- UPower reads/writes `charge_control_start_threshold`/`charge_control_end_threshold`, or `charge_types`, and records the on/off state in a state file `charging-threshold-status`. [V] https://gitlab.freedesktop.org/upower/upower/-/blob/bb7af5f/src/linux/up-device-supply-battery.c#L170-L224, https://gitlab.freedesktop.org/upower/upower/-/blob/bb7af5f/src/up-device-battery.c#L440-L496
- It restores the threshold from that file only when a battery appears (`if (!priv->present) { … recover_battery_charging_threshold … }`), not on resume. [V] https://gitlab.freedesktop.org/upower/upower/-/blob/bb7af5f/src/up-device-battery.c#L536-L541
- On logind `PrepareForSleep` (going-to-sleep case) UPower takes a *delay* inhibitor named "Pause device polling" and, on wake, calls `up_device_refresh_internal(device, UP_REFRESH_RESUME)` for every device. The RESUME refresh reason only resets power-estimation history; it does not touch thresholds. [V] https://gitlab.freedesktop.org/upower/upower/-/blob/bb7af5f/src/linux/up-backend.c#L817-L868, https://gitlab.freedesktop.org/upower/upower/-/blob/bb7af5f/src/up-device-battery.c#L262-L265
- A UPower-driven kernel interaction: `upowerd` could not turn preservation off on Qualcomm laptops because the battmgr driver rejected a start threshold of 0 (range [50-95]); a clamping patch was applied. [S] cover letter via https://patchew.org/linux/20251012233333.19144-2-val@packett.cool (HTML page read through a summarising fetch)

**KDE PowerDevil**
- [S] (HTML page read through a summarising fetch) MR !621 "Persist battery charge thresholds across reboots and resume": "many laptops, including ASUS, some Lenovo, and Samsung models, reset charge thresholds to hardware defaults on every power cycle or resume from suspend"; PowerDevil reads but never restores them. The MR saves the values in `powerdevilrc` and calls `readChargeThreshold()` on resume, writing through the existing KAuth helper. Tested on one ASUS model; the page shows the branch as "requested to merge" and names no release; the description I read does not mention a logind PrepareForSleep hook. [S] https://invent.kde.org/plasma/powerdevil/-/merge_requests/621

**asusctl / asusd**
- asusd subscribes to logind `PrepareForSleep` (and polls `on_external_power` and `lid_closed` every 2 s) and, in the callback, reapplies `charge_control_end_threshold` from its config when the signal says the system is *waking* (`!sleeping`). [V] https://gitlab.com/asus-linux/asusctl/-/blob/321b111/asusd/src/lib.rs#L205-L295, https://gitlab.com/asus-linux/asusctl/-/blob/321b111/asusd/src/ctrl_platform.rs#L846-L861
- A commented-out block shows asusd stopped reading/saving the threshold at suspend after "some kind of issue reported"; the config value is trusted instead. [V] https://gitlab.com/asus-linux/asusctl/-/blob/321b111/asusd/src/ctrl_platform.rs#L850-L857
- asusd resets the threshold to its stored base on unplug (after a one-shot full charge) and on shutdown. [V] https://gitlab.com/asus-linux/asusctl/-/blob/321b111/asusd/src/ctrl_platform.rs#L139-L155, `#L905-L950`

**Other laptops**
- Librem 14 EC: "The Librem EC firmware manages the battery charge parameters"; the EC rejects end <= start and start < 20 %. The page is silent on persistence. [S] https://docs.puri.sm/Hardware/Librem_14/Tips/battery_charging_thresholds.html
- System76: thresholds are lost on an EC reset (full shutdown with power unplugged) and firmware dated 2025-07-24 or earlier did not persist them; their docs suggest a boot-time systemd unit. [S] search-result summary of https://github.com/system76/docs/pull/1316/files
- Framework: the limit sits in the EC; one user reports `ectool fwchargelimit` reverts to the BIOS value after shutdown; several users report the limit "occasionally ignored"; kernel `cros_charge-control` refuses to load on Framework by default; users reapply with a systemd unit/timer. No source addresses suspend explicitly. [S] https://community.frame.work/t/battery-charge-threshold-bios-vs-os/69814/6 (fetched; the timer/unit approach and `Persistent=true` are quoted there); https://community.frame.work/t/battery-charge-limit-occasionally-ignored/62998 (search-result summary only)
- batlimit (Rust CLI): `persist` creates `/etc/systemd/system/batlimit-TARGET.service` for the targets `hibernate`, `hybrid-sleep`, `multi-user`, `sleep`, `suspend`, `suspend-then-hibernate`; i.e. it reapplies the sysfs value around sleep transitions. Unit contents not read. [S] https://libraries.io/cargo/batlimit (repo https://github.com/pepa65/batlimit)

### Inferences
- The consistent pattern is: firmware holds the threshold, userspace's only job is to re-send it when firmware is known to forget (ASUS, Huawei, LG per TLP; ASUS/Lenovo/Samsung per KDE MR). None of them runs anything *during* sleep, because none needs to.
- Mechanism choices seen: a static `system-sleep` script (TLP, `post` only does the reapply), a logind `PrepareForSleep` D-Bus subscriber (asusd, UPower), and systemd units ordered on sleep targets (batlimit). UPower takes a logind delay inhibitor named "Pause device polling" (to pause polling, not to protect a cap). asusctl's `asus-shutdown` helper takes a logind inhibitor with `InhibitType::Shutdown` ([V] https://gitlab.com/asus-linux/asusctl/-/blob/321b111/asus-shutdown/src/main.rs#L148-L149; what it does with it was not read). I found no inhibitor in steamos-manager (see Q1) or in TLP's hooks.
- None of these is a precedent for software enforcement of the cap itself, because they all rely on hardware that enforces by itself; the Thor, with a threshold node the firmware ignores, is outside what these tools were built for.

### Gaps
- Exact contents of batlimit's unit files (whether `Before=sleep.target`, `StopWhenUnneeded`, or a hook) were not read.
- Whether `ideapad_laptop` conservation mode persists across suspend: no source found. thinkpad_acpi's persistence in EC is not stated in kernel docs.
- GNOME's own charge-limit UI code (gnome-control-center / gnome-settings-daemon) was not read; the UPower side above is what it calls.
- KDE !621 merge status not confirmed.

---

## Q3. ROCKNIX, postmarketOS, Ayaneo/Retroid/Odin-class and Qualcomm devices: how do they cap at 80 %, what is reported during sleep, and does anything use RTC wake alarms?

### Takeaway
I found no ROCKNIX or postmarketOS charge-cap implementation. The Qualcomm battery manager (qcom_battmgr) stores thresholds in firmware nvmem, which is the strongest evidence of firmware-held caps on Qualcomm hardware, but on the Thor's SM8550 firmware that generic threshold is ignored. AYN's own Android uses a vendor sysfs flag (`limit_capacity_charge`), and Armada forks expose the same flag. No handheld/laptop project that I found uses RTC wake alarms to enforce a cap; the nearest are an in-kernel Charger Manager (temperature monitoring) and a user script (`bwake`, a charge-time reminder).

### Cited Findings
**ROCKNIX / postmarketOS**
- Search of the sparse ROCKNIX clone for `charge_control_end`, "charge limit", "battery … limit" finds no charge-cap feature. The only charger-related hit is an SM8250 pm8150b fuel-gauge patch with temperature thresholds. [V] `refs/upstream/rocknix@9f8c79d` (sparse checkout: `projects/ROCKNIX/devices/SM8250/patches/linux/0011-qcom-pm8150b-charger.patch`; absence is limited to what the sparse clone contains)
- A Pine64 forum thread says the postmarketOS Tweaks app has a GUI for a maximum charge level, but that on one Debian setup it did not work and the value reverted. I could not find the pmOS wiki page itself. [S] https://forum.pine64.org/printthread.php?tid=13615 (search-result summary only)

**Qualcomm battery manager (qcom_battmgr)**
- Mainline qcom_battmgr exposes `charge_control_start/end_threshold` on SM8550-class batteries (visible as context lines in Armada's patch). [V] `refs/upstream/armada@574da80:packages/kernel/patches/0903-power-supply-qcom-battmgr-expose-the-charge-current-limit.patch` (hunks showing `BATT_CHG_CTRL_START_THR` / `BATT_CHG_CTRL_END_THR` and `charge_ctrl_end`)
- Qualcomm reviewer text on the battmgr series: "these thresholds are stored in nvmem and they won't be reset until battery is unplugged or completely drained". It is a reply in the thread; I attribute it to Qualcomm's Fenglin Wu on the strength of a search summary only (author line not checked). [V] raw message text https://lkml.iu.edu/2511.2/02578.html (lines 94-95) and https://lkml.iu.edu/2511.2/03172.html (line 85). The [50-95] range and the 50 % floor rationale come from the cover letter and replies via a summarising fetch. [S] https://patchew.org/linux/20251012233333.19144-2-val@packett.cool
- On the Thor, Armada `20261006.9c7dd3e` (kernel 7.2.6): `charge_control_end_threshold` reads `0` and a write of 80 reads back `0`; the firmware ignores it. [V] `docs/hardware/device-observed.md` (local observed 2026-10-07; cited, not re-derived)
- Armada patch `0903` exposes the firmware's `BATT_CHG_CTRL_LIM` as `constant_charge_current`; writing `0` stops battery charging while the charger powers the system. [V] `refs/upstream/armada@574da80:packages/kernel/patches/0903-power-supply-qcom-battmgr-expose-the-charge-current-limit.patch#L1-L8`
- Armada's Thor device tree configures the PMIC RTC node `pmk8550_rtc`. The device tree stores a wall-clock offset in an SDAM nvmem cell. On the related `cq8725s` file the comment states "RTC regs are TZ-locked; persist the wall-clock offset in an SDAM nvmem cell". [V] `refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi#L1418-L1421`, `…/cq8725s-ayn-common.dtsi#L1458-L1470`

**AYN Android and Armada forks (Thor-specific prior art)**
- Stock AYN Android exposes "Stop at 80 %" as `Settings.System.percent_80_charge_limit`, applied by AYN's settings app to `/sys/class/qcom-battery/limit_capacity_charge`; Wayfinder's author records it as verified on a Thor on 2026-10-01 and notes it stops charging at 80 % but does not discharge a fuller battery. [V] `refs/thor-android/thor-wayfinder@305d3ad:app/src/main/java/app/wayfinder/Charging.kt#L9-L22`. Whether the stock app re-writes the node at wake/boot, or the kernel/firmware holds it while the screen is off, is not shown there.
- LineageOS for the same SoC family wires its health HAL charging-control to `/sys/class/qcom-battery/charging_enabled`. [V] `refs/thor-android/android_device_ayn_qcs8550-common@d5e669d:common.mk#L192`
- MgeeeeK's kernel fork (`MgeeeeK/armada-packages`, branch `thor`) patch `0921` routes `charge_control_end_threshold` on SM8550 to "the firmware's own 80% capacity limit", property 16 (`BATT_AYN_LIMIT_CAPACITY`), with the log text "Verified live on AYN Thor 2026-09-14: the firmware accepts SET property 16 (readback 1/0)". It sets the cached end/start to 80/75 when enabled. [V] downloaded and read this turn: https://api.github.com/repos/MgeeeeK/armada-packages/contents/kernel/patches/0921-power-supply-qcom-battmgr-ayn-limit-capacity.patch?ref=thor
- The fork's own comment in the patch says only that the SET "toggles the firmware's own 80% capacity limit"; it does not claim the firmware holds the cap while suspended. [V] same patch header
- The same fork's userspace script `thor-charge-limit` sets the firmware flag at boot, then runs a 30 s poll that clamps `charge_control_limit` to 1000 µA at ≥80 % on charger and releases at ≤77 % or when unplugged. Its header notes both mechanisms are used together. [V] `refs/upstream/armada@7e17352:system_files/usr/libexec/armada/thor-charge-limit#L1-L29`
- A repo doc written earlier states that which of the two actually holds the battery at 80 % is not verified. [V] `docs/armada/forks-and-related.md` (local, "[UNVERIFIED — no device access]" about the fork)
- AYN Odin 3: AYN announced an 80 % charge limit feature in Discord ahead of release (press report only). [S] https://steamdeckhq.com/news/ayn-odin-3-charge-limits-oled-burn-in-protection/

**LineageOS / Android charging control**
- LineageOS added a health HAL for user-selectable max charge or a charge-by-time deadline; vendor config has `TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_{BYPASS,DEADLINE,TOGGLE}` flags and path variables. [S] search-result summaries of https://gitlab.e.foundation/e/os/android_vendor_lineage/-/commit/2decc6661eb87a36d64a4aaa9ce7c5a0cda27563 and https://gitlab.com/CalyxOS/calyxos/-/issues/3203
- CalyxOS proposed dropping the Lineage health HAL from build 6.6.22-2 while its charging-control bugs are fixed; Lineage disabled it on Pixels in a 2025 22.2 nightly for a "pretty severe bug" with blips of charge/not charge. [S] https://gitlab.com/CalyxOS/calyxos/-/issues/3203 (search summary)
- A LineageOS 19 user reported a third-party charge-limit app (writes `charging_enabled` 1→0 at the threshold) still charging to 100 % after the display switched off. [S] https://www.android-hilfe.de/forum/root-custom-roms-modding-fuer-oneplus-6.3349/los-19-battery-charge-limiter-nicht-mehr-zuverlaessig.1003843.html (search summary). This is the closest documented report of the Thor's exact failure mode (userspace limiter, device asleep).

**RTC wake alarms**
- Kernel Charger Manager (in-tree) exists because userspace polling during suspend would wake processes: "incurs unnecessary power consumption and slow down charging process"; it wakes the system with an RTC alarm, saves/restores any earlier alarm, and `cm_suspend_again()` returns true to suspend again if the wake was only for monitoring. Its documented duty is temperature monitoring and recharge handling, not an SOC cap. [V] https://raw.githubusercontent.com/torvalds/linux/master/Documentation/power/charger-manager.rst#L37-L46 (motivation), `#L82` (`rtc_only_wakeup`), `#L97-L102` (`cm_suspend_again`)
- `bwake`: a Bash script that estimates time to a target (default 80 %), suspends with `rtcwake`, and sounds an alarm; the README warns the result may land "~ 5%-10%" above/below the threshold, and it suggests `sudo` to avoid a password prompt each sleep. It reminds you to unplug; it does not stop charging. [V] https://raw.githubusercontent.com/helium18/bwake/master/README.md#L13, `#L27-L28`
- An old Android `healthd` change removed a periodic RTC wakeup from suspend because the MSM PMIC already raises a low-battery interrupt; the commit says a design without HW low-battery interrupt must enable the timer to poll. [S] search-result summary of https://gitlab.e.foundation/e/os/android_system_core/-/commit/7c92abfb15354c7d55a44a3bde556682ce076d8b
- systemd timers can wake a suspended machine with `WakeSystem=true` ("an elapsing timer will cause the system to resume from suspend"; the manager "will not take care of suspending it again"; privileged, effectively system manager only). With `WakeSystem=true` the monotonic clock used is CLOCK_BOOTTIME rather than CLOCK_MONOTONIC. [V] https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.timer.xml#L408-L420 (the "requires privileges / system manager" sentence came through the fetch tool and was not grepped)
- Without `WakeSystem=`, an `OnCalendar=` timer that elapses in sleep is not acted on until resume, then runs once ("catch up", `#L218`). [V] same page
- Documented side effects of periodic waking: Charger Manager text above (power cost, and "such peak power consumption can stop chargers in the middle of charging"). [V] charger-manager.rst. For handhelds, the Armada wake-ledger hook exists because "pm_wakeup_irq only keeps the LAST wake", i.e. the project already tracks wake causes for drain reports. [V] `refs/upstream/armada@574da80:system_files/usr/lib/systemd/system-sleep/40-armada-wake-ledger#L1-L10`

### Inferences
- The likeliest candidate for a *firmware-held* 80 % cap on the Thor is the AYN firmware property 16 / `limit_capacity_charge` flag (the thing stock Android toggles), not `charge_control_end_threshold`. Whether property 16 is enforced by the ADSP/PMIC while the application processor is in s2idle is not shown by any source I read; it is testable on the device (set the flag, sleep on a charger across the 80 % boundary, compare). [U]
- Qualcomm's "stored in nvmem" statement about the generic threshold, together with the Thor reading `0` and ignoring writes, suggests the Thor's firmware simply does not implement that property, which is consistent with `0922` in the fork saying GETs of properties 25/26 "always return 0" on AYN firmware (that claim is from the earlier local note quoting the fork's patch text). [U]
- A periodic RTC wake is feasible in principle (systemd `WakeSystem=` or `/sys/class/rtc/rtc0/wakealarm`), but no project I found uses it as a charge cap. Documented costs are wake power, interrupting charging or sleep depth, and an estimate error when scheduling (bwake: 5-10 %). The Thor's `pmk8550_rtc` exists and its alarm is not marked disabled in the dts I read, but I did not verify that an alarm can wake s2idle there. [U]

### Gaps
- No ROCKNIX or postmarketOS wiki/documentation page on charge limiting was found (searches returned nothing relevant); no Ayaneo or Retroid specific implementation was found. Evidence for Ayaneo/Retroid Linux handhelds is absent from my sources.
- Whether the stock AYN Android settings app re-asserts `limit_capacity_charge` after resume, and whether the node is enforced in sleep, is not documented in any file I read.
- The Thor's RTC alarm/wake capability (`wakealarm` write, `rtcwake -m no`, and whether `pmk8550_rtc` is a wakeup source in s2idle) is not documented in the repo or kernel sources I read; the dts says the RTC registers on a sibling SoC are "TZ-locked", so on-device test is needed. [U]
- LineageOS charging-control internals (does it use AlarmManager for deadline mode, does it re-write after wake) were not read from source; only commit/issue titles via search summaries.

---

## Q4. Pre-sleep clamp: a systemd-sleep pre hook that writes the limit before suspend and a post hook that re-evaluates. Any published implementation, and the trade-offs?

### Takeaway
One published implementation exists for exactly the Thor: the `60-thor-charge-limit` hook in the MgeeeeK/thor-armada fork. It clamps before sleep when on charger at ≥70 % and restarts the poll service on resume. Its trade-off (no charging in sleep once clamped) follows from its design but is not written down anywhere I found; the 70 % pre-threshold also leaves an overshoot window for sleeps that begin below 70 %.

### Cited Findings
- The hook, verbatim logic: `pre`: if `qcom-battmgr-usb/online` is 1 and capacity ≥ 70, write `1000` to `charge_control_limit`; `post`: `systemctl restart thor-charge-limit.service`. Header: "Thor 80% limit across sleep: clamp before suspend when on charger at >=70%, re-evaluate after resume." [V] `refs/upstream/armada@7e17352:system_files/usr/lib/systemd/system-sleep/60-thor-charge-limit#L1-L9`
- The service runs the 30 s poll loop and `ExecStopPost` rewrites the node to `charge_control_limit_max`; `Restart=always`. So the `post` restart briefly releases the clamp (ExecStopPost) then re-evaluates in the script start-up. [V] `refs/upstream/armada@7e17352:system_files/usr/lib/systemd/system/thor-charge-limit.service#L1-L13`; `…/usr/libexec/armada/thor-charge-limit#L14-L20`
- The clamp value is a low current (1000 µA), not `0`. In this fork `charge_control_limit` is a different kernel ABI name from Armada's `constant_charge_current`. [V] script above; `docs/armada/forks-and-related.md`
- systemd-sleep semantics that bound this design: hooks run "Immediately before entering system suspend" with arguments `pre <action>` and "Immediately after leaving" with `post <action>`; all executables in the directory "are executed in parallel" and the action does not continue until they finish; `user.slice` is frozen while they run; hooks "should be considered hacks … intended for local use only". `SYSTEMD_SLEEP_ACTION` is exported. [V] https://raw.githubusercontent.com/systemd/systemd/main/man/systemd-suspend.service.xml#L53-L94
- Hooks do not get a chance to run during sleep: they run at the two boundaries only (same page).
- TLP's `pre`/`post` hook is the same shape (`tlp suspend` / `tlp resume`) but neither side touches charge thresholds except the `post` reapply for ASUS/Huawei/LG. [V] https://github.com/linrunner/TLP/blob/a4ea9ce/tlp.in#L448-L473
- In Armada's "fake" mode the dispatcher `exec`s `fake-suspend` and never calls `systemd-sleep`, so `/usr/lib/systemd/system-sleep/` hooks are not run for fake suspend. Only for `s2idle` does it exec `systemd-sleep suspend`. [V] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/suspend-dispatch#L10-L12`, `#L29-L35`; consistent with `50-armada-powerbutton-suspend`, whose `post` branch exits early when `ARMADA_SUSPEND_MODE` is `fake` (`refs/upstream/armada@574da80:system_files/usr/lib/systemd/system-sleep/50-armada-powerbutton-suspend#L76`); this is an inference about which paths run hooks, not a quoted statement
- A logind `delay` inhibitor can hold up the sleep transition for at most `InhibitDelayMaxSec`, default 5 s, "before the inhibitor is ignored and the operation executes anyway". [V] https://raw.githubusercontent.com/systemd/systemd/main/man/logind.conf.xml#L179-L185
- KDE's PowerDevil and asusd both use the *post*-wake direction (reapply on resume) via logind's `PrepareForSleep`, not a pre-sleep clamp; a pre clamp is not their need because firmware holds the cap through sleep. [V] sources under Q2

### Inferences
- The local overshoot (sleep began at 78 %) falls inside the fork hook's >=70 % window, so that hook would have clamped it; the residual exposure is sleeps that start below 70 % on a charger. [U] derived from the hook code and the given local observation, not tested.
- With a pre-sleep clamp that writes `0` (or 1000 µA) and a post-resume re-evaluation, the battery will not charge for the whole sleep once clamped. If the Thor sleeps at e.g. 50-79 % on a charger it stays there until a wake. That is the inherent price of enforcing in userspace without a periodic wake; it is the direct opposite of the observed overshoot (88-89 %), trading "charges past cap" for "doesn't charge". The fork's code makes this trade at a fixed floor of 70 %. [U] not stated in any source; derived from the code.
- Because the fork only clamps when capacity ≥ 70 %, a sleep that starts at 60-69 % on a charger leaves charging unclamped for the whole sleep, so overshoot is still possible. [U] derived from the hook; no field report found.
- A cleaner variant of the same idea, which no source I found implements: compute the headroom in `pre` (cap − current) and clamp only when the remaining charge-to-cap time is shorter than a worst-case sleep, or clamp unconditionally and rely on the post hook to unclamp when below cap. Not published. [U]
- Parallel hook execution means a hook must not depend on another hook's side effects (documented), and must be short because `systemd-sleep` blocks on it.

### Gaps
- No field reports on how `60-thor-charge-limit` behaves in practice (the fork's authors state no device verification in the docs I read; the earlier local note lists the effect as unverified).
- No published implementation of a pre-clamp/post-reevaluate scheme for non-Thor hardware was found beyond batlimit's sleep-target units (contents unread) and the reapply-on-resume pattern.
- I did not confirm whether `systemd-sleep` hooks run in parallel with Armada's `armada-powerbutton-suspend`/`wake-ledger` in a way that would race a charge-limit hook; no such interaction is documented.

---

## Q5. Can a service keep running during suspend with s2idle, or only with a 'fake' software suspend?

### Takeaway
No for real s2idle: the kernel freezes user space, so a daemon (including a root system service) does not run until a wake event thaws it. Yes for Armada's fake suspend, which only freezes the user session's `app.slice` (or SIGSTOPs its processes) and leaves system services running.

### Cited Findings
- s2idle is described as "freezing user space, suspending the timekeeping and putting all I/O devices into low-power states"; sleep states are "global low-power states of the entire system in which user space code cannot be executed"; wake is "by in-band interrupts". Line refs `#L14`, `#L33`, `#L38` of the raw rst. The page does not say whether timers can wake the system. [V] https://raw.githubusercontent.com/torvalds/linux/master/Documentation/admin-guide/pm/sleep-states.rst
- The freezer: "user space processes and some kernel threads are controlled"; frozen tasks loop "until it is woken by an explicit TASK_FROZEN wakeup"; "Kernel threads are not freezable by default"; freezable tasks are "all user space tasks and some kernel threads". [V] https://raw.githubusercontent.com/torvalds/linux/master/Documentation/power/freezing-of-tasks.rst#L10, `#L19`, `#L33-L34`, `#L106`
- systemd's own contribution is separate: systemd-suspend freezes `user.slice` while sleep hooks run. System services (system.slice) are not frozen by systemd; the kernel freezer is what stops them. [V] https://raw.githubusercontent.com/systemd/systemd/main/man/systemd-suspend.service.xml
- Armada's fake suspend: "Real suspend hangs this SoC. Runs as systemd-suspend.service and blocks until woken". It mutes audio, grabs input, turns the display off, then `freeze_processes`: first it writes `1` to the `cgroup.freeze` of the session user's `app.slice`; only on failure it SIGSTOPs processes in the gamescope session cgroup except a keep-list. Nothing in this script touches system.slice. It then calls `armada-power suspend` and `suspend_runtime_pm` (runtime PM on the USB controllers). [V] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/fake-suspend#L1-L4`, `#L71-L98`, `#L114-L132`
- Armada selects between fake and s2idle via `ARMADA_SUSPEND_MODE`; s2idle is written to `/sys/power/mem_sleep` only when advertised, with fallback to fake on any failure. [V] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/suspend-dispatch#L14-L35`; `…/device-quirks#L58-L75`
- Waking an s2idle system needs an interrupt source; the charger-manager design (RTC alarm saved/restored, `cm_suspend_again`) is the in-kernel precedent for waking just to monitor. [V] https://raw.githubusercontent.com/torvalds/linux/master/Documentation/power/charger-manager.rst
- Local observation (given): in native s2idle on the Thor the 30 s daemon is frozen and the battery overshoots (78 % → 88-89 %).

### Inferences
- A userspace poller cannot run during s2idle; the only ways to get code to run are (a) a wake event (RTC alarm, power key, charger IRQ), (b) in-kernel or firmware logic, or (c) a fake-suspend style mode that never really suspends the CPU. In fake mode a system-service daemon keeps running (it is outside `app.slice`), but the device does not reach s2idle power levels. [U] for the claim that a *given* Decky plugin or Gleipnir is outside the frozen cgroup: it depends on which cgroup it runs in, which I did not check.
- Armada release `20260926` notes lower sleep power use on SM8550 (most devices about 50 % less battery drain). s2idle is a configured choice: `suspend-dispatch` defaults `ARMADA_SUSPEND_MODE` to `fake`. [V] `refs/upstream/armada@574da80:system_files/usr/libexec/armada/suspend-dispatch#L8`; the drain figure is per `docs/armada/sleep-battery.md` (local, citing `refs/_gh/releases/20260926.json`)

### Gaps
- Whether the Thor's s2idle can be woken by `pmk8550_rtc` alarm and what a periodic wake costs in drain on this device: not documented; needs an on-device test (`rtcwake -m no`/`wakealarm`, wake-ledger log).
- Whether the charger's own IRQ (for example a UCSI/PMIC "charge state" interrupt) wakes s2idle at a cap crossing: not checked. Armada's wake-ledger records `pm_wakeup_irq` per resume on the device and would show this.
