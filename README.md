# DebianGaming

Latest builds of popular Linux gaming tools, packaged as `.deb` files for **Debian 13 (Trixie)**.

Many Linux gaming projects only officially support Arch or Nix. This repo automatically tracks upstream releases and builds Debian packages so you can install them with `apt`.

## Available Packages

| Package | Description | Upstream |
|---------|-------------|----------|
| **gamescope** | SteamOS session compositing window manager | [ValveSoftware/gamescope](https://github.com/ValveSoftware/gamescope) |
| **mangohud** | Vulkan/OpenGL overlay for FPS, temps, CPU/GPU load | [flightlessmango/MangoHud](https://github.com/flightlessmango/MangoHud) |
| **gamemode** | Game performance optimization daemon | [FeralInteractive/gamemode](https://github.com/FeralInteractive/gamemode) |
| **lutris** | Open Gaming Platform | [lutris/lutris](https://github.com/lutris/lutris) |
| **proton-ge-custom** | GloriousEggroll's custom Proton for Steam | [GloriousEggroll/proton-ge-custom](https://github.com/GloriousEggroll/proton-ge-custom) |
| **sunshine** | Self-hosted game stream host for Moonlight | [LizardByte/Sunshine](https://github.com/LizardByte/Sunshine) |

## Install via APT (Recommended)

Add the repository and install packages:

```bash
# Add the GPG key
curl -fsSL https://mike-callahan.github.io/DebianGaming/debiangaming.gpg.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/debiangaming.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/debiangaming.gpg] https://mike-callahan.github.io/DebianGaming trixie main" \
  | sudo tee /etc/apt/sources.list.d/debiangaming.list

# Update and install
sudo apt update
sudo apt install gamescope mangohud gamemode lutris sunshine
```

## Manual Download

Download `.deb` files directly from [GitHub Releases](https://github.com/mike-callahan/DebianGaming/releases).

```bash
sudo dpkg -i <package>.deb
sudo apt-get install -f  # Install any missing dependencies
```

## How It Works

- A Docker container (`base.Dockerfile`) provides the build environment with all dependencies
- Each package has a build script in `build-scripts/` and Debian packaging files in `debian/`
- `check-upstream.yml` runs every 6 hours, detects new upstream releases, and triggers builds automatically
- Built `.deb` files are published to GitHub Releases and the APT repository on GitHub Pages

## Build Locally

Requirements: Docker

```bash
# Build the base Docker image
docker build -f base.Dockerfile -t devgame-builder .

# Build a specific package
make gamescope

# Build all packages
make all

# Built packages appear in local-artifacts/
```

## Wine

Wine is not packaged here due to the complexity of cross-compiling 32/64-bit builds. Use the official WineHQ repository instead:

```bash
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources
sudo apt update
sudo apt install winehq-staging
```

## Setup Required (for maintainers)

After forking or cloning this repo:

1. **GPG Key**: Generate a GPG key pair and add the private key as the `APT_GPG_PRIVATE_KEY` repository secret
2. **GitHub Pages**: Enable GitHub Pages in repository settings, set to deploy from GitHub Actions
3. **Container Registry**: Trigger the `Build & Push Docker Base` workflow to push the base image to GHCR

## License

MIT
