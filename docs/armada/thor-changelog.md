# AYN Thor on Armada — changelog timeline
> Scope: when each Thor-relevant capability appeared, from release notes, tags and merged PRs · Researched: 2026-10-03 · Confidence: high for dated items; "[SoC]" items are inferred from SM8550 wording

Legend: **[THOR]** note names Thor; **[SoC]** note says SM8550/AYN generally (Thor is SM8550 per [devices-ayn](devices-ayn.md)). Full per-release detail: [release-history](release-history.md). Issue/PR index: [thor-issues-and-prs](thor-issues-and-prs.md).

| Date / tag | Item | Evidence |
|---|---|---|
| 2026-06-05 `20260605` | First release. Tree already contains Thor firmware (`system_files/usr/lib/firmware/qcom/sm8550/ayn/thor/*`, `AYN-Thor-tplg.bin`) but README device table lists no Thor | `git ls-tree` @ tag [src: refs/upstream/armada@574da80:tag 20260605] |
| 2026-06-09 | Issue #8 "AYN Thor" opened (closed 06-14) — earliest Thor issue | [src: refs/_gh/issues.json#8] |
| 2026-06-12 `20260611` | `system_files/usr/lib/armada/devices/ayn-thor.conf` present in tree | `git ls-tree` @ tag [src: refs/upstream/armada@574da80:tag 20260611] |
| 2026-06-12 `20260612` | README lists **AYN Thor | SM8550 | Supported and tested** | `git show 20260612:README.md` [src: refs/upstream/armada@574da80:tag 20260612] |
| 2026-06-07 `20260607` | [SoC] QAM mapped to back button on AYN/Retroid | [src: refs/_gh/releases/20260607.json] |
| 2026-06-21 `20260621` | [SoC] Controller emulation type; stick/trigger calibration (AYN/Retroid only) | [src: refs/_gh/releases/20260621.json] |
| 2026-07-15 `20260714` | [SoC] GPU underclocking bug fixed on SM8550 | [src: refs/_gh/releases/20260714.json] |
| 2026-07-26 `20260725` | **[THOR] dual screen support**; [SoC] SM8550 perf fixes; controller passthrough on AYN. Userspace second-screen PR #78 merged 2026-07-19 | [src: refs/_gh/releases/20260725.json] [src: refs/_gh/prs.json#78] |
| 2026-08-06 `20260806` (pre-release) | **[THOR]** desktop keyboard stays on bottom display (PR #194, merged 2026-08-05); **[THOR]** charging speed improvements; experimental HDR (general) | [src: refs/_gh/releases/20260806.json] [src: refs/_gh/prs.json#194] |
| 2026-08-17 `20260817` | Same Thor items promoted to stable; [SoC] native sleep (s2idle/deep) testable on SM8550 | [src: refs/_gh/releases/20260817.json] |
| 2026-08-20 | PR #261 "Add HDR var and panel profile for thor" merged (likely the change behind "Added HDR support for the AYN Thor" in 20260907 — [UNVERIFIED link]) | [src: refs/_gh/prs.json#261] |
| 2026-09-07 `20260907` | **[THOR] experimental dual-screen experience** (Plasma Mobile on bottom screen, DRM-leasing melonDS/Azahar builds); **[THOR] HDR support**; **[THOR] RGB lighting controls**; [SoC] SM8550 sleep stability (full CPU cluster collapse, USB autosuspend); OLED brightness scaling incl. Thor; fan-curve editor | [src: refs/_gh/releases/20260907.json] |
| 2026-09-15 `20260915` | AYN Thor **Lite** support (PRs #424, #427 merged 2026-09-12); hardware display rotation on SM8550; Follow-Steam compatibility option | [src: refs/_gh/releases/20260915.json] [src: refs/_gh/prs.json#424] |
| 2026-09-27 `20260926` | [SoC] ~50% lower sleep drain on SM8550/8650/8750; **fix: bottom-screen Gamescope startup during display handoff on dual-screen devices**; Armada Tools app | [src: refs/_gh/releases/20260926.json] |
| 2026-09-26/27 (merged, post-`20260915`) | PR #559 HDR direct scanout on SM8550/SM8750; PR #561 optional minimum fan speed while charging; PR #545 s2idle power cut | [src: refs/_gh/prs.json#559] [src: refs/_gh/prs.json#561] [src: refs/_gh/prs.json#545] |

## Open Thor items on GitHub (as of 2026-10-02, label `device: ayn-thor`, state open)
Second-screen brightness not dimming low enough (#201/#202, `hardware: dual-screen`); #284 display not detected HDR-capable (Thor+Odin 3); #320 Armada Control inputs overflow the QAM panel; #338 can't boot from external source when installed internally; #364 dynamic fan profile while charging; #391 border colour customisation; #392 mirror part of top screen to bottom; #449 some games need core pinning; #461 melonDS dual-screen in desktop mode; #476 build-from-source "No FROM statement"; **#529 external monitor (DP-1) causes hard freeze**; #558 second window on bottom screen in Game Mode; #563 can't adjust bottom-screen brightness in desktop mode; **#564 SD card corruption**; #569 firefox packaged; #570 default game nice; #571 second screen as emulated touchpads; #592 analog stick acting partially pushed. Titles only — bodies not read. [src: refs/_gh/issues.json]

## Sources
- [S1] refs/_gh/releases/*.json, refs/_gh/issues.json, refs/_gh/prs.json (gh export 2026-10-02)
- [S2] refs/upstream/armada@574da80 tags 20260605/20260611/20260612 (`git ls-tree`, `git show`)

## Post-20260926 (Unreleased / Main branch as of 2026-10-03)
- **Power**: Cut s2idle sleep power on SM8550 handhelds (PR #545).
- **Power**: Added optional minimum fan speed while charging (PR #561).
- **Display**: Scan out HDR games without composition on SM8550 (`eb54fa6`).
- **Emulation (Thor Lite)**: Fixed FEX atomic emulation oopsing x86 games on SM8250 (`733e16f`).
