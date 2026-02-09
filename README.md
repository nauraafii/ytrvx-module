# YTRVX Module (ReVanced Extended Builder)

[![Build Status](https://github.com/nauraafii/ytrvx-module/actions/workflows/build.yml/badge.svg)](https://github.com/nauraafii/ytrvx-module/actions)
[![Latest Release](https://img.shields.io/github/v/release/nauraafii/ytrvx-module?label=Latest%20Release&color=blue)](https://github.com/nauraafii/ytrvx-module/releases/latest)

---

## ⚡ Features

- **Powered by ReVanced Extended:** Currently uses **Anddea** patches for the latest features and stability.
- **Optimized for Size:** Modules and APKs are compressed for efficiency.
- **Magisk / KernelSU Support:**
    - Handles installation of the correct stock app version automatically.
    - Does **not** break SafetyNet/Play Integrity or trigger root detections.
    - Recompiles invalidated odex for faster app launch.
    - Receives updates directly via Magisk/KSU Manager.

## 📥 Installation (Root / Magisk)

1. Download the module from the [**Latest Release**](https://github.com/nauraafii/ytrvx-module/releases).
2. Flash the ZIP file in Magisk or KernelSU.
3. Reboot your device.

**⚠️ Important:**
It is highly recommended to use [**zygisk-detach**](https://github.com/j-hc/zygisk-detach) to detach YouTube from the Play Store. This prevents auto-updates from breaking the patch.

## 📱 Non-Root Users
If you are installing the APKs directly (without Root Access), you **must** install GmsCore (MicroG) to enable Google Login.

- **Recommended:** [ReVanced GmsCore](https://github.com/ReVanced/GmsCore/releases)
- **Alternative:** [MicroG-RE](https://github.com/MorpheApp/MicroG-RE/releases)

## 🔧 Troubleshooting

If you encounter issues with the classic mount method, such as:
- **"Reflash needed"** error after reboots.
- **"Suspicious mount detected"** warnings from banking/root detector apps.

**Solution:**
Simply reinstall the module via Magisk/KSU to refresh the mount scripts and base APK.

## CREDITS

- **Base Module:** [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module)
- **Patches:** [anddea](https://github.com/anddea/revanced-patches)
- **CLI & Integrations:** [inotia00](https://github.com/inotia00)