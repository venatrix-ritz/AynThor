# Artemis on AYN Thor (Armada OS)

> **Audit 2026-10-07 — unverified.** This doc has no citations. The claims about the V4L2 hardware decoders (`hevc_v4l2m2m`, `h264_v4l2m2m`), native ARM64 build and Game Mode integration were not checked against the Artemis source or on the device. Treat as `[UNVERIFIED]`. See `docs/reference/open-questions.md`.

## Overview
**Artemis** is an enhanced, high-performance client fork of Moonlight Qt specifically optimized for pairing with [Apollo](https://github.com/ClassicOldSong/Apollo) and Sunshine host servers. 

On the AYN Thor (Snapdragon 8 Gen 2 / aarch64 Linux running Armada OS), Artemis provides:
- Native ARM64 binary execution (no FEX-Emu or translation overhead).
- Hardware-accelerated HEVC and H.264 video decoding via Qualcomm V4L2 mem2mem driver (`hevc_v4l2m2m`, `h264_v4l2m2m`).
- Apollo OTP pairing and automatic virtual display resolution switching.
- Full Steam Game Mode integration with custom portrait capsules, wide banners, hero artwork, and logos.

---

## Installation & Paths

| Component | Path |
|---|---|
| Launcher Executable | `~/.local/share/artemis/bin/artemis` (symlinked to `~/.local/bin/artemis`) |
| Native ARM64 Binary | `~/.local/share/artemis/bin/artemis.bin` |
| Bundled Libraries | `~/.local/share/artemis/lib/libSDL2_ttf-2.0.so.0*` |
| Desktop Entry | `~/.local/share/applications/artemis.desktop` |
| Steam Non-Steam Shortcut | Registered in `userdata/<steam_id>/config/shortcuts.vdf` |
| Steam Grid Artwork | `userdata/<steam_id>/config/grid/` (Capsules, Banners, Hero, Logos) |

---

## Hardware Decoding & Performance
The AYN Thor's Adreno 740 GPU and Qualcomm video processing engine expose native V4L2 M2M hardware decode endpoints in Linux:
- `hevc_v4l2m2m`: HEVC / H.265 10-bit & 8-bit NV12 decode with zero-copy buffer pooling.
- `h264_v4l2m2m`: H.264 AVC decode.

Artemis automatically probes and selects the hardware decoder on startup.

---

## Pairing with Apollo / Sunshine

### 1. From Steam Game Mode
1. Select **Artemis** from the Steam library (under "Non-Steam Games" or "Streaming").
2. Artemis opens in fullscreen Gamescope on the main screen (`DISPLAY=:0`).
3. Discovered hosts on the local network appear automatically via mDNS (`qmdnsengine`).
4. Click on the Apollo host and enter the pairing PIN or authenticate with Apollo OTP.

### 2. From CLI
```bash
# Pair directly with Apollo / Sunshine host
artemis pair <host_ip_or_name> --pin <4_digit_pin>

# List streamable apps from host
artemis list <host_ip_or_name>

# Launch stream directly
artemis stream <host_ip_or_name> "Desktop"
```

---

## Build Architecture (Reproducible Container Build)

The build utilizes a Fedora 44 ARM64 Podman container matching the Armada OS runtime ABI:

```bash
# 1. Build container image
podman build -t artemis-builder:latest -f scripts/Containerfile.thor .

# 2. Configure with qmake6
podman run --rm -v "$(pwd):/src:z" -w /src artemis-builder \
    qmake6 artemis.pro CONFIG+=release QMAKE_CXXFLAGS+=-fPIC

# 3. Compile with 8 cores
podman run --rm -v "$(pwd):/src:z" -w /src artemis-builder \
    make -j8

# 4. Strip & deploy
podman run --rm -v "$(pwd):/src:z" -w /src artemis-builder \
    strip -o /src/app/artemis-stripped /src/app/artemis
python3 scripts/deploy-thor-steam.py
```

---

## Credits & Attribution
- **Artemis / Moonlight Qt**: Cameron Gutman, Diego Waxemberg, and the Moonlight Game Streaming Project contributors.
- **Apollo**: ClassicOldSong & contributors for Sunshine / Apollo enhancements.
- **Armada OS & Project Barry**: lavachemist and the Armada OS team for Linux on Snapdragon handhelds.
