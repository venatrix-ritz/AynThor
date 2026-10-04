# Glossary & Technical Vocabulary
> Scope: definitions, acronyms, and hardware/software terms across the AYN Thor and Armada OS research repository · Researched: 2026-10-04 · Confidence: high

## Terminology

| Term | Domain | Definition & Context |
|---|---|---|
| **ABL** | Bootloader | **Android Bootloader**. On Qualcomm devices, the secondary bootloader stage. On Armada/ROCKNIX, `abl_a` and `abl_b` partitions are replaced with a custom signed ELF (`abl_signed-SM8550.elf`) that presents a pre-boot menu (VOL-) to configure device type, boot source (SD/Internal), and OS (Android/Linux). [src: docs/boot-kernel/boot-chain.md] |
| **adtbloader** | Boot / EFI | **ARM Device Tree Blob Loader**. An EFI driver from the Armada organization (`armada-os/adtbloader`) that locates and injects device tree blobs into the UEFI configuration table for ARM64 platforms. [src: refs/upstream/adtbloader@bf15d8b:README.md] |
| **Armada Control** | Armada OS | A pre-installed Decky plugin in Armada OS accessible via the Quick Access Menu (QAM). Provides UI controls for compatibility resolution overrides, power profiles (Quiet/Balanced/Performance), fan curves, controller remapping, and RGB lighting. [src: docs/armada/armada-control.md] |
| **Armada Store** | Armada OS | A pre-installed Decky plugin serving as a software repository in Gaming Mode. Distributes Flatpak emulators, handheld utilities, and Decky plugins with one-click installation and updates. [src: docs/armada/armada-store.md] |
| **barry-launcher** | Community Mod | A community Python/QML application by `project-barry` designed for dual-screen handhelds on Armada. Provides a bottom-screen application launcher, on-screen keyboard, top-screen trackpad, and performance dashboard via the AYN button. [src: docs/android/community-tools.md] |
| **bootc** | Linux / OS | **Bootable Containers**. Red Hat/Fedora technology that encapsulates the entire operating system root filesystem inside a standard OCI container image (e.g., `ghcr.io/armada-os/armada:beta`). Managed atomically via `ostree` and `bootc update`. [src: docs/armada/overview.md] |
| **CH13726A** | Hardware | The panel controller IC for the AYN Thor's **bottom secondary display** (3.92" AMOLED, 1080×1240, 60 Hz). Connected via `mdss_dsi0` (`DSI-1`). [src: docs/boot-kernel/devicetree-thor.md] |
| **Decky Loader** | SteamOS | An open-source plugin launcher for the Steam Deck UI / Game Mode. Exposes a dedicated tab in Steam's Quick Access Menu for third-party plugins. [src: docs/armada/armada-control.md] |
| **DPU Dithering** | Kernel / Graphics | Display Processing Unit hardware dithering. Armada's kernel patch for Thor introduces `armada,dpu-8bpc-dither` to downconvert the 10-bit internal pipeline cleanly to the 8bpc DSI link, preventing visual banding on AMOLED panels. [src: docs/boot-kernel/devicetree-thor.md] |
| **DRM Lease** | Graphics | **Direct Rendering Manager Leasing**. A Linux KMS capability where a display server (KWin or primary gamescope) leases control of an unused video connector (e.g., `DSI-1`) to another process (`armada-bottom-gamescope`), allowing two distinct gamescope instances to drive separate physical screens simultaneously. [src: docs/armada/dual-screen.md] |
| **FEX-Emu** | Emulation | An open-source fast x86 and x86_64 JIT emulator targeting 64-bit ARM Linux. Enables the ARM64 Steam client in Armada to execute standard PC x86 Windows and Linux binaries. [src: docs/armada/overview.md] |
| **FT5426 / FT5452** | Hardware | FocalTech capacitive touchscreen controller ICs used in the Thor. FT5426 drives the top panel touchscreen; FT5452 drives the bottom panel touchscreen. [src: docs/boot-kernel/devicetree-thor.md] |
| **gamescope** | SteamOS | Valve's micro-compositor that wraps Steam and running games, providing hardware scaling, integer scaling, FSR, frame limiting, and HDR tonemapping on Linux. [src: docs/armada/dual-screen.md] |
| **HTR3212** | Hardware | Heroic dual I2C LED driver ICs controlling the RGB LED rings around the AYN Thor's analog joysticks. [src: docs/boot-kernel/devicetree-thor.md] |
| **ICNA3520** | Hardware | Chipone display driver IC for the AYN Thor's **top primary display** (6.0" AMOLED, 1080×1920, 120 Hz). Connected via `mdss_dsi1` (`DSI-2`). [src: docs/boot-kernel/devicetree-thor.md] |
| **InputPlumber** | Linux / Input | A unified Linux daemon that maps physical raw input devices (like the AYN RSInput gamepad) into virtual game controllers (Xbox 360, DualSense, Steam Deck) with deadzone correction and stick calibration. [src: docs/hardware/device-observed.md] |
| **JamesDSP** | Audio | A digital signal processing library providing system-wide equalization, bass boost, and reverberation. Used via JDSP4Linux Flatpak in `thor-armada-audio-fix` to compensate for Thor speaker enclosure acoustics. [src: docs/android/community-tools.md] |
| **LSFG-VK** | Graphics / Mod | **Lossless Scaling Frame Generation Vulkan Layer**. A Linux Vulkan layer that re-implements frame generation by reading `Lossless.dll` from the official Steam purchase and injecting interpolated frames. [src: docs/android/community-tools.md] |
| **OSTree** | Linux / OS | An architecture for content-addressed system versioning. Treats root filesystem trees similar to Git commits, allowing atomic upgrades and clean rollbacks. [src: docs/armada/install-internal.md] |
| **Proton** | Compatibility | Valve's compatibility tool combining Wine, DXVK, and VKD3D to execute Windows games on Linux. Armada uses CachyOS Proton 11 builds optimized for ARM64 with FEX-Emu. [src: docs/armada/overview.md] |
| **QCS8550 / SM8550**| SoC | Qualcomm Snapdragon 8 Gen 2 processor. QCS8550 is the embedded/industrial marketing designation used in upstream devicetree bindings; SM8550 is the mobile consumer designation. [src: docs/boot-kernel/devicetree-thor.md] |
| **RSInput** | Kernel / Input | In-kernel Linux module (`CONFIG_JOYSTICK_RSINPUT=m`) communicating with the AYN microcontroller to report analog stick positions and button presses. [src: docs/hardware/device-observed.md] |
| **s2idle** | Power / Kernel | **Suspend-to-Idle**. A software-driven sleep state where devices transition into low-power states while remaining under kernel execution, rather than powering off the SoC to RAM (`suspend-to-RAM`). [src: docs/hardware/device-observed.md] |
| **SDR104** | Storage / Bus | SD card bus speed mode specifying 1.8V signaling, up to 208 MHz clock frequencies, and up to 104 MB/s theoretical transfer rate. On stock Armada 20260926, the Thor negotiates 202 MHz SDR104. [src: docs/hardware/device-observed.md] |
| **UFS** | Storage | **Universal Flash Storage**. High-speed internal flash storage. Early AYN Thor batches (including early Max 1TB models) feature UFS 4.0; later production batches transitioned to UFS 3.1. [src: docs/hardware/specs.md] |
| **Wayfinder** | Community Mod | **Thor-Wayfinder**. A specialized Android utility by `Thor-Wayfinder` providing window swapping, quick tiles, and control remapping on dual-screen Thor devices without root. [src: docs/android/community-tools.md] |

---

## Sources
- [S1] `refs/upstream/armada@574da80` (device configs, devicetree bindings, service units)
- [S2] `refs/upstream/armadaos.dev@26dcfc3` (Armada OS documentation)
- [S3] `docs/hardware/specs.md` and `docs/hardware/device-observed.md`
- [S4] `docs/android/community-tools.md` and `docs/boot-kernel/boot-chain.md`
