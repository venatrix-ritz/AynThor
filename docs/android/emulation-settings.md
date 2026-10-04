# Emulation Settings for Android
> Scope: Recommended apps and setups for native Android emulation · Researched: 2026-10-04 · Confidence: high

When running the native Android firmware, the AYN Thor excels at dual-screen emulation (Nintendo DS, 3DS, and Wii U). Because standard Android emulators assume a single screen, specific forks and settings are required.

## 3DS Emulation
- **Emulator**: Azahar
- **Setup**: Azahar is the community "gold standard" for the Thor because it features a dedicated toggle for secondary display mapping. 
- **Settings**: In the graphics settings, enable the "Secondary Display" option to route the 3DS bottom screen output directly to the Thor's bottom screen.

## Nintendo DS Emulation
- **Emulator**: MelonDS (SapphireRhodonite Fork)
- **Setup**: This specific fork of MelonDS has been modified to treat the bottom screen as a separate hardware presentation layer, significantly reducing input lag and improving touch accuracy.
- **Settings**: Select "Dual Display Mode" in the video settings.

## Wii U Emulation
- **Emulator**: Cemu (SSimco Android Port)
- **Setup**: The Android port of Cemu allows moving the "GamePad" view to the secondary screen.
- **Settings**: Use the presentation API toggle to send the GamePad output to Display 1 while the main TV output stays on Display 0.

## Frontends
Many users replace the stock AYN Launcher with **CocoonFE** (or Daijishou), which is dual-screen aware and can display a "Now Playing" UI on the bottom screen while navigating the library on top.
