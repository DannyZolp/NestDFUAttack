#!/bin/bash

# Change to the directory containing this script
cd "$(dirname "$0")"


#Redirect output to log
exec 3>&1 1>>GTVHacker-build.log 2>&1
set -x

#Display Ascii
echo "" 1>&3
echo "  ██████ ████████╗██╗   ██╗██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗ " 1>&3
echo " ██╔════╝╚══██╔══╝██║   ██║██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗" 1>&3
echo " ██║  ███╗  ██║   ██║   ██║███████║███████║██║     █████╔╝ █████╗  ██████╔╝" 1>&3
echo " ██║   ██║  ██║   ╚██╗ ██╔╝██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗" 1>&3
echo " ╚██████╔╝  ██║    ╚████╔╝ ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║" 1>&3
echo "  ╚═════╝   ╚═╝     ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝" 1>&3

if [ ! -d toolchain/arm-2008q3 ]; then
    echo "[I] - Downloading Nest toolchain. (80.5 MB)" 1>&3
    mkdir -p toolchain
    cd toolchain
    if [ ! -f arm-2008q3-72-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2 ]; then
        wget http://files.chumby.com/toolchain/arm-2008q3-72-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
    fi
    tar xjvf arm-2008q3-72-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
    rm arm-2008q3-72-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
    cd ..
fi

export PATH="$PATH:$(pwd)/toolchain/arm-2008q3/bin"

# Build and install GNU coreutils for the target and put the binaries into the
# project `root/` directory so they will be available on the target rootfs.
echo "[I] - Downloading and cross-compiling GNU coreutils for target." 1>&3
COREUTILS_VERSION=8.32
COREUTILS_TAR=coreutils-${COREUTILS_VERSION}.tar.xz
if [ ! -d coreutils-${COREUTILS_VERSION} ]; then
    if [ ! -f ${COREUTILS_TAR} ]; then
        echo "[I] - Downloading ${COREUTILS_TAR}" 1>&3
        wget https://ftp.gnu.org/gnu/coreutils/${COREUTILS_TAR}
    fi
    tar xf ${COREUTILS_TAR}
fi

# safe parallel job count for make (works on macOS/linux)
NPROC=$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)

echo "[I] - Configuring and building coreutils (this may take a few minutes)." 1>&3
cd coreutils-${COREUTILS_VERSION}
make distclean > /dev/null 2>&1 || true

# Tell coreutils to use the cross tools from the toolchain already added to PATH.
export CC=arm-none-linux-gnueabi-gcc
export AR=arm-none-linux-gnueabi-ar
export RANLIB=arm-none-linux-gnueabi-ranlib

# Install into the project's root directory (root/). This places executables into root/bin
PREFIX="$(pwd)/../root"
./configure --host=arm-none-linux-gnueabi --prefix=${PREFIX} || {
    echo "[E] - coreutils configure failed." 1>&3
    cd ..
}
make -j${NPROC} || make || { echo "[E] - coreutils build failed." 1>&3; cd ..; }
make install || { echo "[E] - coreutils install failed." 1>&3; cd ..; }
cd ..


echo "[I] - Cross compiling u-boot." 1>&3
cd u-boot
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- diamond
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
cd ..

if [ ! -f u-boot/u-boot.bin ]
    then
        echo "[E] - Error, u-boot compile failed."
        exit
    fi

echo "[I] - Cross compiling Linux (this could take a few minutes.)" 1>&3
cd linux
make ARCH=arm distclean gtvhacker_defconfig
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- uImage
cd ..

if [ ! -f linux/arch/arm/boot/uImage ]
    then
        echo "[E] - Error, Linux kernel compile failed."
        exit
    fi

echo "[I] - Cross compiling x-loader." 1>&3
cd x-loader
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- j49-usb-loader_config
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
cd ..

if [ ! -f x-loader/x-load.bin ]
    then
        echo "[E] - Error, x-loader compile failed."
        exit
    fi

echo "[I] - Compiling omap3_usbload for host machine." 1>&3
cd omap3_usbload
make clean
make
cd ..

if [ ! -f omap3_usbload/omap3_usbload ]
    then
        echo "[E] - Error, omap3_usbload compile failed."
        exit
    fi

echo "[I] - Copying files to \"Release\" directory." 1>&3
cp u-boot/u-boot.bin ../Release/Nest/
cp x-loader/x-load.bin ../Release/Nest/
cp linux/arch/arm/boot/uImage ../Release/Nest/
cp omap3_usbload/omap3_usbload ../Release/Linux/

echo -e "All Done Building, now run attack.sh when you are ready to attack the nest." 1>&3
