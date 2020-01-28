#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

DESCRIPTION="MSP430 GCC Toolchain"
INSTALL_PATH="/opt/msp430-gcc"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    ARCH_INFIX="-x64"
    echo "[-] Selected 64bit version."
else
    ARCH_INFIX=""
    echo "[-] Selected 32bit version."
fi

DownloadToTemp "${DESCRIPTION}" http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/8_3_1_0/export/msp430-gcc-full-linux${ARCH_INFIX}-installer-8.3.1.0.run

echo "[-] Installing MSP430-GCC..."
echo "[-]"

chmod +x ${DOWNLOADED_FILE}
sudo ${DOWNLOADED_FILE} \
       --mode unattended \
       --unattendedmodeui minimal \
       --prefix /opt/msp430-gcc

rm ${DOWNLOADED_FILE}

echo "[-] Appending ${INSTALL_PATH}/bin to PATH"
echo -e "\n# MSP-430 support\nexport PATH=\$PATH:${INSTALL_PATH}/bin" >> ~/.bashrc.taste
echo "[-] Reload terminal (or source ~/.bashrc.taste) to apply change"
