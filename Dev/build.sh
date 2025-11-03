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
