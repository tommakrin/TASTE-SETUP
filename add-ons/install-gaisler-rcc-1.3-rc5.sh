#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

DESCRIPTION="Gaisler's RCC1.3-rc5"
PREFIX="/opt"
INSTALL_PATH="$PREFIX/rcc-1.3.-rc5"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"

echo "[-] Downloading and uncompressing Gaisler's RCC1.3-rc5-gcc..."
echo "[-]"
cd /opt || exit 1
wget -q -O - https://www.gaisler.com/anonftp/rcc/bin/linux/sparc-rtems-5-gcc-7.2.0-1.3-rc5-linux.txz | sudo tar Jxvf -
if [ $? -ne 0 ] ; then
    echo "Downloading Gaisler's RCC1.3-rc5-gcc toolchain has failed."
    echo Aborting...
    exit 1
fi
