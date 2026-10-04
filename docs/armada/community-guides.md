# Community Guides (Armada OS)
> Scope: Community tools, modifications, and guides for Armada OS · Researched: 2026-10-04 · Confidence: high

The Armada OS community has built several tools to enhance the dual-screen and handheld experience. Due to Armada's immutable nature, most tools run in userspace or integrate via Decky plugins.

## Dual-Screen Launchers
Because standard SteamOS UI only drives the primary screen (DSI-1), the bottom screen requires external compositors or launchers.
- **arry-launcher**: A lightweight systemd user service that spawns a secondary Wayland compositor on the bottom screen using a DRM lease (--drm-lease-client). It displays battery stats, time, and allows basic touch interactions. It intercepts the physical AYN button using an InputPlumber override to toggle its visibility.
- **CocoonFE**: An Android frontend (inssekt/CocoonFE) that is often run inside Waydroid (guestos) to provide a "Now Playing" or media-center interface on the secondary screen.

## Audio and DSP Fixes
- **JamesDSP Audio Fix**: A community script suite (udiofix-setup.sh, udiofix-jamesdsp-auto.service) exists to automatically configure JamesDSP with specific EQ presets to improve the sound profile of the internal Awinic AW88166 speakers on Armada.

## Installing Community Tools
To install system-level community tools on an immutable OS like Armada, users typically install them as:
1. **Systemd User Services**: Placed in ~/.config/systemd/user/ and managed without sudo.
2. **Decky Plugins**: Dropped into ~/homebrew/plugins/.
3. **Flatpaks**: Installed system-wide or per-user via latpak.
