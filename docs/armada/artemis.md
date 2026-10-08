# Artemis on AYN Thor (Armada OS)
> Scope: the Artemis Qt streaming client as built for the Thor · Researched: 2026-10-05, re-sourced and measured on the device 2026-10-07 · Confidence: medium. File names, the CLI, the decoder list, the build container and the Steam registration were checked against the source tree (`venatrix-ritz/artemis`, branch `feat/thor-aarch64`, commit `3046d4a`, kept outside this repo at `G:ProjectsPCUtilsProgramsGame StreamingArtemis-Source`). The hardware-decode behaviour below was measured on the Thor. The earlier version failed to credit the client's author; that is fixed below.

## What it is
**Artemis Qt** is an enhanced Moonlight Qt client for NVIDIA GameStream and [Apollo](https://github.com/ClassicOldSong/Apollo)/[Sunshine](https://github.com/LizardByte/Sunshine) hosts, by **wjbeckett** ([wjbeckett/artemis](https://github.com/wjbeckett/artemis)). It is built on [Moonlight Qt](https://github.com/moonlight-stream/moonlight-qt) by the Moonlight Team, with feature inspiration from Artemis Android by ClassicOldSong. Licence GPL-3.0. [src: Artemis-Source@3046d4a:README.md#L3-L12; Artemis-Source@3046d4a:LICENSE#L1-L2] The Thor work (container build, deploy script) sits on a fork, `venatrix-ritz/artemis`, with `wjbeckett/artemis` as its `upstream` remote. [src: Artemis-Source@3046d4a: `git remote -v`; Artemis-Source@3046d4a: commit 3046d4a "add aarch64 podman containerfile, build script, and Steam deployment integration"]

## Video decoding (measured on the Thor, 2026-10-07)
- **Hardware exists and works:** the Thor exposes the Qualcomm Iris decoder and encoder as `/dev/video0` / `/dev/video1` (`qcom-iris-decoder`, `qcom-iris-encoder`, driver `iris_driver`). FFmpeg 8.1.3 (negativo17 build, full codec set) opened `h264_v4l2m2m` and `hevc_v4l2m2m` on the Iris decoder and decoded 60 frames of 720p each. [observed 2026-10-07: `ffmpeg -decoders`, piped test decode]
- **Artemis's automatic search does not use it.** In the Steam launch log (`~/.local/share/armada/logs/steam-launch-*.log`; Artemis's stdout/stderr go there, there is no `/tmp/Artemis-*.log` because `LOG_TO_FILE` is not defined for this build) the startup probe prints `Unable to find working decoder for format: 100` (HEVC), `200` (HEVC Main10), `1000`/`2000` (AV1), then streams H.264 with FFmpeg's software `h264` decoder through the SDL renderer. No v4l2 line appears at all, so no `*_v4l2m2m` decoder was ever tried. That is the "No functioning hardware accelerated video decoder" warning. [observed 2026-10-07: steam-launch log]
- **Naming the decoder works.** Artemis reads `H264_DECODER_HINT` / `HEVC_DECODER_HINT` / `AV1_DECODER_HINT` before its own search. [src: Artemis-Source@3046d4a:app/streaming/video/ffmpeg.cpp#L1560-L1620] With `HEVC_DECODER_HINT=hevc_v4l2m2m` a 25 s test run logged `hevc_v4l2m2m … Using device /dev/video0 … driver 'iris_driver' on card 'Iris Decoder'`, `output: HEVC … capture: NV12`, then `Using custom HEVC decoder (HEVC_DECODER_HINT): hevc_v4l2m2m` and `FFmpeg-based video decoder chosen`. HEVC Main10 and `av1_v4l2m2m` were rejected in the same run, so only H.264 and HEVC are hinted. [observed 2026-10-07]
- **Why the automatic search misses it was not found.** The FFmpeg list also contains AMF/CUVID wrappers that fail to load (`libamfrt64.so.1`, `libnvcuvid.so.1`) before the v4l2 decoders are reached; that is a likely but unproven reason.
- **Fix:** a tracked launcher that exports the two hints: `scripts/artemis-thor-launcher.sh` on branch `fix/thor-v4l2-decoder-hints` of `venatrix-ritz/artemis`. The H.264 hint is not yet confirmed inside Artemis (its probe printed no H.264 line); a failed hint falls back to the normal search. Real streaming performance with hardware decode is untested.

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
