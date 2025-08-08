#!/bin/bash
set -eux

source builder.conf

PROFILE=${PROFILE:-generic}
FILES=${FILES:-config}

[[ -v RELEASE ]] || "RELEASE is not set"
[[ -v TARGET ]] || "TARGET is not set"
[[ -v BOARD ]] || "BOARD is not set"

#TODO add potential templating with envsubst

CURRENT_DIR=$(pwd)
EXT=zst
IMAGE_NAME=openwrt-${RELEASE}-${EXTRA_IMAGE_NAME}-${TARGET}-${BOARD}-${PROFILE}-squashfs-sysupgrade.bin
cd /tmp
wget https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${BOARD}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${BOARD}.Linux-x86_64.tar.${EXT}
tar -xf openwrt-imagebuilder-*
rm -f openwrt-imagebuilder-*.tar.${EXT}
cd openwrt-imagebuilder-*

make image EXTRA_IMAGE_NAME="${EXTRA_IMAGE_NAME}" PROFILE="${PROFILE}" DISABLED_SERVICES="${DISABLED_SERVICES}" PACKAGES="${PACKAGES}" FILES="${FILES}"

mv ./bin/targets/${TARGET}/${BOARD}/${IMAGE_NAME} ${CURRENT_DIR}/

sha256sum ${IMAGE_NAME}
ls -l ${IMAGE_NAME}
# TODO copy to the webserver that host the image
# TODO do some link to latest ?
# TODO copy to the router
# TODO run sysupgrade -v on the router
