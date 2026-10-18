# YTRVX

YTRVX is my personal setup for building YouTube and YouTube Music with [Morphe Patches](https://github.com/MorpheApp/morphe-patches). It is forked from [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module). I adapt the configuration for personal use and maintain the documentation and build workflow. The patcher and module template still come from the upstream project.

## Build outputs

Build files are available on the [Releases](https://github.com/nauraafii/ytrvx-module/releases) page. Choose an `.apk` for a non-rooted device or a `.zip` for a Magisk/KernelSU module. Match the app name and architecture (`all`, `arm64-v8a`, or `arm-v7a`) to your device.

Non-root APKs require [GmsCore](https://github.com/ReVanced/GmsCore/releases) or [MicroG-RE](https://github.com/MorpheApp/MicroG-RE/releases) for sign-in. An APK signed with a different key cannot update an installed copy. Back up your data before uninstalling the existing app.

## Build manually

Edit [`config.toml`](config.toml), then run the [Build Modules](https://github.com/nauraafii/ytrvx-module/actions/workflows/build.yml) workflow from the `main` branch. Check the workflow log and release files when it finishes. This repository requires your own signing key; see the [build guide](BUILDING.md) for setup instructions.

See [CONFIG.md](CONFIG.md) for configuration options and [MAINTENANCE.md](docs/MAINTENANCE.md) for the rationale behind changes and maintenance notes.

This is a personal project and is not an official Google, Morphe, or j-hc application.
