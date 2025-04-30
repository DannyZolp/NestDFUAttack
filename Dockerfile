FROM amd64/ubuntu:18.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic main universe" && \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic-updates main universe" && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    wget \
    bzip2 \
    git \
    libncurses-dev \
    u-boot-tools \
    bc \
    gcc-multilib \
    g++-multilib \
    lib32gcc1 \
    libc6-i386 \
    lib32stdc++6 \
    perl \
    flex \
    bison \
    libssl-dev \
    linux-headers-generic \
    libusb-dev \
    libusb-0.1-4 \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy the project files
COPY . .

# Create Release directories
RUN mkdir -p Release/Nest Release/Linux

# Make build script executable
RUN chmod +x Dev/build.sh

# Set default command
CMD ["/bin/bash"]
