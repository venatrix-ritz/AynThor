# Gaming Mode & Desktop Mode (Armada OS)
> Scope: The Steam UI, Gamescope, and Desktop environments · Researched: 2026-10-04 · Confidence: high

Armada aims to replicate the Steam Deck experience as closely as possible using gamescope-session and the native Steam UI.

## Gaming Mode (Gamescope)
When Armada boots, the default 	arget is a customized gamescope-session systemd service.
- **Primary Screen (DSI-1)**: The top screen is captured by Gamescope using a DRM lease (--lease-connector DSI-1). The Steam client runs within this Gamescope instance, providing the console-like UI.
- **Secondary Screen**: The bottom screen is controlled by a secondary Gamescope instance running in --drm-lease-client mode (or a separate Wayland compositor depending on community tools like arry-launcher).
- **Plugins**: Decky Loader is fully supported and injected into the Steam UI. rmada-control provides the hardware toggles (TDP, RGB) directly in the Quick Access Menu (QAM).

## Desktop Mode
Desktop mode is accessible from the Steam power menu, exactly like SteamOS.
- **Compositor**: Uses KDE Plasma (KWin) on Wayland.
- **Root Filesystem**: Because the root filesystem is an immutable ootc image, users cannot use dnf to install traditional RPM packages persistently (they will be wiped on the next update).
- **Applications**: Users must rely on Flatpak for desktop applications (Discover store) or Distrobox/Toolbx for development environments.
- **Return to Gaming Mode**: A script/shortcut on the desktop terminates the KDE session and returns to gamescope-session.
