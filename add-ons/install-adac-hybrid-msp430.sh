#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=common.sh
. "${DIR}/common.sh"

DESCRIPTION="ADAC-HYBRID-MSP430"
ADAC_HYBRID_MSP430_VERSION="1.0.0"

PREFIX="/opt"
INSTALL_PATH="$PREFIX/adac-hybrid-msp430-${ADAC_HYBRID_MSP430_VERSION}"

if [ -d $INSTALL_PATH ]
then
    echo "[-] Ada hybrid MSP430 Compiler is already installed. Skipped."
    exit 0
fi

TEMP_INSTALL_PATH=$(mktemp -d --tmpdir="$TMP_DIR")

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"

DownloadToTemp "${DESCRIPTION}" "https://github.com/n7space/adac-hybrid-msp430/releases/download/v${ADAC_HYBRID_MSP430_VERSION}/adac-linux-${ADAC_HYBRID_MSP430_VERSION}.tar.gz"

echo "[-]"
echo "[-] Installing adac-hybrid-msp430..."
echo "[-]"

sudo tar -zxf "$DOWNLOADED_FILE" -C "$TEMP_INSTALL_PATH"
sudo mv "$TEMP_INSTALL_PATH/adac" "$INSTALL_PATH"
rm "$DOWNLOADED_FILE"
rm -rf "$TEMP_INSTALL_PATH"

echo "[-] Appending ${INSTALL_PATH}/bin to PATH"
UpdatePROFILE "export PATH=\$PATH:\"${INSTALL_PATH}/bin\""
echo "[-] Reload terminal (or source ~/.bashrc.taste) to apply change"
