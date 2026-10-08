# Community Tools and Guides (Armada OS)
> Scope: community add-ons seen for the Thor on Armada, with what their own READMEs say · Researched: 2026-10-04, re-sourced 2026-10-07 · Confidence: medium. Removed from the earlier version: a "JamesDSP audio-fix script suite" with named files and a claim that CocoonFE runs inside Waydroid; neither appears in any cloned source.

## Bottom-screen launchers
- **Barry Launcher** ([project-barry/barry-launcher](https://github.com/project-barry/barry-launcher), GPL-2.0): a home screen for the Thor's bottom screen while SteamOS-style Game Mode runs on the top; tiles, an on-screen keyboard, a trackpad/keyboard app, and a performance dashboard shown by a short press of the AYN button (hold AYN to return home). [src: refs/community/barry-launcher@13ab555:README.md#L10-L41]
  - It needs Game Mode's gamescope started with `--lease-connector <bottom connector>` and `--drm-lease-client`; the README says Armada and pb-os Thor images do this. [src: refs/community/barry-launcher@13ab555:README.md#L83-L86]
  - Install adds a udev rule (so your user can read the AYN button) and, on the Thor, an InputPlumber override so InputPlumber stops handling the AYN button; reboot afterwards. [src: refs/community/barry-launcher@13ab555:README.md#L105-L108]
  - On Armada it turns off Armada's own bottom-screen session (Plasma Mobile, `armada-bottom-screen.service`) because only one session can hold the bottom screen. [src: refs/community/barry-launcher@13ab555:README.md#L158-L159]
  - Not installed on the surveyed Thor on 2026-10-07. [observed 2026-10-07: docs/hardware/device-observed.md]
- **Cocoon** ([inssekt/CocoonFE](https://github.com/inssekt/CocoonFE), site cocoon-shell.com): listed as a dual-screen launcher in a community Thor config list, i.e. an Android-side launcher. [src: refs/thor-android/ayn-thor-config@1961dee:README.md#L50]

## Audio
- **ThorTune** (androosio/thortune, GPL-2.0) is an Android app that drives JamesDSP with "Joey's Retro Handhelds tuning made for the Thor's speakers"; it is not an Armada tool. [src: refs/thor-android/thortune@4b80497:README.md#L13, #L32-L36]
- **Speaker EQ on Armada:** this repo's `tweaks/audio/50-thor-speaker-eq.conf` (PipeWire filter-chain, adapted from RetroPup/AlsoAmphy's JamesDSP preset); see `CREDITS.md`.

## How add-ons are installed on this immutable image
What the surveyed Thor actually has: a user systemd unit (`~/.config/systemd/user/touch-master.service`), Decky plugins in `~/homebrew/plugins` (`armada-control`, `armada-store`, `thor-input`), Flatpaks (e.g. WebCord) and system units added under `/etc/systemd/system` with their binaries in `/var/local/bin` (`/usr/local/bin` exists but is empty and root-owned; why the tweaks use `/var/local/bin` instead was not tested). [observed 2026-10-07: docs/hardware/device-observed.md]

## Sources
- [S1] refs/community/barry-launcher@13ab555:README.md
- [S2] refs/thor-android/ayn-thor-config@1961dee:README.md; refs/thor-android/thortune@4b80497:README.md
- [S3] On-device survey 2026-10-07
