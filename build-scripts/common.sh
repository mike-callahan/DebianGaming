#!/usr/bin/env bash
set -euo pipefail

BUILD_ROOT="${BUILD_ROOT:-/build}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-/artifacts}"
WORKSPACE="${WORKSPACE:-/workspace}"

# Clone or update a git repo and checkout a specific ref
# Usage: clone_or_update <repo_url> <dest_dir> [ref]
# If ref is empty, checks out the latest tag
clone_or_update() {
    local repo_url="$1"
    local dest="$2"
    local ref="${3:-}"

    if [[ ! -d "$dest/.git" ]]; then
        git clone "$repo_url" "$dest" >&2
    else
        cd "$dest"
        git fetch origin --tags --prune >&2
    fi

    cd "$dest"

    if [[ -z "$ref" ]]; then
        ref=$(git tag --sort=-v:refname | head -n1 || echo "")
        if [[ -z "$ref" ]]; then
            ref="main"
        fi
    fi

    git checkout "$ref" >&2
    git submodule update --init --recursive >&2
    echo "$ref"
}

# Generate debian/changelog from package name and version
# Usage: generate_changelog <pkg_name> <src_dir> [version]
generate_changelog() {
    local pkg_name="$1"
    local src_dir="$2"
    local version="${3:-}"

    if [[ -z "$version" ]]; then
        # Try git describe first, then latest tag, then fallback
        version=$(cd "$src_dir" && git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -z "$version" ]]; then
            version=$(cd "$src_dir" && git tag --sort=-v:refname | head -n1 || echo "")
        fi
        if [[ -z "$version" ]]; then
            version="0.0.1"
        fi
    fi
    # Sanitize version for Debian (remove leading non-digits, replace problematic chars)
    version=$(echo "$version" | sed 's/^[^0-9]*//' | tr '-' '.')
    # Ensure version is not empty after sanitization
    if [[ -z "$version" ]]; then
        version="0.0.1"
    fi

    local date
    date=$(date -R)

    mkdir -p "$src_dir/debian"
    cat > "$src_dir/debian/changelog" <<EOF
${pkg_name} (${version}-1~debiangaming) trixie; urgency=medium

  * Auto-built from upstream release.

 -- DebianGaming <noreply@github.com>  ${date}
EOF
    echo "$version"
}

# Copy debian packaging dir and build the package
# Usage: copy_debian_and_build <pkg_name> <src_dir>
copy_debian_and_build() {
    local pkg_name="$1"
    local src_dir="$2"

    # Copy debian dir from workspace (mounted from repo)
    if [[ -d "$WORKSPACE/debian" ]]; then
        cp -r "$WORKSPACE/debian/"* "$src_dir/debian/"
    fi

    cd "$src_dir"
    dpkg-buildpackage -us -uc -b --no-check-builddeps

    mkdir -p "$ARTIFACTS_DIR"
    # debs are created in parent directory
    cp "$src_dir"/../*.deb "$ARTIFACTS_DIR/" 2>/dev/null || true
    cp "$BUILD_ROOT"/*.deb "$ARTIFACTS_DIR/" 2>/dev/null || true

    echo "Build complete. Packages:"
    ls -lh "$ARTIFACTS_DIR/"*.deb 2>/dev/null || echo "No .deb files found"
}
