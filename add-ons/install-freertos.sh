#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

FREERTOS_VERSION="10.2.1"

PREFIX="/opt"
INSTALL_PATH="$PREFIX/FreeRTOSv$FREERTOS_VERSION"
ZIP_FILE="FreeRTOS.zip"
TMP_DIR="/tmp"

echo "[-] Checking if FreeRTOS is already under ${INSTALL_PATH}..."
echo "[-]"

if [ -e "$INSTALL_PATH" ] ; then
    echo '[-] ${INSTALL_PATH} is there already. Aborting...'
    exit 1
fi

echo "[-] No FreeRTOS present - installing."

echo "[-]"
echo "[-] Downloading FreeRTOS..."
echo "[-]"
cd "$TMP_DIR" || exit 1
wget -q -O $ZIP_FILE https://sourceforge.net/projects/freertos/files/FreeRTOS/V$FREERTOS_VERSION/FreeRTOSv$FREERTOS_VERSION.zip/download
if [ $? -ne 0 ] ; then
    echo "Downloading FreeRTOS has failed."
    echo Aborting...
    exit 1
fi

echo "[-] Installing FreeRTOS..."
echo "[-]"

sudo unzip "$ZIP_FILE" -d "$PREFIX"
rm "$ZIP_FILE"

echo "[-] Creating FREERTOS_PATH enviroment variable"
echo -e "\n# FreeRTOS\nexport FREERTOS_PATH=\"$INSTALL_PATH\"" >> ~/.bashrc.taste
echo "[-] Reload terminal (or source ~/.bashrc.taste) to apply change"
