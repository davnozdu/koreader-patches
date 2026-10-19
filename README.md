# KOReader user patches

Small [user patches](https://koreader.rocks/user_guide/#L2-userpatches) for KOReader. No need to rebuild KOReader.

## Patches

| File | What it does |
|------|--------------|
| `2-network-check-fallback.lua` | KOReader checks for Internet access by resolving only `dns.msftncsi.com`. If your DNS blocks that domain (Pi-hole, AdGuard, some routers and ISPs), KOReader keeps asking you to turn on Wi-Fi even though you're connected. This patch keeps the original check and falls back to a few other hostnames. |
| `2-android-skip-background-repaint.lua` | Android only. While KOReader is minimized, widgets that update on a timer (such as the [Audiobook Read-Along](https://github.com/davnozdu/audiobook.koplugin) highlight) keep re-rendering the page for a window that isn't there (`cannot blit: no window` in logcat). This patch skips those repaints and does one full repaint when you return to the app. |

## Install

Copy the `.lua` files into the `patches` folder of your KOReader data directory, then restart KOReader:

| Platform | Folder |
|----------|--------|
| Android | `/sdcard/koreader/patches/` |
| Kobo | `.adds/koreader/patches/` |
| Kindle | `koreader/patches/` |

You can switch individual patches on or off in **Tools → More tools → Patch management**.

Note: user patches are disabled in the F-Droid build of KOReader.
