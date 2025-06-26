FROM debian:trixie AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/debian.sources && echo "deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware\n\
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware\n\
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware" \
> /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update


# Update + Core Packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # Core dev tools
    build-essential cmake ninja-build git curl wget unzip pkg-config \
    python3 python3-pip python3-setuptools python3-jinja2 \
    gnupg2 lsb-release locales sudo xz-utils zip tar jq \
    autoconf automake libtool \
    # GUI/X11/Wayland/Xvfb
    x11-utils xauth x11-xserver-utils libx11-dev libxext-dev libxrandr-dev \
    libxinerama-dev libxcursor-dev libxcomposite-dev libxi-dev \
    libgl1-mesa-dev libglu1-mesa-dev libwayland-dev libxkbcommon-dev libdbus-1-dev \
    libdrm-dev libgbm-dev xvfb xserver-xorg-video-dummy \
    # Graphics, Vulkan, Mesa
    mesa-utils mesa-common-dev libvulkan-dev vulkan-tools \
    # Game & media libs
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    libglew-dev libglfw3-dev libglm-dev libassimp-dev \
    libopenal-dev libsndfile1-dev libfreetype6-dev \
    libjpeg-dev libpng-dev libtiff-dev zlib1g-dev \
    # Wine + Proton
    wine wine32 wine64 \
    # Steam runtime compat (32-bit libs)
    libudev1:i386 libgl1-mesa-dri:i386 libgl1:i386 libx11-6:i386 \
    libxrandr2:i386 libxss1:i386 libxtst6:i386 libgtk2.0-0:i386 \
    libpulse0:i386 libbz2-1.0:i386 libcurl4:i386 \
    # PipeWire build deps
    meson libasound2-dev libjack-jackd2-dev libpulse-dev \
    libsystemd-dev libudev-dev libglib2.0-dev libspa-0.2-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libbluetooth-dev libdbus-glib-1-dev libv4l-dev \
    gdb valgrind \
    # Godot build deps
    scons yasm clang llvm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Entrypoint
CMD ["bash"]
