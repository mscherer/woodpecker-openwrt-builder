#!/bin/bash
set -eux

# TODO verify the file exist and show a proper error
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
wget https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${BOARD}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${BOARD}.$(uname -s)-$(uname -m).tar.${EXT}
tar -xf openwrt-imagebuilder-*
rm -f openwrt-imagebuilder-*.tar.${EXT}
cd openwrt-imagebuilder-*

make image EXTRA_IMAGE_NAME="${EXTRA_IMAGE_NAME}" PROFILE="${PROFILE}" DISABLED_SERVICES="${DISABLED_SERVICES}" PACKAGES="${PACKAGES}" FILES="${FILES}"

mv ./bin/targets/${TARGET}/${BOARD}/${IMAGE_NAME} ${CURRENT_DIR}/
cd ${CURRENT_DIR}

sha256sum ${IMAGE_NAME}
ls -l ${IMAGE_NAME}
# TODO copy to the webserver that host the image
# TODO do some link to latest ?
# TODO copy to the router
# TODO run sysupgrade -v on the router
# TODO embeded the current git short id in the name, as well as the date, see https://woodpecker-ci.org/docs/usage/environment
