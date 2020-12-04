#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=common.sh
. "${DIR}/common.sh"

DESCRIPTION="FreeRTOS"
FREERTOS_VERSION="10.2.1"

PREFIX="/opt"
INSTALL_PATH="$PREFIX/FreeRTOSv$FREERTOS_VERSION"

if [ -d $INSTALL_PATH ]
then
    echo "[-] FreeRTOS is already installed. Skipped."
    exit 0
fi

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"

DownloadToTemp "${DESCRIPTION}" "https://sourceforge.net/projects/freertos/files/FreeRTOS/V${FREERTOS_VERSION}/FreeRTOSv${FREERTOS_VERSION}.zip/download"

echo "[-]"
echo "[-] Installing FreeRTOS..."
echo "[-]"

sudo unzip "$DOWNLOADED_FILE" -d "$PREFIX"
rm "$DOWNLOADED_FILE"

# TODO
#
# After merge of PR with MSP430FR5969 port to the FreeRTOS repository
# and release of new version of FreeRTOS this step should be removed.
# Pull Request: https://github.com/FreeRTOS/FreeRTOS-Kernel/pull/44
#
echo "[-]"
echo "[-] Applying patch with support for MSP430FR5969"
cd "${INSTALL_PATH}"
sudo patch -s -p0 -i "${DIR}/freertos_msp430fr5969_port.patch"

echo "[-] Creating FREERTOS_PATH enviroment variable"
UpdatePROFILE "export FREERTOS_PATH=\"$INSTALL_PATH\""
echo "[-] Reload terminal (or source ~/.bashrc.taste) to apply change"
