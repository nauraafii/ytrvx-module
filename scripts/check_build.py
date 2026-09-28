"""Validate release configuration and require every configured APK/module."""

import argparse
import re
import tomllib
import zipfile
from pathlib import Path


def expected_outputs(config):
    if config.get("parallel-jobs", 1) != 1:
        raise ValueError("parallel-jobs must be 1 for Morphe")
    outputs = []
    for name, app in config.items():
        if not isinstance(app, dict):
            continue
        enabled = app.get("enabled", True)
        if not isinstance(enabled, bool):
            raise ValueError(f"{name}: enabled must be a boolean")
        if not enabled:
            continue
        version = app.get("version", "auto")
        if not isinstance(version, str) or not re.fullmatch(r"[0-9]+(?:\.[0-9]+)+|auto|latest|beta", version):
            raise ValueError(f"{name}: invalid version")
        if version == "auto" and any(app.get(key) for key in
                                     ("included-patches", "excluded-patches", "exclusive-patches")):
            raise ValueError(f"{name}: custom patches require an explicit version")
        if not any(app.get(f"{source}-dlurl") for source in ("archive", "apkmirror", "uptodown")):
            raise ValueError(f"{name}: no APK source configured")
        mode, arch = app.get("build-mode", "apk"), app.get("arch", "all")
        if mode not in ("apk", "module", "both") or arch not in ("all", "arm64-v8a", "arm-v7a", "both"):
            raise ValueError(f"{name}: invalid build-mode or arch")
        app_name = app.get("app-name", name)
        brand = app.get("rv-brand", config.get("rv-brand", "YTRVX"))
        for value in (app_name, brand):
            if not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9 _-]+", value):
                raise ValueError(f"{name}: use letters, numbers, spaces, '_' or '-' in output names")
        prefix = f"{app_name.lower()}-{brand.lower()}".replace(" ", "-")
        version = "*" if version in ("auto", "latest", "beta") else version
        for abi in ("arm64-v8a", "arm-v7a") if arch == "both" else (arch,):
            if mode in ("apk", "both"):
                outputs.append(f"{prefix}-v{version}-{abi}.apk")
            if mode in ("module", "both"):
                outputs.append(f"{prefix}-magisk-v{version}-{abi}.zip")
    if not outputs or len(outputs) != len(set(outputs)):
        raise ValueError("Enable at least one target and avoid duplicate output names")
    return outputs


def verify_outputs(patterns, directory):
    expected = set()
    for pattern in patterns:
        matches = list(directory.glob(pattern))
        if len(matches) != 1 or not zipfile.is_zipfile(matches[0]):
            raise ValueError(f"Missing, ambiguous or invalid APK/ZIP: {pattern}")
        expected.add(matches[0].name)
    actual = {path.name for path in directory.iterdir() if path.is_file()}
    if actual != expected:
        raise ValueError(f"Unexpected release files: {sorted(actual - expected)}; use a clean build directory")
    return sorted(expected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--outputs", action="store_true")
    args = parser.parse_args()
    try:
        with Path("config.toml").open("rb") as stream:
            expected = expected_outputs(tomllib.load(stream))
        names = verify_outputs(expected, Path("build")) if args.outputs else expected
    except (OSError, ValueError) as error:
        parser.exit(1, f"Build check failed: {error}\n")
    print(f"Validated {len(names)} expected outputs:")
    print("\n".join(names))


if __name__ == "__main__":
    main()
