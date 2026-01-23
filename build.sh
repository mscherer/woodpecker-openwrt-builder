#!/bin/bash
set -eux

CONFIG_FILE=builder.conf
[[ -f $CONFIG_FILE ]] || (echo "configuration $CONFIG_FILE not found" ; exit 1)

[[ -v PLUGIN_SSH_KEY ]] && [[ -v PLUGIN_SERVER ]] && [[ -v PLUGIN_TARGET ]] && UPLOAD_FILE=1

source ${CONFIG_FILE}

PROFILE=${PROFILE:-generic}
FILES=${FILES:-files}

[[ -v RELEASE ]] || (echo "RELEASE is not set in $CONFIG_FILE" ; exit 1)
[[ -v TARGET ]] || (echo "TARGET is not set in $CONFIG_FILE" ; exit 1)
[[ -v BOARD ]] || (echo "BOARD is not set in $CONFIG_FILE" ; exit 1)

SOURCE_DIR=$(pwd)
EXT=zst
CUSTOMISE_FILE=customise.sh

cd /tmp
URL_PREFIX=https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${BOARD}/

wget ${URL_PREFIX}/profiles.json
jq -e .profiles.[\"$PROFILE\"] < profiles.json > /dev/null
if [ $? -ne 0 ]; then
  echo "Profile not found in profiles.json"
  echo "Detected options:"
  jq -M '.profiles|keys.[]' < profiles.json
  exit 1
fi;

wget ${URL_PREFIX}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${BOARD}.$(uname -s)-$(uname -m).tar.${EXT}
tar -xf openwrt-imagebuilder-*
rm -f openwrt-imagebuilder-*.tar.${EXT}
cd openwrt-imagebuilder-*

[[ -f ${SOURCE_DIR}/${CUSTOMISE_FILE} ]] && ( cd $SOURCE_DIR ; . ${CUSTOMISE_FILE} ; cd - )


make image EXTRA_IMAGE_NAME="${EXTRA_IMAGE_NAME}" PROFILE="${PROFILE}" DISABLED_SERVICES="${DISABLED_SERVICES}" PACKAGES="${PACKAGES}" FILES="${SOURCE_DIR}/${FILES}"

cd ./bin/targets/${TARGET}/
(cd "${BOARD}" ; ls -l . )

# TODO embed the current git short id in the name, as well as the date, see https://woodpecker-ci.org/docs/usage/environment
if [[ -v UPLOAD_FILE ]]; then
	# hardcoding is fine since that's in CI and throwaway container
	KEYFILE=/tmp/ssh_key
	# keep the double ${} for variable escaping, and the " for
	# https://stackoverflow.com/questions/22101778/how-to-preserve-line-breaks-when-storing-command-output-to-a-variable
	echo "${PLUGIN_SSH_KEY}" > $KEYFILE
	chmod 700 $KEYFILE

	REMOTE_USERNAME=""
	if [ -n ${PLUGIN_USERNAME} ]; then
		REMOTE_USERNAME="-u ${PLUGIN_USERNAME},"
	fi;
	echo "set sftp:auto-confirm yes" > ~/.lftprc
	echo "set sftp:connect-program \"ssh -a -x -i $KEYFILE\"" >> ~/.lftprc

	lftp $REMOTE_USERNAME -e "mirror -R --no-perms ./${BOARD}/ $PLUGIN_TARGET; bye" sftp://$PLUGIN_SERVER
else
	echo "No upload of the data, since no config have been provided"
fi
