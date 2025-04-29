#!/bin/bash

set -x

umount /Volumes/CaseSensitiveVolume

set -e

rm -rf ~/Desktop/CaseSensitive.dmg.sparsebundle && \
	hdiutil create -size 5g -type SPARSEBUNDLE -fs APFS -volname "TempVolume" ~/Desktop/CaseSensitive.dmg && \
	hdiutil attach ~/Desktop/CaseSensitive.dmg.sparsebundle && \
	sleep 2 && \
	diskutil eraseVolume APFSX "CaseSensitiveVolume" /Volumes/TempVolume

cd /Volumes/CaseSensitiveVolume

git clone https://github.com/rick/NestDFUAttack.git
