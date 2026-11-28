#!/usr/bin/env bash

set -e

PROJECT_NAME="ytrvx-module"
PROJECT_REPO="https://github.com/nauraafii/ytrvx-module"
DOWNLOAD_DIR="/sdcard/Download/${PROJECT_NAME}"

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
ask() {
	local y
	for ((n = 0; n < 3; n++)); do
		pr "$1 [y/n]"
		if read -r y; then
			if [ "$y" = y ]; then
				return 0
			elif [ "$y" = n ]; then
				return 1
			fi
		fi
		pr "Asking again..."
	done
	return 1
}

pr "Ask for storage permission"
until
	yes | termux-setup-storage >/dev/null 2>&1
	ls /sdcard >/dev/null 2>&1
do sleep 1; done
if [ ! -f ~/.ytrvx_"$(date '+%Y%m')" ]; then
	pr "Setting up environment..."
	yes "" | pkg update -y && pkg upgrade -y && pkg install -y git curl jq openjdk-21 zip
	: >~/.ytrvx_"$(date '+%Y%m')"
fi
mkdir -p "$DOWNLOAD_DIR"

if [ -d "$PROJECT_NAME" ] || [ -f config.toml ]; then
	if [ -d "$PROJECT_NAME" ]; then cd "$PROJECT_NAME"; fi
	pr "Checking for ${PROJECT_NAME} updates"
	git fetch
	if git status | grep -q 'is behind\|fatal'; then
		pr "${PROJECT_NAME} is not synced with upstream."
		pr "Cloning ${PROJECT_NAME}. config.toml will be preserved."
		REPO_DIR=$(basename "$PWD")
		cd ..
		cp -f "$REPO_DIR/config.toml" .
		rm -rf "$REPO_DIR"
		git clone "$PROJECT_REPO" --recurse --depth 1 "$PROJECT_NAME"
		mv -f config.toml "$PROJECT_NAME/config.toml"
		cd "$PROJECT_NAME"
	fi
else
	pr "Cloning ${PROJECT_NAME}."
	git clone "$PROJECT_REPO" --recurse --depth 1 "$PROJECT_NAME"
	cd "$PROJECT_NAME"
	sed -i '/^enabled.*/d; /^\[.*\]/a enabled = false' config.toml
	grep -q "$PROJECT_NAME" ~/.gitconfig 2>/dev/null ||
		git config --global --add safe.directory "$HOME/$PROJECT_NAME"
fi

[ -f "$DOWNLOAD_DIR/config.toml" ] ||
	cp config.toml "$DOWNLOAD_DIR/config.toml"

printf "\n"
until
	if ask "Open 'config.toml' to configure builds?\nAll are disabled by default, you will need to enable at first time building"; then
		am start -a android.intent.action.VIEW -d "file://${DOWNLOAD_DIR}/config.toml" -t text/plain
	fi
	ask "Setup is done. Do you want to start building?"
do :; done
cp -f "$DOWNLOAD_DIR/config.toml" config.toml

./build.sh

cd build
PWD=$(pwd)
for op in *; do
	[ "$op" = "*" ] && {
		pr "glob fail"
		exit 1
	}
	mv -f "${PWD}/${op}" "$DOWNLOAD_DIR/${op}"
done

pr "Outputs are available in ${DOWNLOAD_DIR}"
am start -a android.intent.action.VIEW -d "file://${DOWNLOAD_DIR}" -t resource/folder
sleep 2
am start -a android.intent.action.VIEW -d "file://${DOWNLOAD_DIR}" -t resource/folder
