#!/bin/bash
set -eux
#TODO check the variable exist
#RELEASE="23.05.4"
#TARGET="ramips"
#BOARD="mt7621"

source builder.conf
PROFILE=${PROFILE:-generic}
FILES=${FILES:-config}

#TODO etape de preprocessing avec envsubst ?
CURRENT_DIR=$(pwd)

cd /tmp
wget https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${BOARD}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${BOARD}.Linux-x86_64.tar.zst
tar -xf openwrt-imagebuilder-*
rm -f openwrt-imagebuilder-*.tar.xz
cd openwrt-imagebuilder-*
make image
cp  ./bin/targets/${TARGET}/${BOARD}/openwrt-${RELEASE}-${EXTRA_IMAGE_NAME}-{$TARGET}-${BOARD}-${PROFILE}-squashfs-sysupgrade.bin ${CURRENT_DIR}/

# resultat dans ./bin/targets/${TARGET}/${BOARD}/openwrt-${RELEASE}-${EXTRA_IMAGE_NAME}-{$TARGET}-$4BOARD}-${PROFILE}-squashfs-sysupgrade.bin
# copie sur le routeur, et sysupgrade -v + le fichier

