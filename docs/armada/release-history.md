# Armada OS Release History (all 13 GitHub releases)
> Scope: every GitHub release of `armada-os/armada` from the first (2026-06-05) to the latest (20260926), with tag, dates, pre-release flag, full paraphrased change list grouped by area, and Thor-relevant items flagged · Researched: 2026-10-03 · Confidence: high for what the release notes say; medium for Thor flags marked "by SoC/vendor" (an inference from the devices table, stated where used)

## Summary
- 13 releases exist, all non-draft; exactly **one** is flagged pre-release (`20260806`). Tag names are dates (`YYYYMMDD`) and each tag matches a build (`armada-<tag>.img.gz`). [src: refs/_gh/releases-list.json]
- First release `20260605` was published 2026-06-05T04:53:56Z, about 21 minutes after the repo was created (2026-06-05T04:32:15Z). Latest is `20260926` (published 2026-09-27T19:32:13Z). [src: refs/_gh/releases-list.json] [src: refs/_gh/repo.json]
- All 13 tags in `refs/_gh/tags.json` resolve to the same commit SHAs that the local clone reports (checked with `git rev-parse`). [src: refs/_gh/tags.json] [src: refs/upstream/armada@574da80:commit c2fd048]
- The repo has moved on since the last tag: `main` is at `574da80` (2026-10-02), and an open issue (#602, 2026-10-02) reports OS version `20261001.72f2a63`, a build newer than any tagged release (the `72f2a63` commit is a merge on `main` dated 2026-10-01). So untagged beta/preview builds named `<date>.<sha7>` exist. [src: refs/upstream/armada@574da80:commit 72f2a63] [src: refs/_gh/issues.json#602]
- AYN Thor first appears by name in release notes at `20260725` (desktop-mode dual screen). Its device config shipped from tag `20260611`, and the README listed it as tested from tag `20260612`. See [thor-changelog.md](thor-changelog.md).

### Flag legend used in the change lists
- **[THOR]**: the release note names AYN Thor explicitly.
- **[THOR-LITE]**: names AYN Thor Lite.
- **[THOR:SM8550]**: the note says SM8550 (or "supported SM8550 devices"); the docs list AYN Thor as SM8550, so the item applies to Thor. Inference from the docs table. [src: refs/upstream/armadaos.dev@26dcfc3:docs/devices/ayn/index.md#L8]
- **[THOR:AYN]**: the note names AYN devices generally (or "AYN / Retroid") without naming Thor; Thor is an AYN device.
- **[THOR:dual-screen]**: the note concerns dual-screen devices; Thor is named as a dual-screen device in the `20260725` and `20260907` notes.
- Unflagged items name other devices or are generic platform changes; they may still reach Thor through the OS image, but the note does not say so.

### Release overview table
Dates are UTC from GitHub. "Commits" = commits reachable from the tag but not from the previous tag (`git rev-list --count prev..tag`); every previous tag is an ancestor of the next (linear tag history). [src: refs/_gh/releases-list.json] [src: refs/upstream/armada@574da80:commit c2fd048]

| Tag | Published (UTC) | Pre-release | Tag commit | Commits since prev tag | Download host |
|---|---|---|---|---|---|
| 20260605 | 2026-06-05 04:53 | no | 3a81451 (Initial commit) | (first) | r2.dev bucket |
| 20260607 | 2026-06-07 22:02 | no | 7c313fd | 8 | r2.dev |
| 20260611 | 2026-06-12 02:22 | no | 44b2502 | 27 | r2.dev |
| 20260612 | 2026-06-12 22:31 | no | 2678caf | 9 | r2.dev |
| 20260621 | 2026-06-21 17:33 | no | 9fc111f | 36 | r2.dev |
| 20260628 | 2026-06-29 22:15 | no | 47106ab | 38 | r2.dev |
| 20260714 | 2026-07-15 04:04 | no | a7e0263 | 45 | r2.dev |
| 20260725 | 2026-07-26 03:34 | no | 4d0cacb | 34 | r2.dev |
| 20260806 | 2026-08-06 18:52 | **yes** | 40c10d5 | 82 | downloads.armadaos.dev/testing |
| 20260817 | 2026-08-17 22:00 | no | c47fe9d | 69 | downloads.armadaos.dev/release |
| 20260907 | 2026-09-07 20:46 | no | 78958ee | 122 | downloads.armadaos.dev/release |
| 20260915 | 2026-09-16 03:02 | no | feca679 | 81 | downloads.armadaos.dev/release |
| 20260926 | 2026-09-27 19:32 | no | c2fd048 | 367 | downloads.armadaos.dev/release |

Notes on the table: several tags carry a date earlier than the publish date (for example `20260611` was created 2026-06-12T00:55Z and published 02:22Z; `20260926` was created 2026-09-27T03:30Z). The 367-commit window for `20260926` is inflated by the import of the separate armada-packages history under `packages/` (commit `956bd2c`, merged by PR #460 "armada-packages-merge"); the release note says package sources were consolidated into the main repository. Only 44 first-parent commits fall in that window. [src: refs/upstream/armada@574da80:commit 956bd2c] [src: refs/upstream/armada@574da80:commit 22aee97] [src: refs/_gh/releases/20260926.json]

### Cross-release observations
- **Hosting moved.** `20260605`-`20260725` link to a Cloudflare R2 public bucket (`pub-462c...r2.dev/release/`); `20260806` links `downloads.armadaos.dev/testing/`; `20260817` onward link `downloads.armadaos.dev/release/`. [src: refs/_gh/releases/20260725.json] [src: refs/_gh/releases/20260806.json] [src: refs/_gh/releases/20260817.json]
- **"Early preview" warning banner** appears on `20260605`-`20260725`, `20260817`, `20260907`, `20260915`. `20260806` has a different banner (pre-releases are pinned to the preview channel). `20260926` is the first release body with **no** warning banner. [src: refs/_gh/releases/20260926.json] [src: refs/_gh/releases/20260806.json]
- **Install pointer** changed: README `#install` (0605-0621) -> README `#flash-to-sd-card` (0628-0806) -> the wiki flashing page (0817) -> the wiki root (0907 onward). [src: refs/_gh/releases/20260621.json] [src: refs/_gh/releases/20260628.json] [src: refs/_gh/releases/20260817.json] [src: refs/_gh/releases/20260907.json]
- **Only 20260605 has no changelog section** (its body is the download link plus the early-preview warning). [src: refs/_gh/releases/20260605.json]
- **Pre-release 20260806 overlaps stable 20260817.** Several 0806 items (new boot splash, Thor desktop keyboard on bottom display, Thor charging, performance tuning in Armada Control, kernel/Mesa/FEX/Proton versions) are repeated in the 0817 notes, so for those items the first appearance is the 0806 pre-release (preview channel) and the first stable appearance is 0817. [src: refs/_gh/releases/20260806.json] [src: refs/_gh/releases/20260817.json]
- Each release body includes a sha256 for the `.img.gz`; they are recorded in the per-release sections below so downloads can be verified.

## Details

### 20260605 (first release; initial commit)
- Published 2026-06-05T04:53:56Z (created 04:19:55Z), pre-release flag false, tag commit `3a81451` "Initial commit". Download `armada-20260605.img.gz`, sha256 `56ab4d9108bb2ec0432263e2f11f808987a0ff20291c1312120a6fe7f58bb16a`. Body has the early-preview warning and an install pointer; no changelog. [src: refs/_gh/releases/20260605.json] [src: refs/_gh/releases-list.json]
- **Context from the README at this tag** (not from the release body): Armada is "a SteamOS-like Linux distribution for ARM handhelds built on Fedora bootc using device support from ROCKNIX", shipping ARM64 Steam, latest FEX, CachyOS Proton 11. [src: refs/upstream/armada@574da80:README.md@20260605#L3-L9]
- README warnings at this tag: prototype software; no upgrade path (reflash SD, re-login, redownload games); SSH enabled with a documented default account (user `armada`) so the LAN is exposed until changed. [src: refs/upstream/armada@574da80:README.md@20260605#L11-L23]
- Supported-devices table at this tag lists only four devices: AYANEO Pocket EVO, Odin 2 Portal, Odin 2 Mini (touchscreen not working), Odin 2 (untested). **AYN Thor is not in the table.** [src: refs/upstream/armada@574da80:README.md@20260605#L27-L32]
- Install steps at this tag: SD card only (internal install "still in development"); flash `.img.gz` to a 64 GB+ SD (A2 for best results); copy `rocknix_abl` to Android internal storage, run `backup_abl.sh` then `flash_abl.sh` as root; hold **volume up** while powering on to reach the ABL menu (later READMEs and the docs say VOL-). [src: refs/upstream/armada@574da80:README.md@20260605#L34-L61]
- Roadmap at this tag: desktop mode, internal install, update mechanism with rollback, power/fan control, broader device support (e.g. Odin 3). [src: refs/upstream/armada@574da80:README.md@20260605#L63-L69]
- Known issues at this tag: QAM unmapped (use Home+A), fake suspend only, occasional Adreno/Turnip GPU hangs from `steamwebhelper`. [src: refs/upstream/armada@574da80:README.md@20260605#L71-L80]
- **Thor presence in the image at this tag [THOR]:** the tree already contains AYN Thor firmware (`system_files/usr/lib/firmware/qcom/sm8550/ayn/thor/*`, `AYN-Thor-tplg.bin`) and ALSA UCM profiles for Thor, but no `devices/ayn-thor.conf`. Verified by `git ls-tree -r 20260605`. [src: refs/upstream/armada@574da80:commit 3a81451]

### 20260607
- Published 2026-06-07T22:02:09Z, tag commit `7c313fd`, 8 commits after 0605. sha256 `b077768b2a2d09f12072c6795d69ba6ced295c874372de544f7502c079c28b73`. [src: refs/_gh/releases/20260607.json]
- **Stability:** GPU hang workaround (the 0605 known issue). [src: refs/_gh/releases/20260607.json]
- **Devices:** Retroid Pocket 6 support (explicitly untested). [src: refs/_gh/releases/20260607.json]
- **Controls:** QAM mapped to the back button on AYN / Retroid devices **[THOR:AYN]**. The docs abbreviations page still gives "Back button for AYN/Retroid" as the QAM key. [src: refs/_gh/releases/20260607.json] [src: refs/upstream/armadaos.dev@26dcfc3:includes/abbreviations.md#L1]
- **Components:** kernel 7.0.11, Mesa 26.1.2; Steam moved to the public beta channel. [src: refs/_gh/releases/20260607.json]

### 20260611
- Published 2026-06-12T02:22:59Z (tag created 2026-06-12T00:55:39Z), tag commit `44b2502`, 27 commits after 0607. sha256 `f3ab4aa1e4ab3ba3a0549b7769c6181df40bcada26bb30ccb958b20f8e6d8c4e`. [src: refs/_gh/releases/20260611.json] [src: refs/_gh/releases-list.json]
- **Devices:** "support for new untested devices" (unnamed in the note). The tag's tree is the first to contain `system_files/usr/lib/armada/devices/ayn-thor.conf` (added by commit `75349fe`, "Add support for more SM8550, SM8650, and SM8750 devices"). **[THOR, inferred from commit/tree, not named in the note]** [src: refs/_gh/releases/20260611.json] [src: refs/upstream/armada@574da80:commit 75349fe]
- **Desktop mode:** desktop-mode switching fully working; Bazaar app store added for Flatpaks. [src: refs/_gh/releases/20260611.json]
- **UI/Display:** improved UI scaling on smaller devices. A commit in the same window is titled "Fix touchscreen on Thor and Odin 2 Mini and improve UI scaling" (`a4e11d9`, an ancestor of this tag). **[THOR, from commit]** [src: refs/_gh/releases/20260611.json] [src: refs/upstream/armada@574da80:commit a4e11d9]
- **Compat:** latest FEX and CachyOS 11 Proton. [src: refs/_gh/releases/20260611.json]
- **Power:** improvements to fake suspend. [src: refs/_gh/releases/20260611.json]
- **Updates:** over-the-air updates enabled. [src: refs/_gh/releases/20260611.json]

### 20260612
- Published 2026-06-12T22:31:16Z, tag commit `2678caf`, 9 commits after 0611 (the tag commit message is "Update ROCKNIX ABL to 1.1.1 and add per SoC subfolders"). sha256 `bd1bb2adabe42fa36a7f8f3a16ca727ae99e3b0cd0e34587e44fbff5969be473`. [src: refs/_gh/releases/20260612.json] [src: refs/upstream/armada@574da80:commit 2678caf]
- **Bootloader:** ROCKNIX ABL updated to 1.1.1; separate ABL folders per SoC (the origin of the `rocknix_abl/SM8550` layout the docs use). [src: refs/_gh/releases/20260612.json] [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/flashing-to-an-sd-card.md#L42-L44]
- **Steam:** improved Steam startup and restart times; OS updates suppressed during SteamOS onboarding. [src: refs/_gh/releases/20260612.json]
- **Context:** the README at this tag is the first to list **AYN Thor | SM8550 | Supported and tested** (commit `66e15ec`, 2026-06-11 22:23 -0400; two earlier README edits that added and then reverted the table are in the history, see thor-changelog.md). **[THOR]** [src: refs/upstream/armada@574da80:README.md@20260612#L38]

### 20260621
- Published 2026-06-21T17:33:34Z, tag commit `9fc111f`, 36 commits after 0612. sha256 `5385f2afeaf5d092b1a283c4f77b52331431459b501a7c3ac1b9082940847ebd`. [src: refs/_gh/releases/20260621.json]
- **Power:** power profiles in the QAM (Eco / Balanced / Performance); fake-suspend integration with Steam sleep behaviour. [src: refs/_gh/releases/20260621.json]
- **Armada Control (new Decky plugin):** per-game compatibility (resolution and FEX presets); power-profile editing (fan curve, CPU underclock, GPU clock range); controller emulation type (Steam Deck / Xbox 360 / DualSense); stick and trigger calibration (AYN / Retroid only) **[THOR:AYN]**; enable/disable SSH server. [src: refs/_gh/releases/20260621.json]
- **Install:** internal-storage installer (Armada Installer in desktop mode). [src: refs/_gh/releases/20260621.json]
- **Misc:** MangoHud shows previously missing GPU and power metrics; controller rumble working on many devices. [src: refs/_gh/releases/20260621.json]

### 20260628
- Published 2026-06-29T22:15:12Z, tag commit `47106ab`, 38 commits after 0621. sha256 `8741987a122a5b02b043adedce10aa4e2048e2036e464fc51b75760dd637582d`. [src: refs/_gh/releases/20260628.json]
- **Storage/Install:** flashed SD cards should no longer appear corrupted to Android (partition table migrated from GPT to MBR); more reliable installer disk detection; OTA updates fixed from internal installs. [src: refs/_gh/releases/20260628.json]
- **Armada Control:** hides uninstalled games, shows its version. [src: refs/_gh/releases/20260628.json]
- **Performance:** tuning including NTSync for Proton 11. [src: refs/_gh/releases/20260628.json]
- **Power:** fake-suspend improvements (reduced power, lower fan curves; credit @xXJSONDeruloXx). [src: refs/_gh/releases/20260628.json]
- **Devices:** KONKR Pocket FIT support (backlight init fixed; touchscreen added, credit @kevinkreiser). [src: refs/_gh/releases/20260628.json]

### 20260714
- Published 2026-07-15T04:04:52Z, tag commit `a7e0263`, 45 commits after 0628. sha256 `1ba48b906cd5f117245989f8334af23b125f1e79a01f011018ccef19aa6bcd28`. [src: refs/_gh/releases/20260714.json]
- **Upgrade notice:** Retroid Pocket 6 users must re-select the device model in the ABL menu (hold VOL-) after upgrading; one-time migration. [src: refs/_gh/releases/20260714.json]
- **Performance:** GPU underclocking issue fixed on SM8550 devices **[THOR:SM8550]**. [src: refs/_gh/releases/20260714.json]
- **Power:** real suspend enabled on AYN Odin 3. [src: refs/_gh/releases/20260714.json]
- **Compat:** Proton version management in Armada Control; auto-register Proton 11 (ARM) and GE Proton when installed; controllers no longer unresponsive in x86 Proton; FEX and Proton CachyOS 11 (ARM64) updated; ProtonUp-Qt bundled in desktop mode on new installs. [src: refs/_gh/releases/20260714.json]
- **Storage:** SD-card formatting and auto-mount in Steam. [src: refs/_gh/releases/20260714.json]
- **Fans:** fan control uses the hottest temperature sensors, smoother curves, faster response under load. [src: refs/_gh/releases/20260714.json]
- **Controllers:** AYANEO controller improvements (credit @pacoa-kdbg). [src: refs/_gh/releases/20260714.json]

### 20260725
- Published 2026-07-26T03:34:29Z, tag commit `4d0cacb`, 34 commits after 0714. sha256 `aa599ccc72fed2bd10c8c0153c5a1ccb5e91198528799d8eef60b6da3b113a78`. [src: refs/_gh/releases/20260725.json]
- **Performance:** more robust SM8550 performance fixes (credit @sunshineinabox) **[THOR:SM8550]**. [src: refs/_gh/releases/20260725.json]
- **Power:** improved power button, lid, suspend and resume handling (credit @enjihn). [src: refs/_gh/releases/20260725.json]
- **Waydroid:** Waydroid support, including controller passthrough on AYN devices (credit @Gaidzi) **[THOR:AYN]**. [src: refs/_gh/releases/20260725.json]
- **Desktop mode:** **AYN Thor dual screen support (credit @brycesub) [THOR]**; Heroic Games Launcher (credit @justradical); network and Bluetooth controls; SMB/CIFS support, Ark, Gwenview, KWrite. [src: refs/_gh/releases/20260725.json]

### 20260806 (PRE-RELEASE)
- Published 2026-08-06T18:52:10Z, **isPrerelease = true**, tag commit `40c10d5`, 82 commits after 0725. Banner: pre-releases are pinned to the preview channel (more frequent, less stable updates). Download from `downloads.armadaos.dev/testing/`. sha256 `caff449d58fe161851288666fd5543fb100c809a2543afa5b5a5e511a2a5fcdf`. [src: refs/_gh/releases/20260806.json] [src: refs/_gh/releases-list.json]
- **Devices:** initial support for Retroid Pocket 5, Pocket Flip 2, Pocket Mini / Mini V2, Pocket Nova, KONKR Pocket FIT Elite. [src: refs/_gh/releases/20260806.json]
- **Boot:** new boot splash with smoother handoff from early boot through Steam startup, reboot and power off. [src: refs/_gh/releases/20260806.json]
- **Device improvements:** Odin 3 Bluetooth (@axunes), headphone routing (@bernhardberger), experimental HDR (@enjihn), haptics; Pocket EVO extra button mappings (@jesherman); **Thor desktop keyboard now stays on the bottom display (@tslmy) [THOR]**; more reliable suspend/resume/power-button wake (@Gaidzi); **charging speed improvements on AYN Thor and Retroid Pocket 6 [THOR]**. [src: refs/_gh/releases/20260806.json]
- **Armada Control:** global and per-game CPU core, Wine topology, process priority, scheduler, and environment-variable controls; CPU governor selection per power profile. [src: refs/_gh/releases/20260806.json]
- **Components:** kernel 7.1.5, Mesa 26.2.0, FEX 2608, CachyOS Proton 11 20260703, ROCKNIX ABL 1.1.7; OpenGamingCollective gamescope integrated (@JustRadical). [src: refs/_gh/releases/20260806.json]

### 20260817
- Published 2026-08-17T22:00:28Z, tag commit `c47fe9d`, 69 commits after 0806. Download from `downloads.armadaos.dev/release/`. sha256 `586d21c218fceada4cbb21fc446ceb86c49397b62795c96e97fca14541719c6d`. [src: refs/_gh/releases/20260817.json]
- **Install note:** SM8250 devices need the SD card fully wiped before flashing (relevant to Thor Lite, which the docs list as SM8250) **[THOR-LITE by SoC]**. [src: refs/_gh/releases/20260817.json] [src: refs/upstream/armadaos.dev@26dcfc3:docs/devices/ayn/index.md#L9]
- **Devices:** same initial-support list as 0806 (Pocket 5, Flip 2, Mini / Mini V2, Nova, FIT Elite). [src: refs/_gh/releases/20260817.json]
- **Sleep:** new experimental native sleep: supported SM8550 devices can test native sleep (s2idle or deep) instead of fake suspend **[THOR:SM8550]**; switch in Armada Control, applies immediately and persists across reboots; fake suspend remains the safe fallback. [src: refs/_gh/releases/20260817.json]
- **Armada Store (new Decky plugin):** install/update emulators, launchers, streaming apps and selected Decky plugins from Game Mode; automatic Steam shortcuts and your own non-Steam shortcuts; ES-DE system definitions for all included emulators (@FeralAI). [src: refs/_gh/releases/20260817.json]
- **Armada Control:** same performance controls as 0806 plus per-game settings for non-Steam shortcuts. [src: refs/_gh/releases/20260817.json]
- **Device improvements:** as in 0806 (Odin 3 Bluetooth/headphone/HDR/haptics, Pocket EVO buttons, **Thor desktop keyboard on bottom display [THOR]**, suspend/wake reliability) plus Pocket DS dual-screen desktop support and better suspend (@pacoa-kdbg); **charging improvements for AYN Thor, Retroid Pocket 6, and devices using s2idle sleep [THOR]**. [src: refs/_gh/releases/20260817.json]
- **Compat:** updated for Steam's integrated FEX flow with a newer guest filesystem; FEX Multiblock enabled by default. [src: refs/_gh/releases/20260817.json]
- **Boot:** new splash (includes shutdown and applying updates). [src: refs/_gh/releases/20260817.json]
- **More experimental:** USB file transfer over MTP; selectable Plasma Desktop or Plasma Mobile desktop mode (@JPyke3); ROCKNIX ABL auto-updater (off by default). [src: refs/_gh/releases/20260817.json]
- **Components/extras:** kernel 7.2-rc7, Mesa 26.2.0, FEX 2608, CachyOS Proton 11 20260703, ROCKNIX ABL 1.1.7; Distrobox and DistroShelf with rootless containers (@justradical); OpenGamingCollective gamescope (@justradical); improved Waydroid compatibility in Game Mode. [src: refs/_gh/releases/20260817.json]

### 20260907
- Published 2026-09-07T20:46:09Z, tag commit `78958ee`, 122 commits after 0817. sha256 `e9b96f39d7f09d57f18f09cd952e275425bbf46cd021b4226f513c86e653f282`. [src: refs/_gh/releases/20260907.json]
- **Install note:** the OTA to this release may be larger than usual because Armada's image-layer format changed; later updates should be much smaller. [src: refs/_gh/releases/20260907.json]
- **Dual screen:** new experimental dual-screen experience for **AYN Thor** and AYANEO Pocket DS **[THOR]**: launch Plasma Mobile on the bottom screen from Armada Control with a persistent brightness control; Armada Store offers preconfigured DRM-leasing builds of melonDS and Azahar for the second display. [src: refs/_gh/releases/20260907.json]
- **Sleep:** native sleep is now the default on all supported devices **[THOR:SM8550]**; SM8550 sleep stability and power use improved (full CPU cluster collapse, USB autosuspend, controller and UART fixes); fewer accidental wakeups (volume keys no longer wake; closed clamshell ignores power button; lid-open wake debounced). [src: refs/_gh/releases/20260907.json]
- **RGB (Armada Control):** power/brightness/colour, restored at boot; supports **AYN Thor**, Odin 2 Portal, Odin 3, Retroid Pocket 5, Flip 2, Nova, Pocket 6, KONKR FIT Elite **[THOR]** (credit @antnyhills, @Ga1dz1, @Rayekkk, @drewano). [src: refs/_gh/releases/20260907.json]
- **Fan curves:** new touch/controller friendly fan-curve editor (custom curves, fan stop, ramp timing, smoothing, minimum speed, live temperature; @Alexandreaam). [src: refs/_gh/releases/20260907.json]
- **Defaults:** Vulkan real-time priority on by default, higher Gamescope priority, non-SM8250 devices default to Proton Experimental. [src: refs/_gh/releases/20260907.json]
- **Display/HDR:** external monitors usable in Game Mode; dim SDR and clipped HDR highlights fixed (@Rayekkk); **HDR support added for AYN Thor [THOR]**; improved OLED brightness scaling on AYN Odin 3, **Thor** and Odin 2 Portal, AYANEO Pocket EVO, Retroid Pocket Nova **[THOR]**. [src: refs/_gh/releases/20260907.json]
- **Controllers/devices:** rear-button support for Retroid Pocket 6, Pocket Nova, AYN Odin 2 Portal; KONKR FIT Elite backlight current limit (@mrdidit); broader Steam Controller, game controller and VR device support. [src: refs/_gh/releases/20260907.json]
- **Compat:** native AppImages no longer invoke FEX by mistake (RPCS3 faster, Epic login in Heroic restored); missing environment paths for native non-Steam games fixed (@tslmy); CJK fonts in Xenia; Armada Control dropdowns no longer freeze QAM input in-game (@drewano). [src: refs/_gh/releases/20260907.json]
- **Updates/Install:** faster image builds and smaller incremental updates (Chunkah); better update progress and storage checks with a 2 GB update reserve; more reliable Steam bootstrap and FEX guest filesystem mounting; internal installs use the `ARMADA` EFI partition name (ROCKNIX labels migrated automatically). [src: refs/_gh/releases/20260907.json]
- **Extras/components:** Tailscale CLI, btop, wl-clipboard, binutils added; more compressed swap; kernel 7.2.3, Mesa 26.2.2, InputPlumber 0.78.1, KWin 6.7.4, jupiter-hw-support 3.7.20251020.1, ROCKNIX ABL 1.1.8. [src: refs/_gh/releases/20260907.json]

### 20260915
- Published 2026-09-16T03:02:04Z (tag created 2026-09-15T22:10:32Z), tag commit `feca679`, 81 commits after 0907. sha256 `48af8f59c85f743bfadc88ca1882adbf24ea26944883cda9d126e87c40c3ddb2`. [src: refs/_gh/releases/20260915.json] [src: refs/_gh/releases-list.json]
- **Display:** hardware display rotation on SM8550, SM8650, SM8750 improves game performance (credit @tiopex and ROCKNIX) **[THOR:SM8550]**; night mode, colour temperature and vibrance work during direct scanout through hardware colour correction; colour profiles for Odin 2 Portal, Pocket EVO, Pocket DS; Pocket S2 and Pocket S 2K stay on shader rotation because their panel resolution exceeds the hardware rotator limit. [src: refs/_gh/releases/20260915.json]
- **Devices:** **AYN Thor Lite support added [THOR-LITE]**; AYANEO Pocket S 1K (@gryoza); Visionox display variants of Retroid Pocket 5 and Flip 2. [src: refs/_gh/releases/20260915.json]
- **Internal installer:** reimplemented for reliability; can replace any Linux CFW install alongside Android while preserving Android data; touch-friendly storage sizing; uninstall now through UNINSTALL CFW in the ABL. [src: refs/_gh/releases/20260915.json]
- **Recovery:** hold Select for one second during the boot splash to start Desktop Mode. [src: refs/_gh/releases/20260915.json]
- **Steam compat:** global "Follow Steam" option in Armada Control (Steam chooses compatibility tools, per-game overrides kept); Proton dropdown restored on newer Steam beta clients; CPU-topology settings override Proton defaults per game. [src: refs/_gh/releases/20260915.json]
- **Devices/controllers:** DisplayPort audio on Odin 3 and KONKR FIT Elite (@noahcdls); lid switch for Pocket DS; Qualcomm battery capacity/remaining charge reporting fixed (@xXJSONDeruloXx) **[THOR:SM8550, Qualcomm SoC]**. [src: refs/_gh/releases/20260915.json]
- **Armada Control:** RGB support for AYN Odin 2 (@sehraf); bottom-screen brightness slider only shown while that display is active **[THOR:dual-screen]**. [src: refs/_gh/releases/20260915.json]
- **Armada Store:** BigPEmu, MAME, PrimeHack, Ymir added; Flatpak emulators from the store get home-directory access. [src: refs/_gh/releases/20260915.json]
- **Components:** InputPlumber 0.79.0, Decky Loader 3.2.9. [src: refs/_gh/releases/20260915.json]

### 20260926 (latest tag)
- Published 2026-09-27T19:32:13Z (tag created 2026-09-27T03:30:23Z), tag commit `c2fd048`, 367 commits after 0915. sha256 `2213cc709bca39c977f7d0810150810436f82115df2e13275b0557fd571a3c7a`. First body with no early-preview banner. [src: refs/_gh/releases/20260926.json] [src: refs/_gh/releases-list.json]
- **Sleep:** lower sleep power on SM8550/SM8650/SM8750 (most devices about 50% less drain) **[THOR:SM8550]**; faster Wi-Fi reconnect after wake (no full scans), WPA3 auto-connect fixed. [src: refs/_gh/releases/20260926.json]
- **Armada Tools (new desktop app + CLI):** device info, storage, IP addresses, installed OS/Steam versions; enable SSH; select Stable/Beta/Preview update channels; install OS updates and roll back to the previous version without Steam running; repair Steam by restoring the bundled client while keeping games, saves, accounts, settings. [src: refs/_gh/releases/20260926.json]
- **Devices/controllers:** Retroid Pocket 6 touch sampling about 28 Hz -> 119 Hz (@diogotr7); RSInput controllers (incl. Pocket 6 and **AYN Odin 3**) analog reporting raised to 250 Hz; Odin 3 built-in stick deadzone removed so Steam Input/games control it; DisplayPort detection with reversed USB-C on SM8250 Retroid devices (@Tom42-eu); brief input freezes via USB hubs/docks fixed (@keks2293). [src: refs/_gh/releases/20260926.json]
- **Graphics/compat:** QAM appearing behind games during hardware scanout fixed; **bottom-screen Gamescope startup during display handoff fixed on dual-screen devices [THOR:dual-screen]**; kernel support for FEX unaligned atomic emulation and backpatching; EmuDeck dependencies added. [src: refs/_gh/releases/20260926.json]
- **Waydroid:** controller input restored (hotplug and Android restarts without duplicate controllers in Steam); Armada's Android Mesa drivers available at first init. [src: refs/_gh/releases/20260926.json]
- **Armada Control:** Simplified Chinese, Brazilian Portuguese, European Portuguese translations (@mydanyi, @Raxcoms); conservative CPU governor (@dsancalm); defaults: Eco and Balanced use conservative; CPU realtime scheduling option removed (stability); controller calibration/system commands fixed with native ARM64 Decky Loader; optional automatic sleep logs under `Documents/sleep-logs` with kernel tracing (@xXJSONDeruloXx). [src: refs/_gh/releases/20260926.json]
- **Armada Store:** startup failure from a missing Python module in Decky Loader fixed (@Janleyx); Lossless Scaling plugin pinned to 0.12.8 (@Raxcoms). [src: refs/_gh/releases/20260926.json]
- **New devices:** initial support for MANGMI Pocket Max and MANGMI Air Y Pro (thanks ROCKNIX); known issue: audio not working. [src: refs/_gh/releases/20260926.json]
- **System/build:** Armada OS identification; `armada-rebase` helper for switching image tags or testing forks; package sources consolidated into the main repository. [src: refs/_gh/releases/20260926.json]
- **Components:** Linux 7.2.6, Mesa 26.2.3, FEX 2609, Gamescope 3.16.29-ogc2, NetworkManager 1.58.1. [src: refs/_gh/releases/20260926.json]

## Version-number tracker (from release notes only)
| Component | Values by release |
|---|---|
| Kernel | 7.0.11 (0607) -> 7.1.5 (0806) -> 7.2-rc7 (0817) -> 7.2.3 (0907) -> 7.2.6 (0926) |
| Mesa | 26.1.2 (0607) -> 26.2.0 (0806, 0817) -> 26.2.2 (0907) -> 26.2.3 (0926) |
| FEX | "latest" (0611) -> 2608 (0806, 0817) -> 2609 (0926) |
| CachyOS Proton 11 | "11" (0611) -> 20260703 (0806, 0817) |
| ROCKNIX ABL | 1.1.1 (0612) -> 1.1.7 (0806, 0817) -> 1.1.8 (0907) |
| InputPlumber | 0.78.1 (0907) -> 0.79.0 (0915) |
| Gamescope | OpenGamingCollective integrated (0806/0817) -> 3.16.29-ogc2 (0926) |
| Decky Loader | 3.2.9 (0915) |
| KWin | 6.7.4 (0907) |

Sources for the table: [src: refs/_gh/releases/20260607.json] [src: refs/_gh/releases/20260612.json] [src: refs/_gh/releases/20260806.json] [src: refs/_gh/releases/20260817.json] [src: refs/_gh/releases/20260907.json] [src: refs/_gh/releases/20260915.json] [src: refs/_gh/releases/20260926.json]

## Contributors credited in release notes
@xXJSONDeruloXx, @kevinkreiser, @pacoa-kdbg, @sunshineinabox, @enjihn, @Gaidzi, @brycesub, @justradical / @JustRadical, @axunes, @bernhardberger, @jesherman, @tslmy, @FeralAI, @JPyke3, @antnyhills, @Ga1dz1, @Rayekkk, @drewano, @Alexandreaam, @mrdidit, @tiopex, @gryoza, @noahcdls, @sehraf, @diogotr7, @Tom42-eu, @keks2293, @mydanyi, @Raxcoms, @dsancalm, @Janleyx; ROCKNIX credited for ABL, display rotation and MANGMI support. See [community-credits.md](community-credits.md). [src: refs/_gh/releases/20260628.json] [src: refs/_gh/releases/20260926.json]

## Sources
- [S1] refs/_gh/releases-list.json, refs/_gh/releases/*.json (13 files) - release dates, pre-release flag, bodies
- [S2] refs/_gh/tags.json and `git rev-parse <tag>` in refs/upstream/armada - tag to commit mapping
- [S3] refs/upstream/armada `git rev-list --count prev..tag`, `git merge-base --is-ancestor` - commit counts and linear history
- [S4] refs/upstream/armada `git show <tag>:README.md` - README context at 0605, 0612
- [S5] refs/upstream/armadaos.dev docs (devices/ayn/index.md, includes/abbreviations.md, flashing page) - cross-references
- [S6] refs/_gh/repo.json, refs/_gh/issues.json#602 - repo creation time, untagged-build evidence
