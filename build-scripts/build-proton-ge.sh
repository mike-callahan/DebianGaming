#!/usr/bin/env bash
set -euo pipefail

BUILD_ROOT="${BUILD_ROOT:-/build}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-/artifacts}"
WORKSPACE="${WORKSPACE:-/workspace}"
PKG_NAME="proton-ge-custom"
INSTALL_DIR="usr/share/steam/compatibilitytools.d"

# Fetch latest release info from GitHub API
AUTH_HEADER=""
if [[ -n "${GH_TOKEN:-}" ]]; then
    AUTH_HEADER="-H Authorization: Bearer $GH_TOKEN"
fi
LATEST=$(curl -s $AUTH_HEADER https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest)
TAG=$(echo "$LATEST" | jq -r '.tag_name // empty')
if [[ -z "$TAG" ]]; then
    echo "Failed to fetch latest release from GitHub API"
    echo "Response: $LATEST"
    exit 1
fi
VERSION=$(echo "$TAG" | sed 's/^GE-Proton//' | tr '-' '.')

if [[ -n "${VERSION_OVERRIDE:-}" ]]; then
    TAG="GE-Proton${VERSION_OVERRIDE//./-}"
    VERSION="$VERSION_OVERRIDE"
fi

TARBALL_URL=$(echo "$LATEST" | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url')

echo "Building Proton-GE $TAG (version $VERSION)"

mkdir -p "$BUILD_ROOT/$PKG_NAME"
cd "$BUILD_ROOT/$PKG_NAME"

# Download and extract
echo "Downloading $TARBALL_URL..."
curl -L -o proton-ge.tar.gz "$TARBALL_URL"
mkdir -p "pkg/$INSTALL_DIR"
tar xzf proton-ge.tar.gz -C "pkg/$INSTALL_DIR/"

# Set up debian packaging
mkdir -p debian
if [[ -d "$WORKSPACE/debian" ]]; then
    cp -r "$WORKSPACE/debian/"* debian/
fi

# Generate changelog
DATE=$(date -R)
cat > debian/changelog <<INNEREOF
${PKG_NAME} (${VERSION}-1~debiangaming) trixie; urgency=medium

  * Repackaged from upstream release ${TAG}.

 -- DebianGaming <noreply@github.com>  ${DATE}
INNEREOF

# Build the package
dpkg-buildpackage -us -uc -b --no-check-builddeps

mkdir -p "$ARTIFACTS_DIR"
cp "$BUILD_ROOT"/*.deb "$ARTIFACTS_DIR/" 2>/dev/null || true
cp "$BUILD_ROOT/$PKG_NAME"/../*.deb "$ARTIFACTS_DIR/" 2>/dev/null || true

echo "Build complete:"
ls -lh "$ARTIFACTS_DIR/"*.deb 2>/dev/null
