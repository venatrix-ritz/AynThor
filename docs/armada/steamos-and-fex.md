# SteamOS Integration & FEX GuestOS Architecture on ARM64
> Scope: How Armada adapts Valve's SteamOS ecosystem (steamos-manager, jupiter-hw-support, gamescope-session) and FEX-Emu to Snapdragon 8 Gen 2 on the AYN Thor · Researched: 2026-10-05 · Confidence: verified against primary source code in `refs/upstream/armada/packages/`, `refs/upstream/steamos-manager`, `refs/upstream/jupiter-hw-support`, and `refs/upstream/fex-emu`

---

## 1. Overview & Architectural Stack

Armada brings Valve's Steam Deck software stack to ARM64 handhelds by bridging three distinct execution layers:
1. **Native Host Layer (ARM64 Linux):** Fedora/Armada core OS, systemd, KWin/Wayland, Mesa Turnip (Adreno 740 Vulkan driver), `armada-powerd`, and `inputplumber`.
2. **Valve System Services (SteamOS Cloud daemons):** Patched `steamos-manager` and `jupiter-hw-support` providing Steam Deck UI integration, power telemetry, and storage helpers.
3. **FEX GuestOS Emulation Layer (x86/x86_64):** FEX-Emu running an Arch Linux guest rootfs overlay with Mesa thunking, executing x86 Proton and Windows game binaries with native Vulkan acceleration.

---

## 2. `steamos-manager` (System Daemon on ARM64)

### Upstream & Version Baseline
- **Source:** [`gitlab.steamos.cloud/holo/steamos-manager`](https://gitlab.steamos.cloud/holo/steamos-manager)
- **Pinned Commit:** `8e2883d0d7e2fc3994e822ca9853c03561ca6eec` (v26.4.1)
- **Role:** D-Bus daemon abstracting the operating system's hardware controls (power profiles, GPU clocks, thermal limits, controller profiles) for the Steam Big Picture UI.

### Device Matching on AYN Thor
Configured via `/usr/share/steamos-manager/devices/sm8550.toml`:
```toml
[[device]]
dt.compatible = "ayn,thor"
device        = "ayn_thor"
variant       = "Thor"
friendly_name = "AYN Thor"

[cpu_scaling]
driver = "none"
```
The daemon inspects `/sys/firmware/devicetree/base/compatible` and matches `ayn,thor`.

### Critical Patches Series (`0001`–`0012`)
Armada applies 12 patches on top of upstream `steamos-manager`:

1. **Patches `0001`–`0009` (Steam Frame Rebase):**
   - Incorporates Arun Raghavan's (`arunr/steam-frame`) upstream devfreq GPU clock scaling series.
   - Connects GPU frequency control directly to Qualcomm's Adreno devfreq sysfs node (`sysfs_path`), enabling the Steam Quick Access Menu (QAM) GPU manual clock slider with `gpufreq_limit` and minimum/maximum frequency clamps.
2. **Patch `0010` (Remote `CpuScaling1` Interface):**
   - *Problem:* Upstream `steamos-manager` unconditionally registers `CpuScaling1` and attempts to write CPU governors directly via `steamos-priv-write`. On Armada, `armada-powerd` owns the governor as part of dynamic power profiles. Steam's raw sysfs writes would conflict with Armada's power profiles or be rejected.
   - *Fix:* Sets `driver = "none"` in `sm8550.toml` and allows `CpuScaling1` to be served by a remote interface via `/etc/steamos-manager/remotes.d/`. This routes Steam UI power slider adjustments cleanly into `armada-powerd`.
3. **Patch `0011` (InputPlumber Target Device Protection):**
   - *Problem:* `DeckService` inside `steamos-manager` races `armada-controller-type.service` at boot. Without an `[inputplumber]` config section, `DeckService` unconditionally forces `[deck-uhid]`. Because `is_deck()` expects exactly one target device, Thor's composite keyboard and mouse extra targets were dropped without user notification.
   - *Fix:* Modifies `DeckService` to only manage target devices when explicitly configured in the device's TOML profile, allowing InputPlumber to preserve Thor's complete controller mapping.
4. **Patch `0012` (Wi-Fi Backend Pinning):**
   - *Problem:* Steam Big Picture derives its desired network backend from `steamos_wifi_force_wpa_supplicant`. When unset, Steam attempts to write `iwd` on every launch, breaking NetworkManager connections on platforms using `wpa_supplicant`.
   - *Fix:* Hardcodes `wpa_supplicant` in the daemon's Wi-Fi configuration writer.

[src: `refs/upstream/armada/packages/steamos-manager/PATCHES.md#L1-L40`]  
[src: `refs/upstream/armada/packages/steamos-manager/devices/sm8550.toml#L54-L75`]

---

## 3. `jupiter-hw-support` (Storage Safety & System Helpers)

### Upstream Baseline
- **Source:** [`gitlab.com/evlaV/jupiter-hw-support`](https://gitlab.com/evlaV/jupiter-hw-support) (`jupiter-3.7-20251020.1`)
- **Package:** `armada-jupiter-hw-support`

### UFS Flash Storage Protection (`0001-armada-storage-behavior.patch`)
The most dangerous incompatibility between x86 Steam Deck and ARM64 Qualcomm devices lies in storage block device naming:
- **Steam Deck (x86):** Internal storage is NVMe (`/dev/nvme0n1`), MicroSD is MMC (`/dev/mmcblk0`), and external flash drives are SCSI (`/dev/sd*`).
- **AYN Thor (SM8550):** The internal high-speed UFS flash memory is managed by the Linux SCSI subsystem and exposed as **`/dev/sda`**, `/dev/sdb`, `/dev/sdc`, etc.!

If unpatched SteamOS scripts ran on the Thor, selecting "Format SD Card" in Steam or triggering `steamos-automount.sh` on insertion could treat the internal UFS chip (`/dev/sda`) as an external storage drive, wiping internal Android and Armada installations.

#### The Patch Implementation:
1. **Removes `/dev/sd[a-z]` from Formatting Targets:**
   In `format-device.sh`:
   ```diff
   -    /dev/sd[a-z])
   -        STORAGE_PARTITION="${STORAGE_DEVICE}1"
   -        ;;
   ```
2. **System Mount Guard (`armada_is_system_storage_device`):**
   Checks `/sys/block/<disk>` against the physical parent disks backing critical mount points (`/`, `/var`, `/sysroot`, `/etc`, `/boot`, `/boot/efi`). If the target disk matches any system mount point, formatting is rejected immediately with `EBUSY` (error 16).
3. **SD Card Type Validation (`armada_is_sd_storage_device`):**
   Requires that the target block device matches `mmcblk[0-9]+` AND that `/sys/block/<disk>/device/type` explicitly contains `"SD"`.
4. **Automount Guard:**
   In `steamos-automount.sh`, non-SD devices and system storage devices are skipped silently without mounting or filesystem checks.
5. **Polkit Safety (`0002-armada-polkit-helper-safety.patch`):**
   Adds strict regex validation on hostnames before executing `hostnamectl` and scopes SSH service toggles strictly to `sshd.service`.

[src: `refs/upstream/armada/packages/jupiter-hw-support/patches/0001-armada-storage-behavior.patch#L1-L282`]  
[src: `refs/upstream/armada/packages/jupiter-hw-support/PATCHES.md#L1-L17`]

---

## 4. `gamescope-session` & Steam Client Bootstrap

### Session Orchestration
- **Package:** `gamescope-session` and `gamescope-session-steam` (sourced from OpenGamingCollective via Fyra Labs Terra repository at commit `23ec8c9aeaad28179925232fe7564f80da06d4ab`).
- **Launch Command:**
  Gamescope starts the primary session on `DSI-2` (top screen) and hosts the DRM leasing socket (`/tmp/gamescope-lease.sock`).
- **Steam Client ARM64 Bootstrap (`steam-bootstrap`):**
  - Valve does not provide an official public aarch64 desktop client installer, but produces internal ARM64 Steam client builds (`bins_linuxarm64_linuxarm64.zip` from `steam_client_${STEAM_ARM_CHANNEL}_linuxarm64`).
  - Armada's `steam-bootstrap` extracts these native ARM64 binaries and configures symlinks:
    - `~/.steam/sdk32` → `~/.local/share/Steam/linux32`
    - `~/.steam/sdk64` → `~/.local/share/Steam/linux64`
    - `~/.steam/sdkarm64` → `~/.local/share/Steam/linuxarm64`
  - Steam client itself runs as a native ARM64 process, avoiding emulation overhead for the store, Big Picture UI, and input processing.

[src: `refs/upstream/armada/packages/steam-bootstrap/generate.sh#L1-L50`]  
[src: `refs/upstream/armada/packages/gamescope-session-steam/build.sh#L1-L40`]

---

## 5. FEX-Emu GuestOS & Turnip Vulkan Pipeline

### FEX-Emu Architecture
When an x86 or x86_64 Windows game is launched through Proton, it cannot run directly on the ARM64 CPU. Armada uses **FEX-Emu** (`refs/upstream/fex-emu`, packaged via `fex-emu.spec` v26.04.1) for fast instruction translation with vector optimization.

### GuestOS Filesystem Overlay
1. **Rootfs SquashFS Images:**
   - `ArchLinux.sqsh`: Full x86_64 Arch Linux userland containing runtime libraries, glibc, and Proton dependencies.
   - `ArmadaMesa.sqsh`: Matched x86_64 Mesa libraries compiled against the guest environment.
2. **Mount Pipeline:**
   - Mounted via loopback overlay at `/usr/share/guestos/fex-mesa`.
   - FEX intercepts binary execution via Linux `binfmt_misc` (registering x86 ELF headers to the FEX interpreter) and redirects root paths to the guest sysroot.

### Adreno 740 Vulkan Thunking (Mesa Turnip)
The critical performance advantage in Armada's pipeline is **Vulkan Thunking**:
```
+-------------------------------------------------------------+
| x86_64 Windows Game / Proton (D3D11 / D3D12 via DXVK / VKD3D)|
+-------------------------------------------------------------+
                              |
                              v  (Guest x86 Vulkan calls)
+-------------------------------------------------------------+
| FEX Vulkan Thunk Layer (guest libvulkan.so)                  |
+-------------------------------------------------------------+
                              |
                              v  (Direct host pointer forwarding)
+-------------------------------------------------------------+
| Host Mesa Turnip Driver (ARM64 libvulkan_freedreno.so)      |
+-------------------------------------------------------------+
                              |
                              v  (Direct DRM / KGSL ioctls)
+-------------------------------------------------------------+
| Qualcomm Adreno 740 GPU Hardware (SM8550)                   |
+-------------------------------------------------------------+
```
- Instead of emulating an x86 GPU driver, FEX's Vulkan thunking serializes Vulkan API arguments and calls the host ARM64 Mesa Turnip driver (`libvulkan_freedreno.so`) directly.
- The Adreno 740 GPU processes commands at native hardware speed with zero CPU emulation cost on graphics rendering.

[src: `refs/upstream/armada/packages/fex/fex-emu.spec#L1-L150`]  
[src: `refs/upstream/armada/packages/mesa-x86/build.sh#L1-L30`]

---

## 6. Gaming Overlays & Auxiliary Tooling

### MangoHud (ARM64 Gaming Overlay)
- **Source:** [`github.com/flightlessmango/MangoHud`](https://github.com/flightlessmango/MangoHud) (v0.8.4)
- **ARM64 Compilation:** Built as an ARM64 Vulkan layer. Armada's patch series resolves Wayland subsurface presentation issues and integrates with gamescope's shared HUD buffer (`0022-mangoapp-keep-a-lease-client-off-the-shared-queue.patch`).

### Protontricks
- **Source:** [`github.com/Matoking/protontricks`](https://github.com/Matoking/protontricks) (v1.14.1.1)
- **Role:** Python utility for running Winetricks commands and configuring DLL overrides within Proton wineprefixes running under FEX emulation.

[src: `refs/upstream/armada/packages/mangohud/mangohud.spec#L1-L40`]  
[src: `refs/upstream/armada/packages/protontricks/protontricks.spec#L1-L30`]
