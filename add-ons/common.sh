#!/bin/bash

function InstallBSP() {
    DESCRIPTION="$1"
    URL="$2"
    BASE="$3"
    FOLDER="${BASE}/$4"
    echo '[-] This will install '"${DESCRIPTION}"','
    echo '[-] under:'
    echo '[-] '
    echo '[-]     '"${FOLDER}"
    echo '[-] '
    [ -e "${FOLDER}" ] && { \
        echo '[-] It will remove anything that is currently there.'
        echo '[-] '
    }
    echo -n '[-] Are you sure you want this? (y/n) '
    read -r ANS
    if [ "$ANS" != "y" ] ; then
        echo '[-] Response was not "y", aborting...'
        exit 1
    fi
    sudo rm -rf "${FOLDER}" 2>/dev/null
    wget -q --show-progress -O - "${URL}"  | \
        ( cd "${BASE}" || exit 1 ; sudo tar jxvf - )
}

function DownloadToTemp() {
    local DESCRIPTION="$1"
    local URL="$2"
    local TMP_DIR="${3:-/tmp}"

    DOWNLOADED_FILE=$(mktemp --tmpdir="$TMP_DIR")

    echo "[-]"
    echo "[-] Downloading ${DESCRIPTION}..."
    echo "[-]"

    wget -q --show-progress -O "${DOWNLOADED_FILE}" "${URL}"

    if [ $? -ne 0 ] ; then
        echo "Downloading ${DESCRIPTION} has failed."
        echo "Aborting..."
        exit 1
    fi
}
