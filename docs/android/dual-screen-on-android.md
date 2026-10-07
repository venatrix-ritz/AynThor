# Dual Screen & System Architecture on Android (AYN Thor)

> **Audit 2026-10-07 — partly unverified.** The 16 `[src:]` tags point at files that exist in `refs/`, but their content was not re-checked. The rest — `Settings.System` keys, `/vendor/usr/idc/*` paths, app package names — has no citation and was not re-verified; treat as `[UNVERIFIED]`. See `docs/reference/open-questions.md`.

> Scope: Hardware DTS, SurfaceFlinger, DisplayManager, WindowManager, and community orchestration mechanisms on stock Android 13 and LineageOS · Researched: 2026-10-05 · Confidence: partly unverified (see banner) [src: refs/thor-android/]

---

## 1. Hardware & Kernel Display Topology

The AYN Thor runs Qualcomm Snapdragon 8 Gen 2 (SM8550 / Moorechip Board ID 4 `kalamap-ayn-odin2-thor`) driving two independent MIPI-DSI display panels through Qualcomm's Mobile Display Subsystem (MDSS / SDE).

### Display Interfaces
Both panels are manufactured as native portrait glass and rotated 90° clockwise in SurfaceFlinger:

| Parameter | Top (Primary) Display | Bottom (Secondary) Display |
|---|---|---|
| **DSI Port** | `&sde_dsi1` (`label = "primary"`) | `&sde_dsi` (`label = "secondary"`) |
| **Kernel Node** | `msm_drm.moorechip_dsi_display0` | `msm_drm.moorechip_dsi_display1` |
| **Driver / Panel** | Chipone ICNA3520 DSC Command Mode (`dsi_icna3520_1080p_dsc_cmd`) | Chipone CH13726A AMOLED Video Mode (`dsi_ch13726a_amoled_video`) |
| **Physical Resolution** | 1080 × 1920 (native portrait) | 1080 × 1240 (native portrait) |
| **Landscape Resolution**| 1920 × 1080 | 1240 × 1080 |
| **Refresh Rate** | 120 Hz (up to 120 fps) | 60 Hz |
| **SurfaceFlinger Orientation** | `ro.surface_flinger.primary_display_orientation=ORIENTATION_90` | `ro.surface_flinger.secondary_display_orientation=ORIENTATION_90` |
| **Display Density** | 320 dpi (`TARGET_SCREEN_DENSITY := 360` in board config, 320 in display XML) | 320 dpi |
| **Peak Brightness** | 650 nits | 500 nits (`screenBrightnessMap`: 0.0=2 nits, 1.0=500 nits) |
| **Reset GPIO** | GPIO 137 (`&tlmm 137 0`) | GPIO 133 (`&tlmm 133 0`) |
| **Power Supplies** | VCI: `&L14B` (3.0V), VDD: `&display_panel_avdd` | AVDD2: GPIO 143 (`display_panel_avdd2`, 2.8V), VDDIO: GPIO 70 (`display_panel_vddio`, 1.8V) |
| **Backlight Control** | DCS backlight commands (`bl_ctrl_dcs`), enable GPIO 52 (`&tlmm 52 0`) | DCS backlight commands (`bl_ctrl_dcs`) |

[src: `refs/thor-android/android_kernel_ayn_qcs8550-devicetrees/moorechip/display/display/kalama-sde-display-ayn-odin2-thor.dtsi#L3-L342`]  
[src: `refs/thor-android/android_device_ayn_odin2thor/properties/vendor.prop#L5-L10`]

---

## 2. Touchscreen Subsystem & IDC Configurations

Both displays utilize FocalTech touch controllers communicating over independent I2C buses with unique hardware IDs:

### Primary Touchscreen (Top)
- **Controller:** FocalTech FT3519 (`focaltech,fts_ts`, IC type `0x35190489`)
- **Bus:** `&qupv3_se4_i2c` at I2C address `0x38`
- **Interrupt:** GPIO 25 (`&tlmm 25 0x2008`)
- **Reset:** GPIO 24 (`&tlmm 24 0`)
- **Coordinates:** `0 0 1080 1920` (10-point multi-touch)
- **IDC File:** `/vendor/usr/idc/fts_ts.idc`
  ```properties
  device.internal = 1
  touch.deviceType = touchScreen
  touch.orientation = ORIENTATION_90
  touch.displayId = local:4630946441858561667
  ```

### Secondary Touchscreen (Bottom)
- **Controller:** FocalTech FT3519 (`focaltech,fts_ts`, IC type `0x35190489`)
- **Bus:** `&qupv3_hub_i2c3` at I2C address `0x38`
- **Interrupt:** GPIO 15 (`&tlmm 15 0x2008`)
- **Reset:** GPIO 14 (`&tlmm 14 0`)
- **Power Regulators:** `ts_avdd_3v0` on GPIO 144 (3.0V), `ts_vddio_1v8` on GPIO 102 (1.8V)
- **Coordinates:** `0 0 1080 1240` (10-point multi-touch)
- **IDC File:** `/vendor/usr/idc/fts_ts_secondary.idc`
  ```properties
  device.internal = 1
  touch.deviceType = touchScreen
  touch.orientation = ORIENTATION_90
  touch.displayId = local:4630946482288158084
  ```

[src: `refs/thor-android/android_device_ayn_odin2thor/configs/idc/fts_ts.idc#L1-L13`]  
[src: `refs/thor-android/android_device_ayn_odin2thor/configs/idc/fts_ts_secondary.idc#L1-L13`]  
[src: `refs/thor-android/android_kernel_ayn_qcs8550-devicetrees/moorechip/display/display/kalama-sde-display-ayn-odin2-thor.dtsi#L262-L322`]

---

## 3. Display States & DisplayManager Configuration

Android handles the clamshell states using `device_state_configuration.xml` and `display_layout_configuration.xml`:

### Device States
1. **State 0 — `DUAL_SCREEN` (Standard Open Clamshell):**
   - Top screen (`local:4630946441858561667`): `enabled="true"`, `defaultDisplay="true"`.
   - Bottom screen (`local:4630946482288158084`): `enabled="true"`, `leadDisplayAddress="4630946441858561667"`.
2. **State 1 — `TOP_SCREEN_ONLY`:**
   - Top screen enabled (defaultDisplay); bottom screen disabled.
3. **State 2 — `BOTTOM_SCREEN_ONLY`:**
   - Top screen disabled; bottom screen enabled (`defaultDisplay="true"`).

### Secondary Screen Capabilities
Configured in `/vendor/etc/display_settings.xml`:
```xml
<display-settings>
    <config identifier="0" />
    <display
        name="local:4630946482288158084"
        isHomeSupported="true"
        shouldShowIme="true" />
</display-settings>
```
- **`isHomeSupported="true"`:** Permits Android to host a home launcher activity directly on the bottom screen.
- **`shouldShowIme="true"`:** Directs on-screen soft keyboards (IMEs) to render on the bottom screen when text input is focused.

[src: `refs/thor-android/android_device_ayn_odin2thor/configs/display/device_state_configuration.xml#L1-L20`]  
[src: `refs/thor-android/android_device_ayn_odin2thor/configs/display/display_layout_configuration.xml#L1-L36`]  
[src: `refs/thor-android/android_device_ayn_odin2thor/configs/display/display_settings.xml#L1-L13`]

---

## 4. Multi-Display Window Manager & App Orchestration

### Launching on a Target Display
Both screens are exposed as standard public Android displays (`Display.DEFAULT_DISPLAY` for top, and the lowest non-zero `DisplayManager` ID for bottom). Any application can launch an activity onto a specific display without special system permissions:
```kotlin
val options = ActivityOptions.makeBasic().setLaunchDisplayId(displayId).toBundle()
context.startActivity(intent, options)
```
Shell fallback (requires Shizuku or shell uid):
```bash
am start --display <displayId> -n <package>/<activity>
```

### Live Task Migration Between Displays (Screen Swapping)
Unlike standard Android activity launches which restart the activity lifecycle, community tools (such as `thor-pathfinder`, `thor-wayfinder`, and `Thor-Swapper`) migrate running activities live without losing state or restarting game engines:
```bash
am display move-stack <rootTaskId> <targetDisplayId>
```
1. `am stack list` parses all active root tasks, their `displayId`, and visibility.
2. The frontmost non-excluded task on Display A is moved to Display B via `am display move-stack <taskA> <displayB>`.
3. If swapping both screens simultaneously, the task from Display B is moved to Display A in the same compound shell command (`am display move-stack <taskA> <displayB> && am display move-stack <taskB> <displayA>`).
4. To prevent video stutter, apps currently playing audio/video (`dumpsys media_session` state `STATE_PLAYING=3`) are moved first.
5. If only one app moves, the vacated screen receives a synthetic Home command:
   ```bash
   input -d <vacatedDisplayId> keyevent KEYCODE_HOME
   ```

### Home Launchers Across Screens
- **Top Display:** Launches standard `Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)`.
- **Bottom Display:** Queries `Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_SECONDARY_HOME)`. On stock AYN firmware, the primary claimant is **Cocoon** (`com.ayn.cocoon` / AYN bottom launcher), falling back to `com.android.launcher3` or community launchers like `Jarngreipr`.

[src: `refs/thor-android/thor-pathfinder/app/src/main/kotlin/com/thorpathfinder/app/ScreenSwap.kt#L1-L197`]  
[src: `refs/thor-android/thor-pathfinder/app/src/main/kotlin/com/thorpathfinder/app/Launcher.kt#L1-L119`]

---

## 5. Screen Focus Lock & Controller Routing

Because Android's input pipeline routes gamepad buttons, D-pads, and focus keys to the currently focused window, dual-screen setups require an explicit mechanism to choose which display receives controller input:

### Focus Lock Mechanism
AYN implements Focus Mode in `DualScreenAssistant` and `OdinSettings`:
- Setting key: `Settings.System.screen_focus_lock`
  - `0`: Auto-lock (follows window focus)
  - `1`: Top screen locked
  - `2`: Bottom screen locked
- **OEM Input Routing Property:** `OdinSettings` monitors `screen_focus_lock` and updates the system property `persist.sys.input.dispaly` (note OEM spelling) to `0`, `1`, or `2`.
- **Synthetic Focus Tap:** When switching focus lock to a specific display, `OdinSettings` injects a synthetic touch event at off-screen coordinates `(-10, -10)` on that display, forcing the Android window manager to shift input focus without interacting with visible UI elements.

[src: `refs/thor-android/thor-pathfinder/app/src/main/kotlin/com/thorpathfinder/app/FocusMode.kt#L1-L79`]

---

## 6. Audio, Brightness, & Hardware Controls

### Independent Screen Audio Volumes
The AYN Thor firmware decouples volume control for the two screens:
- **Top Screen Audio:** Standard Android media volume (`AudioManager.STREAM_MUSIC`, stream index `3`, 0–15 scale):
  ```bash
  cmd media_session volume --stream 3 --set <level>
  ```
- **Bottom Screen Audio:** Managed via AYN system setting `secondary_screen_volume_level` (0–15 scale):
  ```bash
  settings put system secondary_screen_volume_level <level>
  ```
- **Physical Amps & Codec:** Qualcomm WCD9385 SoundWire codec + stereo Awinic AW883xx Smart Power Amplifiers (`awinic,aw883xx_smartpa` on `&qupv3_hub_i2c2`, Left `0x34`, Right `0x35`).

### Per-Screen Brightness
- **Top Screen:** Managed via standard Android display brightness settings.
- **Bottom Screen:** Controlled via `DisplayManager.setBrightness(bottomDisplayId, floatValue)` using Android's standard HLG gamma curve (`BrightnessUtils`).

### Power & Charging Control
Stock firmware exposes hardware charging bypass and limits via sysfs:
- **Direct Power Supply (Bypass Charging):**
  - Setting: `Settings.System.is_charging_separation` (`1` = active)
  - Sysfs node: `/sys/class/qcom-battery/usb_charge_now` (`0` = device runs directly from USB charger, battery rests; `1` = normal battery charging)
- **80% Battery Charge Limit:**
  - Setting: `Settings.System.percent_80_charge_limit` (`1` = active)
  - Sysfs node: `/sys/class/qcom-battery/limit_capacity_charge` (`1` = halt charging at 80%)

### Fan Cooling Modes
- **Setting:** `Settings.System.fan_mode`
  - Values: `0` = Off, `1` = Quiet, `4` = Smart (default), Sports, Custom
- **Hardware Driver:** PM8550 PMIC PWM GPIO 8 (`pwm4`, period 50,000 ns) driving 5.0V fan regulator on GPIO 109 (`&tlmm 109`).

### Gamepad-to-Mouse Mode
- **Setting:** `Settings.System.global_gamepad_to_mouse_mode` (`0` or `1`)
- **Daemon:** `com.odin.mapping` via native library `librsinput`
- **Config Path:** `/sdcard/<model>_Settings/global_mouse_mode_config.json`
- **Right Stick Emulation:** Right stick operates as `RIGHT_JOYSTICK` type 3003 (`ST_MOUSE_MOVE_TOUCHSCREEN`), simulating touch drag gestures.

[src: `refs/thor-android/thor-wayfinder/app/src/main/java/app/wayfinder/Charging.kt#L1-L100`]  
[src: `refs/thor-android/thor-pathfinder/app/src/main/kotlin/com/thorpathfinder/app/ScreenVolume.kt#L1-L68`]  
[src: `refs/thor-android/thor-pathfinder/app/src/main/kotlin/com/thorpathfinder/app/MouseMode.kt#L1-L95`]  
[src: `refs/thor-android/android_kernel_ayn_qcs8550-devicetrees/moorechip/thermal/kalamap-moorechip-thermal.dtsi#L1-L40`]
