#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

FREERTOS_VERSION="10.2.1"

DESCRIPTION="FreeRTOS"

PREFIX="/opt"
INSTALL_PATH="$PREFIX/FreeRTOSv$FREERTOS_VERSION"
ZIP_FILE="FreeRTOS.zip"

echo "[-] Checking if FreeRTOS is already under ${INSTALL_PATH}..."
echo "[-]"

if [ -e "$INSTALL_PATH" ] ; then
    echo '[-] ${INSTALL_PATH} is there already. Aborting...'
    exit 1
fi

echo "[-] No FreeRTOS present - installing."

DownloadToTemp "${DESCRIPTION}" "https://sourceforge.net/projects/freertos/files/FreeRTOS/V${FREERTOS_VERSION}/FreeRTOSv${FREERTOS_VERSION}.zip/download"

echo "[-] Installing FreeRTOS..."
echo "[-]"

sudo unzip "$DOWNLOADED_FILE" -d "$PREFIX"
rm "$DOWNLOADED_FILE"

echo "[-] Creating FREERTOS_PATH enviroment variable"
echo -e "\n# FreeRTOS\nexport FREERTOS_PATH=\"$INSTALL_PATH\"" >> ~/.bashrc.taste
echo "[-] Reload terminal (or source ~/.bashrc.taste) to apply change"
