FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/debian.sources && echo "deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware\n\
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware\n\
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware" \
> /etc/apt/sources.list && \
    apt-get update

# Core dev tools and Debian packaging
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build git curl wget unzip pkg-config \
    python3 python3-pip python3-setuptools python3-jinja2 \
    gnupg2 lsb-release locales sudo xz-utils zip tar jq \
    autoconf automake libtool ca-certificates \
    # Debian packaging tools
    devscripts debhelper dh-make fakeroot lintian dpkg-dev \
    # GUI/X11/Wayland
    x11-utils xauth x11-xserver-utils libx11-dev libxext-dev libxrandr-dev \
    libxinerama-dev libxcursor-dev libxcomposite-dev libxi-dev \
    libgl1-mesa-dev libglu1-mesa-dev libwayland-dev libxkbcommon-dev libdbus-1-dev \
    libdrm-dev libgbm-dev \
    # Graphics, Vulkan, Mesa
    mesa-utils mesa-common-dev libvulkan-dev vulkan-tools \
    # Game & media libs
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    libglew-dev libglfw3-dev libglm-dev \
    libopenal-dev libsndfile1-dev libfreetype6-dev \
    libjpeg-dev libpng-dev libtiff-dev zlib1g-dev \
    # PipeWire / audio build deps
    meson libasound2-dev libpulse-dev \
    libsystemd-dev libudev-dev libglib2.0-dev libspa-0.2-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    # Gamescope deps
    libinih-dev libdisplay-info-dev libliftoff-dev libseat-dev \
    libxcb-composite0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-res0-dev \
    libxdamage-dev libxfixes-dev libxres-dev libxtst-dev \
    libcap-dev libpipewire-0.3-dev glslang-tools \
    libxcb1-dev libxcb-xfixes0-dev libxmu-dev \
    wayland-protocols libwayland-bin \
    # MangoHud deps
    python3-mako libappstream-dev \
    # GameMode deps
    libinih-dev libdbus-1-dev systemd-dev \
    # Lutris deps
    python3-yaml python3-requests python3-pil python3-gi gettext \
    # Sunshine deps
    libcurl4-openssl-dev libavdevice-dev libboost-all-dev \
    libevdev-dev libminiupnpc-dev libnotify-dev libopus-dev \
    libssl-dev libva-dev libvdpau-dev libwayland-dev libx11-xcb-dev \
    libxcb-shm0-dev libxcb-xtest0-dev libxfixes-dev libxrandr-dev \
    libxtst-dev numactl npm nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

CMD ["bash"]
