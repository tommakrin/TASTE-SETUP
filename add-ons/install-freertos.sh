#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

DESCRIPTION="FreeRTOS"
FREERTOS_VERSION="10.2.1"

PREFIX="/opt"
INSTALL_PATH="$PREFIX/FreeRTOSv$FREERTOS_VERSION"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"

DownloadToTemp "${DESCRIPTION}" "https://sourceforge.net/projects/freertos/files/FreeRTOS/V${FREERTOS_VERSION}/FreeRTOSv${FREERTOS_VERSION}.zip/download"

echo "[-]"
echo "[-] Installing FreeRTOS..."
echo "[-]"

sudo unzip "$DOWNLOADED_FILE" -d "$PREFIX"
rm "$DOWNLOADED_FILE"

echo "[-] Creating FREERTOS_PATH enviroment variable"
PATH_CMD="export FREERTOS_PATH=\"$INSTALL_PATH\""
UpdatePATH
echo "[-] Reload terminal (or source ~/.bashrc.taste) to apply change"
