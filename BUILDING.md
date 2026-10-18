# YTRVX Build Guide

This guide is for fork owners who want to change the configuration or create their own release. See [README.md](README.md) to choose a release asset and [CONFIG.md](CONFIG.md) to understand each option.

## Choose a build path

| Path | Use it for | Effect |
| --- | --- | --- |
| GitHub Actions | Building a release for your fork | Uses repository secrets and creates or updates a GitHub Release. |
| Local Linux or Termux | Testing changes locally | Requires your own keystore and a Bash environment. Local builds do not enable the Magisk update URL. |
| `build-termux.sh` | Guided setup in Termux | Updates Termux packages and may replace an outdated local clone after saving `config.toml`. Review the script before running it. |

## Build a release with GitHub Actions

The [`Build Modules`](.github/workflows/build.yml) workflow sets up Java 21, runs `build.sh`, creates `SHA256SUMS.txt`, and uploads all assets to a GitHub Release.

Every enabled target must succeed. If a download, patch, or module build fails, the workflow stops before publication. Output checks reject missing files, files that are not APK or ZIP archives, and leftover files from an earlier build. These checks do not confirm that an app works on a device.

The scheduled workflow checks for patch bundle updates. When a bundle changes, it builds all enabled targets together so the release assets and update metadata stay consistent. The run page includes a validation summary; check the workflow result to confirm publication.

## Pre-build checks

The [`Check builder`](.github/workflows/check.yml) workflow checks configuration, Bash syntax, and regressions without a signing key or APK downloads. It runs on pull requests and pushes to `main`.

Configuration and output checks require Python 3.11 or later (available on the Ubuntu runner). On Windows, run these commands from the repository directory:

```powershell
python scripts/check_build.py
python -m unittest discover -s scripts -v
```

On Linux, run these additional checks:

```bash
for script in build.sh utils.sh build-termux.sh scripts/check_downloads.sh; do
  bash -n "$script" || exit 1
done
bash scripts/check_downloads.sh
# After the build, before generating checksums:
python3 scripts/check_build.py --outputs
```

For an `All APK sources failed` error, compare the version in `config.toml` with the versions supported by the patch bundle and available from the configured APK sources. Retrying a version that is no longer available will not fix the issue. See the [maintenance notes](docs/MAINTENANCE.md) for the supporting evidence and maintenance steps.

Before running the release workflow, configure these two repository secrets:

| Secret | Value | Used for |
| --- | --- | --- |
| `YTRVX_KEYSTORE_B64` | Your PKCS#12 keystore, encoded as Base64 | Signs APKs on the GitHub runner. |
| `YTRVX_KEYSTORE_PASSWORD` | The keystore password and `ytrvx` entry password | Opens the keystore during signing. |

Do not put secret values in `config.toml`, issues, logs, commits, or uploaded files. After configuring the secrets, run the workflow from `main` and review its logs and release assets.

## Local build

The builder is a Bash script. Use Linux, Termux, or a compatible Bash shell; PowerShell does not run `build.sh` directly.

The builder requires or uses:

- Java 21 or later;
- Bash, `curl`, `jq`, and `zip`;
- a Git checkout of this repository;
- your own PKCS#12 keystore with the alias `ytrvx`;
- the `YTRVX_KEYSTORE_PATH` and `YTRVX_KEYSTORE_PASSWORD` environment variables.

Morphe Desktop also lists Java 21 or later as a CLI prerequisite. See its [official documentation](https://github.com/MorpheApp/morphe-desktop#prerequisites) before changing the patcher or bundle version.

Example workflow on Linux or Termux:

```bash
git clone --recurse-submodules https://github.com/nauraafii/ytrvx-module.git
cd ytrvx-module

export YTRVX_KEYSTORE_PATH="$PWD/ytrvx-release.p12"
read -rs -p "Keystore password: " YTRVX_KEYSTORE_PASSWORD
export YTRVX_KEYSTORE_PASSWORD

./build.sh config.toml
```

The local build writes output to `build/`, which Git ignores. Store the keystore in a secure location outside the repository when possible. Do not use another maintainer's release keystore: Android updates require the same signing identity.

## Create your own keystore

The builder calls Morphe with the keystore alias `ytrvx`. Create a PKCS#12 keystore with that alias, store its password securely, and set `YTRVX_KEYSTORE_PATH` to the keystore file. See the [Java documentation](https://docs.oracle.com/en/java/javase/21/docs/specs/man/keytool.html) for `keytool` syntax and options.

A keystore is the release identity. If you lose or replace it, Android treats the new APK as having a different signature. Users usually need to uninstall the previous app before installing the new one.

## Termux helper

[`build-termux.sh`](build-termux.sh) installs `git`, `curl`, `jq`, `openjdk-21`, and `zip`, then runs `build.sh`. On first setup, it requests storage access and places `config.toml` and build output in `/sdcard/Download/ytrvx-module`.

The script is intended for personal use and can update Termux packages. Read it before running. Use [GitHub Actions](#build-a-release-with-github-actions) to build and publish a release for your fork.
