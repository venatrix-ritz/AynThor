# AYN Thor vs. Odin 2, Odin 3, and Related Handhelds
> Scope: comparative hardware, display architecture, and Armada OS support across AYN and competing ARM handhelds · Researched: 2026-10-04 · Confidence: high for Armada configs/SoCs; medium for physical specs from reviews

## Comparison Matrix

| Specification / Property | AYN Thor | AYN Thor Lite | AYN Odin 2 / Mini / Portal | AYN Odin 3 | AYANEO Pocket DS |
|---|---|---|---|---|---|
| **Form Factor** | Clamshell (dual-screen) | Clamshell (dual-screen) | Candybar (single-screen) | Candybar (single-screen) | Clamshell (dual-screen) |
| **SoC** | Snapdragon 8 Gen 2 (SM8550 / QCS8550) | Snapdragon 865 (SM8250) | Snapdragon 8 Gen 2 (SM8550) | Snapdragon 8 Elite (SM8750) | Snapdragon 8 Gen 2 (SM8550) |
| **CPU Architecture** | 1x Cortex-X3 + 4x A715/A710 + 3x A510 | 1x Cortex-A77 + 3x A77 + 4x A55 | 1x Cortex-X3 + 4x A715/A710 + 3x A510 | Oryon CPU architecture | 1x Cortex-X3 + 4x A715/A710 + 3x A510 |
| **GPU** | Adreno 740 | Adreno 650 | Adreno 740 | Adreno 830 | Adreno 740 |
| **Primary Display** | 6.0" AMOLED, 1080×1920, 120 Hz | 6.0" AMOLED, 1080×1920, 120 Hz | Odin 2: 6.0" IPS 60Hz / Mini: 5.0" Mini-LED / Portal: 7.0" OLED 120Hz | 6.0" AMOLED (120 Hz) | 7.0" OLED, 1080×1920 |
| **Secondary Display** | 3.92" AMOLED, 1080×1240, 60 Hz | 3.92" AMOLED, 1080×1240, 60 Hz | None | None | 3.4" IPS / LCD |
| **Battery** | 6000 mAh | 6000 mAh | 8000 mAh (Base) / 5000 mAh (Mini) | 8000 mAh | ~6500 mAh |
| **Armada Status** | **Tested** (since 20260612) | **Untested** (added 20260915) | **Tested** | **Tested** | **Tested** (since 20260907) |
| **Armada Device ID** | `ayn-thor` | `ayn-thor-lite` | `ayn-odin-2` / `-mini` / `-portal` | `ayn-odin-3` | `ayaneo-pocket-ds` |
| **Primary Connector** | `DSI-2` (`mdss_dsi1`) | `DSI-1` (`mdss_dsi0`) | Direct / default DRM | Direct / default DRM | `DSI-1` (`mdss_dsi0`) |
| **Secondary Connector** | `DSI-1` (`mdss_dsi0`) | `DSI-2` (`mdss_dsi1`) | None | None | `DSI-2` (`mdss_dsi1`) |
| **Panel Orientation** | `right` | `right` | `right` | `right` | `left` |
| **Target HDR Nits** | 650 | Not set | Not set (Portal: OLED HDR) | 650 | 780 |

[src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/*.conf] [src: refs/upstream/armadaos.dev@26dcfc3:docs/devices/supported-devices.md] [src: docs/hardware/specs.md]

---

## Architectural & Practical Differences

### 1. Dual-Screen Routing and Gamescope Pipelines
- **Single-Screen Devices (Odin 2 family, Odin 3):**
  Armada runs standard `gamescope-session-steam`. A single connector is owned by gamescope directly via KMS/DRM. No auxiliary leasing daemon or secondary frame allocation is needed.
- **AYN Thor (`ayn-thor`):**
  Gamescope drives only `DSI-2` (top 1080×1920 120Hz panel). The bottom panel `DSI-1` is disabled in Game Mode unless experimental dual-screen is enabled. When enabled, a secondary gamescope instance runs via DRM leasing (`/tmp/gamescope-lease.sock`). In Desktop Mode, KDE KWin manages both heads simultaneously (top primary, bottom secondary).
- **AYANEO Pocket DS (`ayaneo-pocket-ds`):**
  Inverts the connector assignment compared to Thor (`DSI-1` primary, `DSI-2` secondary), uses `ARMADA_PANEL_ORIENTATION=left`, sets `ARMADA_SYNC_SUSPEND=1`, and controls the bottom backlight via `sy7758-backlight` instead of Qualcomm DSI backlight sysfs.

### 2. Thermal and Form Factor Trade-offs
- **Clamshell vs. Candybar:**
  The Thor's clamshell hinge separates the primary display from the mainboard/chassis base where the SoC, heatpipe, and active fan sit. In candybar devices like Odin 2 and Odin 2 Portal, heat dissipates directly behind the primary screen, leading to higher screen surface temperatures under load.
- **Battery Life Impact:**
  The Thor's dual AMOLED screens draw noticeably more power when both displays are engaged simultaneously (~15–25% faster drain). Odin 2's large 8000 mAh battery with a single display delivers significantly longer continuous runtimes (often 6–10 hours vs. 3–5 hours on Thor under similar loads).

### 3. Emulation Alignment
- **Thor's Dual-Screen Advantage:**
  Nintendo DS (melonDS, Drastic) and Nintendo 3DS (Citra, Azahar) map natively 1:1 onto Thor's dual vertical form factor without awkward splitscreen, picture-in-picture, or external monitor setups.
- **Odin 2 / Odin 3 Screen Space Advantage:**
  Single 16:9 widescreen games (PSP, PS2, Switch, Steam PC games via Proton) benefit from Odin 2's ergonomic centered stick layout and larger single screen (especially the 7" Odin 2 Portal).

---

## Sources
- [S1] `refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/{ayn-thor.conf, ayn-thor-lite.conf, ayn-odin-2.conf, ayn-odin-3.conf, ayaneo-pocket-ds.conf}`
- [S2] `refs/upstream/armadaos.dev@26dcfc3:docs/devices/supported-devices.md`
- [S3] `docs/hardware/specs.md` and `docs/hardware/device-observed.md`
