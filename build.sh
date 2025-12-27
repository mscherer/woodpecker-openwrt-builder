#!/bin/bash
set -eux

CONFIG_FILE=builder.conf
[[ -f $CONFIG_FILE ]] || (echo "configuration $CONFIG_FILE not found" ; exit 1)

CUSTOMISE_FILE=customise.sh

[[ -v PLUGIN_SSH_KEY ]] || (echo "no ssh key found, please use ssh_key setting (and a secret)" ; exit 1)
[[ -v PLUGIN_SERVER ]] || (echo "no destination server set, please use server setting" ; exit 1)
[[ -v PLUGIN_TARGET ]] || (echo "no target directory set, please use target setting" ; exit 1)

source builder.conf

PROFILE=${PROFILE:-generic}
FILES=${FILES:-files}

[[ -v RELEASE ]] || (echo "RELEASE is not set in $CONFIG_FILE" ; exit 1)
[[ -v TARGET ]] || (echo "TARGET is not set in $CONFIG_FILE" ; exit 1)
[[ -v BOARD ]] || (echo "BOARD is not set in $CONFIG_FILE" ; exit 1)

CURRENT_DIR=$(pwd)
EXT=zst

cd /tmp
wget https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${BOARD}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${BOARD}.$(uname -s)-$(uname -m).tar.${EXT}
tar -xf openwrt-imagebuilder-*
rm -f openwrt-imagebuilder-*.tar.${EXT}
cd openwrt-imagebuilder-*

[[ -f ${CUSTOMISE_FILE} ]] && . ${CUSTOMISE_FILE}

make image EXTRA_IMAGE_NAME="${EXTRA_IMAGE_NAME}" PROFILE="${PROFILE}" DISABLED_SERVICES="${DISABLED_SERVICES}" PACKAGES="${PACKAGES}" FILES="${FILES}"

mkdir -p ${CURRENT_DIR}/build/
mv ./bin/targets/${TARGET}/${BOARD}/ ${CURRENT_DIR}/build/${CI_REPO_NAME}
cd ${CURRENT_DIR}/build
ls -lR

ls -l
# TODO embeded the current git short id in the name, as well as the date, see https://woodpecker-ci.org/docs/usage/environment

# hardcoding is fine since that's in CI and throwaway container
KEYFILE=/tmp/ssh_key
# keep the double ${} for variable escaping, and the " for
# https://stackoverflow.com/questions/22101778/how-to-preserve-line-breaks-when-storing-command-output-to-a-variable
echo "${PLUGIN_SSH_KEY}" > $KEYFILE
chmod 700 $KEYFILE

REMOTE_USERNAME=""
if [ -n ${PLUGIN_USERNAME} ]; then
	REMOTE_USERNAME="${PLUGIN_USERNAME}@"
fi;

scp -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -i $KEYFILE -r -- "${CI_REPO_NAME}" "${REMOTE_USERNAME}${PLUGIN_SERVER}:/${PLUGIN_TARGET}"
