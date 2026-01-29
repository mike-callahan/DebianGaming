#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

PKG_NAME="gamemode"
REPO_URL="https://github.com/FeralInteractive/gamemode.git"
SRC_DIR="$BUILD_ROOT/$PKG_NAME"
VERSION="${VERSION:-}"

ref=$(clone_or_update "$REPO_URL" "$SRC_DIR" "$VERSION")
generate_changelog "$PKG_NAME" "$SRC_DIR" "$ref"
copy_debian_and_build "$PKG_NAME" "$SRC_DIR"
