#!/bin/bash
set -eux

CONFIG_FILE=builder.conf
[[ -f $CONFIG_FILE ]] ||  (echo "configuration $CONFIG_FILE not found" ; exit 1)

source builder.conf

PROFILE=${PROFILE:-generic}
FILES=${FILES:-config}
FILESYSTEM=${FILESYSTEM:-squashfs}

[[ -v RELEASE ]] || (echo "RELEASE is not set in $CONFIG_FILE" ; exit 1)
[[ -v TARGET ]] || (echo "TARGET is not set in $CONFIG_FILE" ; exit 1)
[[ -v BOARD ]] || (echo "BOARD is not set in $CONFIG_FILE" ; exit 1)

CURRENT_DIR=$(pwd)
EXT=zst
IMAGE_NAME=openwrt-${RELEASE}-${EXTRA_IMAGE_NAME}-${TARGET}-${BOARD}-${PROFILE}-${FILESYSTEM}-sysupgrade.bin

cd /tmp
wget https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${BOARD}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${BOARD}.$(uname -s)-$(uname -m).tar.${EXT}
tar -xf openwrt-imagebuilder-*
rm -f openwrt-imagebuilder-*.tar.${EXT}
cd openwrt-imagebuilder-*

make image EXTRA_IMAGE_NAME="${EXTRA_IMAGE_NAME}" PROFILE="${PROFILE}" DISABLED_SERVICES="${DISABLED_SERVICES}" PACKAGES="${PACKAGES}" FILES="${FILES}"

mv ./bin/targets/${TARGET}/${BOARD}/ ${CURRENT_DIR}/build
cd ${CURRENT_DIR}/build

sha256sum ${IMAGE_NAME}
ls -l ${IMAGE_NAME}
# TODO embeded the current git short id in the name, as well as the date, see https://woodpecker-ci.org/docs/usage/environment
