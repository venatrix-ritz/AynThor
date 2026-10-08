# Emulation Settings for Android
> Scope: which emulators and settings the community recommends on the Thor's stock Android · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: medium; one community config repo is the only source. The earlier version attributed the wrong forks (it called SapphireRhodonite's fork "MelonDS" and named an "SSimco Cemu port"), invented menu option names and called Azahar "the gold standard"; all of that is replaced by what the source says.

All entries below come from one community Thor setup list (an Obtainium + Cocoon configuration). [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L26-L52]

## Dual-screen emulators (per that list)
| System | App | What the list says |
|---|---|---|
| Nintendo DS | **melonDS Android** (rafaelvcaetano), official | "Native dual-screen support since 2.0.0". Older guides pointed to the **MelonDualDS** fork by SapphireRhodonite because the official app could not drive both screens; the official app gained that in April 2026. The fork still ships RC prereleases with a Vulkan renderer and per-ROM controller mapping, its source is unpublished (APKs only), and it installs alongside the official app as `me.magnum.melondualds`. [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L38, #L59-L66] |
| Wii U | **Cemu** (SapphireRhodonite's fork) | Listed as "SapphireRhodonite's dual-screen fork". [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L33] |
| 3DS | **Azahar** | Listed as the "Citra successor"; the list gives no dual-screen setting. [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L32] |

Recommended melonDS settings on the Thor: renderer OpenGL, internal resolution 4x, dual-screen preset "Internal: Top, External: Bottom", soft input behavior "Always Invisible". [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L65-L72]

## Other emulators on the list
Dolphin (GameCube/Wii), DuckStation (PS1), Eden (Switch), EmuCoreV and Vita3K (PS Vita), NetherSX2 Classic (PS2), PPSSPP (PSP), RetroArch (AArch64 build), RPCSX (PS3), X360 Mobile (Xbox 360, experimental). [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L34-L44]

## Frontends
**Cocoon** ([inssekt/CocoonFE](https://github.com/inssekt/CocoonFE)) is listed as the dual-screen launcher; Argosy Launcher (RomM client) and Obtainium (updater) are also listed. [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L50-L58] The earlier mention of Daijishou is dropped (not in the source).

## Not covered by a source
Specific in-emulator menu names for Azahar and Cemu dual-screen options (the earlier text gave "Secondary Display" and a "presentation API toggle"): `[UNVERIFIED]`. Dual-screen game lists: `refs/thor-android/Dual-Screen-Games` (codm2000) and `refs/thor-android/GAFT`.

## Sources
- [S1] refs/thor-android/ayn-thor-config@1961dee:README.md
