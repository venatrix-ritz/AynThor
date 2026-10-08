# Thor-related issues and PRs (armada-os/armada)
> Scope: every issue/PR in the GitHub export that mentions Thor (word match, incl. Thor Lite) or carries the device: ayn-thor label · Researched: 2026-10-03 · Confidence: high for metadata; summaries are title-level only (bodies not read)

## Summary
- Export (2026-10-02): 342 issues, 258 PRs total. Thor-related: **53 issues** (27 open) and **23 PRs**. Issues with label `device: ayn-thor`: 28. [src: refs/_gh/issues.json] [src: refs/_gh/prs.json]
- Labels in use: blocked, bug, dependencies, device: all, device: ayaneo-pocket-dmg, device: ayaneo-pocket-ds, device: ayaneo-pocket-s, device: ayn-odin-2, device: ayn-odin-2-portal, device: ayn-odin-3, device: ayn-thor, device: generic, device: konkr-pocket-fit, device: retroid-pocket-5, device: retroid-pocket-6, device: unknown, documentation, enhancement, for-triage, github_actions, hardware: dual-screen, new-device, soc: SM8550. [src: refs/_gh/issues.json]
- Match rule: regex bthorb|thor-?lite on title+body (+headRefName for PRs) or a label containing "thor". Many hits are multi-device reports (Odin 3/Odin 2) that merely mention Thor.

## Issues
| # | state | opened | closed | labels | title |
|---|---|---|---|---|---|
| #8 | closed | 2026-06-09 | 2026-06-14 |  | AYN Thor |
| #17 | closed | 2026-06-18 | 2026-06-24 |  | Joystick calibration tool |
| #28 | closed | 2026-06-22 | 2026-07-19 |  | AYN Thor Second Screen |
| #35 | closed | 2026-06-28 | 2026-07-30 |  | AYN Thor Not Recognizing SD Card After Flashing With balenaEtcher |
| #39 | open | 2026-06-30 |  |  | Right stick ghost input on game start up |
| #43 | open | 2026-07-01 |  | enhancement | OLED burn-in protection |
| #57 | closed | 2026-07-03 | 2026-07-15 |  | AYN Thor Very Very Hot |
| #58 | closed | 2026-07-04 | 2026-09-25 |  | MangoHud Performance Impact |
| #61 | closed | 2026-07-04 | 2026-08-03 | device: ayn-thor | Bug: AYN Thor doesn't reliably switch to fast charging |
| #68 | closed | 2026-07-05 | 2026-07-15 |  | Unable to change host name |
| #72 | closed | 2026-07-06 | 2026-07-09 |  | Bootc making it seemingly impossible to install anything that's not from bazaar |
| #76 | closed | 2026-07-07 | 2026-07-15 |  | controller not working in games |
| #89 | open | 2026-07-13 |  | bug, device: ayn-thor, device: ayn-odin-2, device: ayn-odin-3, device: retroid-pocket-6, device: konkr-pocket-fit, device: ayaneo-pocket-s | Bug: Charging limited to ~4W in Armada, 0W when powered off |
| #107 | open | 2026-07-16 |  |  | Pocket konkr fit 8 elite support |
| #109 | closed | 2026-07-17 | 2026-07-31 |  | Glorious Eggroll not in available compatibility options |
| #126 | closed | 2026-07-19 | 2026-08-17 | device: ayn-thor | CPU/GPU stuck on balanced power profile Ayn thor |
| #129 | closed | 2026-07-19 | 2026-08-03 | device: ayn-thor | Dual Screen Device Improvements |
| #131 | closed | 2026-07-20 | 2026-09-25 | device: ayn-thor, device: retroid-pocket-6 | X-Y Swapped on face buttons - Waydroid |
| #145 | closed | 2026-07-23 | 2026-07-24 |  | Crashing, currently observing/testing. |
| #154 | closed | 2026-07-25 | 2026-07-31 |  | Decky tab missing from quick setting menu after latest preview update ayn Thor max |
| #167 | closed | 2026-07-27 | 2026-08-25 | device: ayn-thor, device: ayn-odin-3 | Joystick lighting controls |
| #174 | closed | 2026-07-29 | 2026-07-31 | device: ayn-thor | input issues in waydroid |
| #175 | open | 2026-07-29 |  | soc: SM8550 | Improve fan curves and clocks |
| #192 | closed | 2026-08-02 | 2026-08-02 | device: ayn-thor | Night Light not working |
| #201 | open | 2026-08-03 |  | hardware: dual-screen | Second screen on the Ayn Thor isn't getting as dim as expected in low brightness |
| #202 | open | 2026-08-03 |  | hardware: dual-screen | Consider brightness differentiation between screens on the combined brightness slider of dual screen devices |
| #216 | closed | 2026-08-04 | 2026-09-25 | device: konkr-pocket-fit, for-triage | Konkr pocket fit g3 gen 3 issue and "fix" for proton 11 arm (cachyos) crashing |
| #221 | closed | 2026-08-05 | 2026-08-06 |  | AYN Thor cannot change controller emulation type in armada control (preview version) |
| #240 | open | 2026-08-11 |  | device: retroid-pocket-5 | Retroid Pocket 5 joystick movement is slower than dpad movement for binding of isaac in preview version |
| #254 | closed | 2026-08-15 | 2026-08-20 |  | [Feature Request] AYN Thor: Enable HDR support on the top screen |
| #284 | open | 2026-08-20 |  | device: ayn-thor, device: ayn-odin-3 | Display not being detected as HDR capable |
| #306 | closed | 2026-08-23 | 2026-08-24 | device: ayn-thor | Screen remains black when returning from desktop to gamemode |
| #320 | open | 2026-08-25 |  | device: ayn-thor | Inputs in Armada Control are going beyond the QAM panel or not fitting it fully |
| #338 | open | 2026-08-28 |  | device: ayn-thor | Cant boot from external source when Armada is installed internal. |
| #347 | closed | 2026-08-30 | 2026-09-25 | device: ayn-thor | leave the second screen running when opening big picture mode. |
| #357 | closed | 2026-09-01 | 2026-09-02 |  | No "device mdel" option on bootloader screen. |
| #362 | open | 2026-09-02 |  | device: ayn-odin-3 | Internal microphone not functional on AYN Odin 3 (SM8750) — UCM HiFi.conf has no capture device |
| #364 | open | 2026-09-03 |  | device: ayn-thor | Dynamically change the fan profile when in a charging state |
| #391 | open | 2026-09-08 |  | device: ayn-thor | Ability to customize colour of borders |
| #392 | open | 2026-09-08 |  | device: ayn-thor | Tool to show a section of the top screen on the bottom screen for dual screen devices |
| #422 | closed | 2026-09-11 | 2026-09-11 | device: ayn-thor | Mouse shutting off after a few seconds; keyboard unreliable |
| #449 | open | 2026-09-15 |  | device: ayn-thor | Certain games need core pinning for proper performance |
| #453 | open | 2026-09-16 |  | device: ayn-odin-3 | Rpg maker games just sucks on this |
| #461 | open | 2026-09-17 |  | device: ayn-thor | Melon DS using both screen in desktop mode |
| #476 | open | 2026-09-19 |  | device: ayn-thor | No FROM statement found when building from source |
| #529 | open | 2026-09-23 |  | device: ayn-thor | External monitor (DP-1) causes hard freeze on AYN Thor |
| #558 | open | 2026-09-26 |  | device: ayn-thor | Ability to display a second window on the bottom screen in gamemode for dual screen handhelds |
| #563 | open | 2026-09-27 |  | device: ayn-thor | Can't adjust bottom screen brightness in desktop mode |
| #564 | open | 2026-09-28 |  | device: ayn-thor | SD Card Corruption |
| #569 | open | 2026-09-28 |  | device: ayn-thor | Please remove firefox as a packaged browser, since it cannot be uninstalled without rebuilding the os. |
| #570 | open | 2026-09-29 |  | device: ayn-thor | Change default game nice to 1 |
| #571 | open | 2026-09-29 |  | device: ayn-thor | Use second screen as emulated touchpad(s) |
| #592 | open | 2026-10-01 |  | device: ayn-thor | Analog stick acts as if you're only slightly pushing it, no matter how far it's pushed. (In certain circumstan |

## Pull requests
| # | state | opened | merged | branch | title |
|---|---|---|---|---|---|
| #60 | closed | 2026-07-04 |  | main | feat: add AYN RGB controls and fake suspend integration |
| #78 | merged | 2026-07-07 | 2026-07-19 | thor-second-screen | AYN Thor second screen support (userspace) |
| #80 | closed | 2026-07-08 |  | thor-nested-gaming | Nested gaming session for dual-screen devices (Thor phase 2) |
| #90 | closed | 2026-07-13 |  | bottom-screen-perf | Add AYN button toggle for a bottom-screen performance HUD |
| #140 | closed | 2026-07-22 |  | rgb-support | feat: add RGB controls with fake suspend integration |
| #160 | closed | 2026-07-26 |  | fix/pocket-ds-desktop-dual-screen | fix: keep Pocket DS dual screen desktop-only |
| #161 | closed | 2026-07-26 |  | feat/lsfg-vk | Feat: add lsfg-vk decky |
| #177 | closed | 2026-07-30 |  | review/issue175 | fix(fan_curves): reduce heat SM8550 issue #175 |
| #194 | merged | 2026-08-02 | 2026-08-05 | codex/keyboard-output-affinity | [For dual-display devices] Pin virtual keyboard to the bottom screen |
| #255 | closed | 2026-08-15 |  | odin3-stick-lighting | Add stick lighting control for the AYN Odin 3 |
| #261 | merged | 2026-08-16 | 2026-08-20 | feat-ayn-thor-hdr | Add HDR var and panel profile for thor |
| #262 | merged | 2026-08-16 | 2026-08-20 | pocket-ds-label | Update display to label for gamescope |
| #270 | closed | 2026-08-18 |  | feat/bundle-handheld-rgb-plugin | feat(armada-control): add native RGB tab with universal LED driver and gamma correction |
| #290 | closed | 2026-08-20 |  | codex/native-launch-path | Restore PATH for native non-Steam shortcuts |
| #317 | merged | 2026-08-24 | 2026-08-24 | feat-armada-rgb | Add armada-rgb package and initial device profiles |
| #319 | merged | 2026-08-25 | 2026-08-25 | feat-armada-rgb-decky | Armada Control Backend + RGB Decky |
| #424 | merged | 2026-09-12 | 2026-09-12 | feat-thor-lite | AYN Thor Lite Support |
| #427 | merged | 2026-09-12 | 2026-09-12 | fix-thor-lite-controls | AYN Thor Lite Controller + Touch Screen |
| #444 | closed | 2026-09-15 |  | armada-trackpad | feat(trackpad): add Armada Trackpad, bottom screen as a touchpad |
| #525 | open | 2026-09-23 |  | feat/luks-unl0kr-support | feat: add unl0kr and LUKS encrypted root partition support |
| #545 | merged | 2026-09-25 | 2026-09-26 | sleep-savings | feat(kernel): cut s2idle sleep power on SM8550/SM8650/SM8750 handhelds |
| #561 | merged | 2026-09-27 | 2026-09-27 | sleep-charging-fan-speed | feat(power): optional minimum fan speed while charging |
| #573 | open | 2026-09-29 |  | main | fix(audio): disable audio power suspension for more consistent headphone jack behavior |

## Sources
- [S1] refs/_gh/issues.json, refs/_gh/prs.json (gh export, 2026-10-02)
## Deep Dives
- **#564 (SD Card Corruption)**: Reported on 20260915. Uninstalling a Steam game while Armada is installed to the SD card caused a crash and permanently corrupted two 256GB Kingston SD cards (readable only as "No Media"). Suspected controller failure triggered by the OS.
- **#563 (Bottom screen brightness in desktop mode)**: Armada Control's brightness setting for the bottom screen overrides the KDE desktop mode slider; the slider reverts when released.
- **#529 (External monitor DP-1 hard freeze)**: Connecting a Type-C monitor freezes the Thor on kernel 7.2.3. The user diagnosed this as a missing `ucsi_pmic_glink.ko` module breaking the SBU mux initialization. (Note: On stock kernel 7.2.6, #529's "module missing" cause appears incorrect as the module is present, but whether it still freezes is unknown).
- **#338 (Boot from external source with internal install)**: With Armada installed internally (ABL v1.1.7), booting ROCKNIX from an SD card fails with `cannot find /system/flash` and reboots.
- **#202 & #201 (Brightness issues)**: The combined brightness slider sets both screens to the same percentage, but the top screen is naturally brighter. Also, the bottom screen doesn't dim as much as the top screen in desktop mode.
