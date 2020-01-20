#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

echo "[-] Checking if Texas Instruments MSP430-GCC is already under /opt/msp430-gcc..."
echo "[-]"

if [ -e /opt/msp430-gcc ] ; then
    echo '[-] /opt/msp430-gcc is there already. Aborting...'
    exit 1
fi

echo "[-] No MSP430-GCC present - installing."

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  ARCH_INFIX="-x64"
  echo "[-] Selected 64bit version."
else
  ARCH_INFIX=""
  echo "[-] Selected 32bit version."
fi

echo "[-]"
echo "[-] Downloading MSP430-GCC..."
echo "[-]"
cd ~/Downloads || exit 1
wget -q -O msp430-gcc-installer.run http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/8_3_1_0/export/msp430-gcc-full-linux${ARCH_INFIX}-installer-8.3.1.0.run 
if [ $? -ne 0 ] ; then
    echo "Downloading MSP430-GCC toolchain has failed."
    echo Aborting...
    exit 1
fi

echo "[-] Installing MSP430-GCC..."
echo "[-]"

chmod +x msp430-gcc-installer.run 
sudo ./msp430-gcc-installer.run \
       --mode unattended \
       --unattendedmodeui minimal \
       --prefix /opt/msp430-gcc

rm msp430-gcc-installer.run

