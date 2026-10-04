# Dual Screen on Android
> Scope: How Android natively handles the dual displays · Researched: 2026-10-04 · Confidence: high

The AYN Thor uses Android's native multi-display support to manage its clamshell design (6-inch primary AMOLED, 3.92-inch secondary touch display). 

## Display Mapping
Android natively treats the top screen as Display 0 (the primary display) and the bottom screen as Display 1 (a secondary presentation display).
Unlike standard slab devices, the Thor firmware is customized to allow rendering distinct activities or floating views to Display 1.

## Navigation and Input
- Touch input is uniquely routed to each display by the kernel (t5426 for top, t5452 for bottom). Android's input manager seamlessly handles these as separate coordinate spaces.
- The default AYN Launcher provides tools (often mapped to the physical AYN button) to swap applications between the top and bottom screens, or to summon a specialized bottom-screen widget panel.

## App Compatibility
Apps that do not explicitly target Display 1 using Android's Presentation API will simply open on the primary screen. The community has developed tools like DualScreen-Launcher to force apps to launch on the bottom screen for multi-tasking (e.g., Discord or YouTube on the bottom while gaming on top).
