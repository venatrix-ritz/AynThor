# Emulation on Armada OS
> Scope: x86 emulation and Android app support · Researched: 2026-10-04 · Confidence: high

Since the Thor is an ARM64 device, playing standard PC games requires x86/x64 emulation. Armada handles this transparently to the user.

## FEX-Emu
Armada uses `FEX-Emu` to translate x86 and x86_64 instructions to ARM64. 
- FEX is baked into the OS container image.
- When Steam launches a Windows game through Proton, or a native x86 Linux game, FEX intercepts the execution and translates the binaries on the fly.
- FEX leverages a lightweight RootFS (packaged during the `Packages` workflow) containing the minimal x86 Linux libraries required to run Steam and Proton.

## Android App Support (Waydroid / GuestOS)
To play Android games on Armada without rebooting into the native Android firmware:
- Armada runs a lightweight Android container (referred to as `guestos` or Waydroid) using `loop` devices.
- `loop0` mounts the Android rootfs, and `loop1` mounts a specific Mesa driver build to provide hardware acceleration.
- Android apps are integrated into the Steam UI, allowing users to launch them side-by-side with PC games.

## Performance
- Emulation overhead for x86 games means a portion of the SM8550's CPU power is spent on translation. However, the sheer power of the Snapdragon 8 Gen 2 makes many lightweight and older PC games highly playable.
- Native Android games running via `guestos` run with almost no overhead, as they execute natively on the ARM64 architecture.
