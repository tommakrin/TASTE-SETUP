#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=../install/common.sh
. "${DIR}/../install/common.sh"

function CheckTargetFolder() {
    local DESCRIPTION="$1"
    local FOLDER="$2"

    echo "[-]"
    echo "[-] This script will install ${DESCRIPTION}"
    echo "[-] under:"
    echo "[-]"
    echo "[-]     ${FOLDER}"
    echo "[-]"

    if [ -e "${FOLDER}" ] ; then
        echo "[-] WARNING: It will remove everything that is currently there."
        echo "[-]"
    fi

    echo -n "[-] Are you sure you want this? (y/n)"
    read -r ANS
    if [ "$ANS" != "y" ] ; then
        echo '[-] Response was not "y", aborting...'
        exit 1
    fi

    sudo rm -rf "${FOLDER}" 2>/dev/null
}

function DownloadAndExtract() {
    local DESCRIPTION="$1"
    local URL="$2"
    local PREFIX="${3:-/opt}"
    local COMPRESSION="${4:-j}"

    echo "[-]"
    echo "[-] Downloading and uncompressing ${DESCRIPTION}..."
    echo "[-]"

    if ! wget -q --show-progress -O - "${URL}" | \
            ( cd "${PREFIX}" || exit 1 ; sudo tar "xv${COMPRESSION}f" - )
    then
        echo "Downloading ${DESCRIPTION} has failed."
        echo Aborting...
        exit 1
    fi
}

function InstallBSP() {
    local DESCRIPTION="$1"
    local URL="$2"
    local BASE="$3"
    local FOLDER="${BASE}/$4"

    CheckTargetFolder "$DESCRIPTION" "$FOLDER"
    DownloadAndExtract "$DESCRIPTION" "$URL" "$BASE"
}

function DownloadToTemp() {
    local DESCRIPTION="$1"
    local URL="$2"
    local TMP_DIR="${3:-/tmp}"

    DOWNLOADED_FILE=$(mktemp --tmpdir="$TMP_DIR")

    echo "[-]"
    echo "[-] Downloading ${DESCRIPTION}..."
    echo "[-]"

    if ! wget -q --show-progress -O "${DOWNLOADED_FILE}" "${URL}"
    then
        echo "Downloading ${DESCRIPTION} has failed."
        echo "Aborting..."
        exit 1
    fi
}
