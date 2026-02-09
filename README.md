# YT - MORPHE

[![Build Status](https://github.com/nauraafii/yt-morphe/actions/workflows/build.yml/badge.svg)](https://github.com/nauraafii/yt-morphe/actions)
[![Latest Release](https://img.shields.io/github/v/release/nauraafii/yt-morphe?label=Latest%20Release&color=blue)](https://github.com/nauraafii/yt-morphe/releases/latest)

---

## ⚡ Features

- **Powered by MorpheApp:** Always updated with the latest patches and optimizations.
- **Optimized for Size:** Modules and APKs are compressed for efficiency.
- **Magisk / KernelSU Support:**
    - Handles installation of the correct stock app version automatically.
    - Does **not** break SafetyNet/Play Integrity or trigger root detections.
    - Recompiles invalidated odex for faster app launch.
    - Receives updates directly via Magisk/KSU Manager.

## 📥 Download & Installation

1. Download the module from the [**Latest Release**](https://github.com/nauraafii/ytrvx/releases).
2. Flash the ZIP file in Magisk or KernelSU.
3. Reboot your device.

**⚠️ Important:**
It is highly recommended to use [**zygisk-detach**](https://github.com/j-hc/zygisk-detach) to detach YouTube from the Play Store. This prevents auto-updates from breaking the patch.

## 🔧 Troubleshooting

If you encounter issues with the classic mount method, such as:
- **"Reflash needed"** error after reboots.
- **"Suspicious mount detected"** warnings from banking/root detector apps.

**Solution:**
Simply reinstall the module via Magisk/KSU to refresh the mount scripts and base APK.

## CREDITS

- **Base Module:** [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)
- **Patches:** [MorpheApp](https://github.com/MorpheApp)