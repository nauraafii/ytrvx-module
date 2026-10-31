# YTRVX Configuration

[`config.toml`](config.toml) defines the YTRVX build: source applications, patch bundles, versions, ABIs, and output types. The builder reads global values first, then reads each app table. An app-specific value overrides the matching global value.

See [BUILDING.md](BUILDING.md) for build environments and signing. This document covers configuration only.

## Safe change workflow

1. Create a branch and copy `config.toml` before editing it.
2. Change one small group of values, such as only `version` or `build-mode`.
3. For custom patch selections, set an explicit app version and check the [versions supported upstream](https://github.com/MorpheApp/morphe-patches#-patches-list).
4. Run a build, review `build.md` and the workflow logs, then test the assets on the relevant device.
5. Use the configuration for a release after these checks pass.

## Global values

Place these values at the top of `config.toml` to set defaults for all app tables.

| Option | Value or behavior | When to change it |
| --- | --- | --- |
| `enable-magisk-update` | `true` or `false`. GitHub builds generate the module update URL from this repository. Local builds disable it. | Set to `false` if your fork should not check for module updates. |
| `parallel-jobs` | Only `1` is currently supported. | Morphe builds run sequentially under the upstream builder's restriction; other values are rejected. |
| `module-author` | Name in the module metadata. | Set this to brand your fork. |
| `rv-brand` | Brand used in output names and metadata. | Use a brand distinct from upstream. |
| `patches-source` / `patches-version` | Repository and tag or ref for the Morphe `.mpp` bundle. | Keep a reviewed release tag pinned; update it with a compatible Desktop tag. |
| `cli-source` / `cli-version` | Repository and tag or ref for the Morphe Desktop JAR. | Pin the tested tag and review compatibility with the patch bundle before changing either value. |
| `dpi` | DPI values tried when downloading from supported sources. | Change this only when the APK source offers different DPI variants. |
| `compression-level` | ZIP compression level from `0` to `9`. | Use a lower value for faster builds or a higher value for smaller ZIP files. |
| `remove-rv-integrations-checks` | Must be `false` for the Morphe `.mpp` bundles used by this fork. | Do not enable it unless the builder code and bundle format change and are tested. |

## Per-app values

Each table, such as `[YouTube-Extended]` or `[Music-Extended]`, defines one build target.

| Option | Value or behavior | Important notes |
| --- | --- | --- |
| `enabled` | `true` or `false`. | The builder builds only enabled targets. |
| `app-name` | Name used in output files. | It does not need to match the table name. |
| `build-mode` | `apk`, `module`, or `both`. | `apk` creates a non-root APK; `module` creates a ZIP for root; `both` creates both. |
| `version` | An explicit version, `auto`, `latest`, or `beta`. | See [Version selection](#version-selection). |
| `arch` | `all`, `arm64-v8a`, `arm-v7a`, or `both`. | `both` runs separate builds for the two ABIs; `all` requests a multi-ABI build. |
| `uptodown-dlurl`, `apkmirror-dlurl`, `archive-dlurl` | App source URLs. | Set at least one. The builder tries available sources if one fails. |
| `included-patches` / `excluded-patches` | Lists of patch names to force on or off. | Quote patch names and use an explicit app version. |
| `exclusive-patches` | When `true`, uses only the selected patches. | This is high risk because required default patches may be omitted. |
| `include-stock` | Includes the stock APK in the module ZIP; defaults to `true`. | This makes module installation more reliable but increases ZIP size. |
| `module-author` | Overrides the author for this target. | Other targets are unchanged. |
| `riplib` | Set to `false` to disable ABI library removal. | The builder uses this optimization only when the CLI supports `rip-lib`. |
| `patcher-args` | Additional arguments passed to the Morphe CLI. | Use only after checking the upstream CLI documentation. |
| `module-prop-name` | Magisk module ID. | Do not change it after installation if you want updates to use the same module path. |

## Version selection

| Value | Builder behavior | Recommendation |
| --- | --- | --- |
| Explicit version, such as `"21.16.256"` | Forces the patcher to use that version. | Review patch support and APK availability before building. |
| `auto` | Selects the version with the highest patch count according to the CLI. | This does not guarantee the APK is available or that the version is non-experimental. |
| `latest` | Selects the highest stable version available from the APK source and forces patching. | Use for experiments that can tolerate failure if the version is not compatible. |
| `beta` | Selects the highest beta version available from the APK source and forces patching. | Highest risk; avoid for routine releases. |

The builder rejects `auto` when `included-patches`, `excluded-patches`, or `exclusive-patches` is set. Choose an explicit app version listed as supported upstream so patch changes remain reproducible and reviewable.

## Minimal example

This example builds only a non-root YouTube APK, using the currently tested Morphe tags and an explicit app version:

```toml
patches-source = "MorpheApp/morphe-patches"
patches-version = "v2.0.0"
cli-source = "MorpheApp/morphe-desktop"
cli-version = "v1.20.0"

[YouTube-Extended]
enabled = true
app-name = "YouTube"
build-mode = "apk"
version = "21.30.216"
arch = "all"
apkmirror-dlurl = "https://www.apkmirror.com/apk/google-inc/youtube"
archive-dlurl = "https://archive.org/download/jhc-apks/apks/com.google.android.youtube"
```

This example shows the configuration format only. Before using a new app version or tag, confirm that [Morphe Patches](https://github.com/MorpheApp/morphe-patches) supports that combination.

The active configuration pins Morphe Patches `v2.0.0` and Morphe Desktop `v1.20.0` for both apps. Review upstream releases and update the pair together; the manual CI workflow can detect a changed patch bundle and start a build. For a CLI-only or app-version change, run Build Modules directly. GitHub Actions references are pinned to commit SHAs, and Dependabot proposes weekly updates for those actions. APK sources remain external and may stop serving a pinned version.

## Custom patches

The CLI receives patch names, so spelling must exactly match the upstream patch list. In TOML, double single quotes when a patch name contains a single quote. For example: `Hide ''Get Music Premium''`.

Start with a small change: select one patch, pin the app and bundle versions, build, and review the output. Do not manually include or exclude GmsCore/microG patches; the builder handles them differently for non-root APKs and root modules.

## References

- [Morphe Patches — patch list and supported versions](https://github.com/MorpheApp/morphe-patches#-patches-list)
- [Morphe Desktop — CLI, JAR, and documentation](https://github.com/MorpheApp/morphe-desktop)
- [Active configuration in this fork](config.toml)
