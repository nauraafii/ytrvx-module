# YTRVX Maintenance

Reviewed on October 31, 2026. YTRVX remains a personal fork. The builder comes from j-hc, and the patches come from Morphe. Changes focus on build reliability and clear release results.

## Evidence and decisions

| Finding | Evidence | Decision |
| --- | --- | --- |
| Build 11 did not obtain YouTube 21.13.164 but still published Music. | [Run 36422651695 logs](https://github.com/nauraafii/ytrvx-module/actions/runs/36422651695): the Archive source failed, APKMirror returned 403, and Uptodown returned 404. | A failed target makes the workflow fail; publication requires every configured output. |
| A fixed APK version can disappear from mirrors. | The Archive URL for 21.13.164 returned 404; [Archive metadata](https://archive.org/metadata/jhc-apks) listed 21.16.256 when checked. | YouTube was updated to 21.16.256 at the time. A pinned version does not guarantee that the APK will remain available. The current version is defined in `config.toml`. |
| Stable and experimental app support differ. | [Morphe Patches v1.44.0](https://github.com/MorpheApp/morphe-patches/releases/tag/v1.44.0) added support for 21.16.256, while 21.38.123 was marked experimental. | Choose a version that is not marked experimental for release builds, and test it on a device. |
| The upstream builder restricts parallel builds because of CLI issues. | [Upstream `build.sh`](https://github.com/j-hc/revanced-magisk-module/blob/main/build.sh), checked on the review date above. | Run targets sequentially and keep `parallel-jobs = 1`. |
| Failed temporary downloads can prevent fallback sources from running. | The previous `_req` waited while a temporary file existed, and the failure path did not remove that file. | Remove temporary files on failure. In the sequential builder, a leftover file from an interrupted download can then be retried. |
| Output checks are lightweight enough to run without the patcher. | Python provides `tomllib`, `pathlib`, `zipfile`, and `unittest` in its standard library. | Use the standard library and avoid extra packages. |
| Moving `latest` refs can change the patcher and bundle between runs. | [Run 41156457109](https://github.com/nauraafii/ytrvx-module/actions/runs/41156457109) succeeded with Desktop 1.20.0, patches 2.0.0, and YouTube 21.30.216. | Pin a tested Desktop/Patches pair, review new stable releases manually, and keep GitHub Actions SHA updates in reviewed Dependabot PRs. |
| The `ubuntu-latest` runner label is migrating to Ubuntu 26.04. | The successful build on October 31 used Ubuntu 24.04.5. | Pin release and check workflows to Ubuntu 24.04 until the vendored tools are validated on Ubuntu 26.04. |

## Options considered

- **Change only the APK version:** fixes the missing input at that time but does not prevent a partial release later.
- **Use `auto` for every app:** reduces manual updates, but selecting by patch count does not guarantee APK availability or distinguish experimental support.
- **Add more mirrors:** helps only when a source is trustworthy and maintained. Additional scraping creates more failure paths.
- **Pin versions and validate the full release:** chosen for this change. This requires periodic version reviews, and one failed target blocks the entire release.

## Update workflow

1. Read the release notes for [Morphe Patches](https://github.com/MorpheApp/morphe-patches/releases) and [Morphe Desktop](https://github.com/MorpheApp/morphe-desktop/releases). Distinguish stable from experimental versions.
2. Confirm that the matching APK is available. An HTTP 200 response only confirms that the endpoint responded; still check the APK signature and patching result.
3. Update the pinned Morphe Desktop and Patches tags together, then run `Check builder`. Review the app version against Morphe support and confirm the matching APK is still available.
4. Run Build Modules manually from the reviewed commit. The current build expects four Music outputs and two YouTube outputs.
5. Test installation or update, startup, sign-in, and playback on a device before describing a release as tested. Test non-root APKs and root modules separately.

## Future priorities

These items are not implemented because they need further validation:

- **Direct APK input with checksum and signature verification:** useful if mirrors often remove older versions. The [upstream `utils.sh`](https://github.com/j-hc/revanced-magisk-module/blob/main/utils.sh) now includes a `direct` source. Do not download an arbitrary URL without checking the APK identity.
- **Reproducible input records:** record the patcher version, bundle version, source APK SHA-256, and commit in a release manifest. First verify the CLI output format and APK identity checks.
- **Update proposals through pull requests:** more controlled than changing `latest` automatically. This requires a stable-version policy and reliable compatibility checks.

## Validation limitations

Offline tests check release policy and download-failure behavior. They do not run Morphe or prove that an APK works on Android. `zipfile.is_zipfile` checks the basic archive format; it does not verify the signature, the integrity of every entry, or app behavior. Run the build workflow for end-to-end validation.

Workflow references: [GitHub job summaries](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#adding-a-job-summary), [workflow triggers](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow), and [Morphe Desktop prerequisites](https://github.com/MorpheApp/morphe-desktop#prerequisites).
