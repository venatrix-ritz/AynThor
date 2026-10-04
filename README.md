# AYN Thor + Armada OS — research repo

Knowledge base about the **AYN Thor** (dual-screen Snapdragon 8 Gen 2 handheld) and **Armada OS** (SteamOS-like ARM64 Linux that runs on it). Built 2026-10-02/03 from upstream source clones and web sources; `docs/hardware/device-observed.md` is a live read-only survey of the physical Thor (2026-10-03) — everything else is not yet device-verified.

## How to read this
- Every factual line carries a tag: `[src: URL | refs/<dir>@<sha>:path | refs/_gh/…]`, `[UNVERIFIED — …]`, or `[CONFLICT: …]`. Rules: [docs/reference/CONVENTIONS.md](docs/reference/CONVENTIONS.md).
- `refs/` (gitignored) holds the upstream clones; `scripts/clone-refs.ps1 [-UseLock]` recreates them at pinned SHAs (`scripts/refs.lock.json`); `scripts/fetch-gh-meta.ps1` re-exports releases/issues/PRs to `refs/_gh/`.
- What is **not** covered yet: [docs/reference/open-questions.md](docs/reference/open-questions.md) (coverage gaps listed first).

## Start here
| Question | Doc |
|---|---|
| What is Armada? | [overview](docs/armada/overview.md) |
| Install / update / uninstall | [install-sd](docs/armada/install-sd.md) · [install-internal](docs/armada/install-internal.md) · [updating-ota](docs/armada/updating-ota.md) · [restore-android](docs/armada/restore-android.md) |
| Using it | [armada-control](docs/armada/armada-control.md) · [armada-store](docs/armada/armada-store.md) · [desktop-mode](docs/armada/desktop-mode.md) · [faq](docs/armada/faq.md) · [known-issues](docs/armada/known-issues.md) |
| Thor on Armada | [devices-ayn](docs/armada/devices-ayn.md) · [thor-changelog](docs/armada/thor-changelog.md) · [thor-issues-and-prs](docs/armada/thor-issues-and-prs.md) · [dual-screen](docs/armada/dual-screen.md) · [thor-issue-findings](docs/armada/thor-issue-findings.md) |
| Every release | [release-history](docs/armada/release-history.md) |
| Forks and related repos | [forks-and-related](docs/armada/forks-and-related.md) |
| Hardware | [specs](docs/hardware/specs.md) · [variants-pricing](docs/hardware/variants-pricing.md) · **[device-observed](docs/hardware/device-observed.md)** (live survey) · [tuning-recommendations](docs/hardware/tuning-recommendations.md) |
| Comparisons | [thor-vs-odin2-odin3-others](docs/comparison/thor-vs-odin2-odin3-others.md) · [android-vs-armada](docs/comparison/android-vs-armada.md) |
| Kernel / boot | [devicetree-thor](docs/boot-kernel/devicetree-thor.md) · [boot-chain](docs/boot-kernel/boot-chain.md) |
| Stock Android side | [bootloader-root](docs/android/bootloader-root.md) · [community-tools](docs/android/community-tools.md) |
| Sources / claims / gaps | [sources](docs/reference/sources.md) · [claims-log](docs/reference/claims-log.md) · [open-questions](docs/reference/open-questions.md) · [glossary](docs/reference/glossary.md) |

## Key findings (2026-10-04)
- **Armada Upstream:** Canonical repo is `armada-os/armada` (latest tag `20260926`; `main` at `574da80`); `virtudude/armada` is a redirect; `SilentBob347/armada-os` has zero unique commits; `Ga1dz1/armada` is an archived SM8250 fork; only `MgeeeeK/thor-armada` is Thor-specific (80% charge limit service + SDR104 kernel).
- **Device Support:** Thor is "Tested" on Armada (SM8550); Thor Lite (SM8250) was added in `20260915` and is "Untested" in docs.
- **Displays & Dual Screen:** Top = DSI-2 (ICNA3520 panel, 1080×1920 120Hz), bottom = DSI-1 (CH13726A panel, 1080×1240 60Hz); Desktop Mode uses both heads; Game Mode runs a secondary gamescope via DRM lease (experimental since `20260907`).
- **Devicetree Lineage:** Thor dts in Armada is byte-identical to ROCKNIX's base copy; Armada applies a patch for hall wake (`EV_ACT_DEASSERTED`), touch orientation, and DPU 8bpc dithering.
- **Hardware Verification (on Ven's Thor Max 1 TB):**
  - **UFS 4.0 confirmed:** Device descriptor `0x0400` (SK Hynix) resolves the press vs. batch-6 vendor page discrepancy.
  - **microSD SDR104 confirmed:** Stock kernel 7.2.6 negotiates SDR104 @ 202 MHz on Samsung SDXC (89.5 MB/s sequential read) without third-party kernel patches.
  - **ABL v1.1.8 confirmed:** Both `abl_a` and `abl_b` match the approved SM8550 manifest hash.
  - **Thermals & Power:** Performance profile pins GPU to 680 MHz (~73 °C load, 48–53 °C idle).
- **Community Tooling & Mods:**
  - **Audio Fix:** `thor-armada-audio-fix` (JamesDSP Flatpak) installed and running to correct speaker acoustics.
  - **Lossless Scaling:** Official `Lossless.dll` staged to Steam path and linked in `~/.config/lsfg-vk/conf.toml`.
  - **barry-launcher:** Missing Qt6 QML runner and `xdotool` dependencies successfully resolved by extracting Fedora 44 RPMs into `~/.local/opt/barry-deps` in user space without modifying the immutable OS root.
