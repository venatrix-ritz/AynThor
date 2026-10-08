# Artemis on AYN Thor (Armada OS)
> Scope: the Artemis Qt streaming client as built for the Thor · Researched: 2026-10-05, re-sourced 2026-10-07 · Confidence: medium. File names, the CLI, the decoder list, the build container and the Steam registration were checked against the source tree (`venatrix-ritz/artemis`, branch `feat/thor-aarch64`, commit `3046d4a`, kept outside this repo at `G:\Projects\PCUtils\Programs\Game Streaming\Artemis-Source`). Whether the Thor's hardware video decoder is actually used is **not** verified. The earlier version failed to credit the client's author; that is fixed below.

## What it is
**Artemis Qt** is an enhanced Moonlight Qt client for NVIDIA GameStream and [Apollo](https://github.com/ClassicOldSong/Apollo)/[Sunshine](https://github.com/LizardByte/Sunshine) hosts, by **wjbeckett** ([wjbeckett/artemis](https://github.com/wjbeckett/artemis)). It is built on [Moonlight Qt](https://github.com/moonlight-stream/moonlight-qt) by the Moonlight Team, with feature inspiration from Artemis Android by ClassicOldSong. Licence GPL-3.0. [src: Artemis-Source@3046d4a:README.md#L3-L12; Artemis-Source@3046d4a:LICENSE#L1-L2] The Thor work (container build, deploy script) sits on a fork, `venatrix-ritz/artemis`, with `wjbeckett/artemis` as its `upstream` remote. [src: Artemis-Source@3046d4a: `git remote -v`; Artemis-Source@3046d4a: commit 3046d4a "add aarch64 podman containerfile, build script, and Steam deployment integration"]

## Video decoding
- The client's FFmpeg decoder candidate list includes `h264_v4l2m2m`, `hevc_v4l2m2m` and `av1_v4l2m2m` (next to Rockchip, NVIDIA and OMX variants). [src: Artemis-Source@3046d4a:app/streaming/video/ffmpeg.cpp#L70-L90] That is Moonlight Qt's generic probing list, not Thor-specific code.
- The earlier claims that the Adreno 740/Qualcomm video engine exposes V4L2 M2M endpoints with "zero-copy buffer pooling" and that this is used on the Thor have no source: `[UNVERIFIED]`. Check on the device with `v4l2-ctl --list-devices` and the client's log.

## CLI
`artemis pair <host> --pin <4 digits>`, `artemis list <host>`, `artemis stream <host> "<app>"` exist in the command-line parser (`pair`, `list`, `stream` positional actions and a `--pin` option). [src: Artemis-Source@3046d4a:app/cli/commandlineparser.cpp#L189-L193, #L260-L262] Apollo OTP pairing exists in the code (`PendingOTPPairingTask`). [src: Artemis-Source@3046d4a:app/backend/computermanager.cpp#L641-L652] mDNS discovery uses the bundled `qmdnsengine`. [src: Artemis-Source@3046d4a:app/app.pro#L521-L522]

## Install on the Thor
- On the surveyed Thor, `~/.local/bin/artemis` is a symlink to `~/.local/share/artemis/bin/artemis`. [observed 2026-10-07: docs/hardware/device-observed.md]
- `scripts/deploy-thor-steam.py` registers Artemis as a non-Steam shortcut (`shortcuts.vdf`, executable `/var/home/armada/.local/share/artemis/bin/artemis`, icon `…/share/icons/artemis.png`) and writes grid artwork into the Steam `config/grid` folder. [src: Artemis-Source@3046d4a:scripts/deploy-thor-steam.py#L3, #L41-L44, #L58-L59, #L85-L86]

## Build (container)
`scripts/Containerfile.thor` builds on `fedora:44` with Qt 6, SDL2, Opus, OpenSSL, libdrm, FFmpeg and Wayland development packages. [src: Artemis-Source@3046d4a:scripts/Containerfile.thor#L1-L9] A copy of that Containerfile and the `localhost/artemis-builder` image were present on the Thor on 2026-10-07 (`~/build`). [observed 2026-10-07]

## Credits
- **Artemis Qt:** wjbeckett and contributors; **Moonlight Qt:** the Moonlight Team (Cameron Gutman, Diego Waxemberg and contributors); **Artemis Android / Apollo:** ClassicOldSong. [src: Artemis-Source@3046d4a:README.md#L3-L12]
- Full list: `CREDITS.md`.

## Sources
- [S1] Artemis-Source@3046d4a (README.md, LICENSE, app/streaming/video/ffmpeg.cpp, app/cli/commandlineparser.cpp, app/backend/computermanager.cpp, scripts/Containerfile.thor, scripts/deploy-thor-steam.py)
- [S2] On-device survey 2026-10-07 (docs/hardware/device-observed.md)
