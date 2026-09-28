#!/usr/bin/env bash
# Offline regression checks for the actual downloader functions.
set -euo pipefail
unset GITHUB_REPOSITORY
source utils.sh
TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT

# An interrupted file must not make a later fallback wait forever.
printf partial > "$TEMP_DIR/tmp.input.apk"
curl() { return 22; }
if _req https://example.org/input.apk "$TEMP_DIR/input.apk"; then
	echo 'Failed download reported success' >&2
	exit 1
fi
test ! -e "$TEMP_DIR/tmp.input.apk"
test ! -e "$TEMP_DIR/input.apk"

curl() {
	while (($#)); do
		if [ "$1" = -o ]; then printf apk > "$2"; return; fi
		shift
	done
	return 1
}
_req https://example.org/fallback.apk "$TEMP_DIR/input.apk"
test "$(cat "$TEMP_DIR/input.apk")" = apk

# Matching must use the argument, not a caller's version_f or regex dots.
__ARCHIVE_PKG_NAME__=com.google.android.youtube
__ARCHIVE_RESP__=$'com.google.android.youtube-21x16x256-all.apk\ncom.google.android.youtube-21.16.256-all.apk'
version_f=wrong
req() { test "$1" = 'https://example.org/com.google.android.youtube-21.16.256-all.apk'; }
dl_archive https://example.org 21.16.256 ignored all
if dl_archive https://example.org 21.13.164 ignored all; then
	echo 'Missing archive version reported success' >&2
	exit 1
fi

# Failed targets must never be reported as successful to build.sh.
declare -A app_args=(
	[build_mode]=both [version]=21.16.256 [app_name]=YouTube
	[table]=YouTube [dl_from]=archive [arch]=all
	[excluded_patches]='' [included_patches]='' [exclusive_patches]=false
	[archive_dlurl]=https://example.org [apkmirror_dlurl]='' [uptodown_dlurl]=''
	[dpi]=nodpi [rv_brand]=YTRVX [patcher_args]='' [riplib]=false
	[cli]=unused [ptjar]=unused
)
cli_jar=unused
patches_jar=unused
get_archive_resp() { return 0; }
get_archive_pkg_name() { echo com.google.android.youtube; }
java() { echo 'Name: Example patch'; }
dl_archive() { return 1; }
if build_rv "$(declare -p app_args)"; then
	echo 'Unavailable APK reported success' >&2
	exit 1
fi
printf fixture > "$TEMP_DIR/com.google.android.youtube-21.16.256-all.apk"
check_sig() { return 0; }
log() { :; }
patch_apk() { return 1; }
if build_rv "$(declare -p app_args)"; then
	echo 'Failed patch reported success' >&2
	exit 1
fi
echo 'Download and target failure regression checks passed'
