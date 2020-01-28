#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

DESCRIPTION="Gaisler's RTEMS 4.10"
PREFIX="/opt"
INSTALL_PATH="$PREFIX/rtems-4.10"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"

echo "[-] Downloading and uncompressing Gaisler's RTEMS 4.10..."
echo "[-]"
cd "${PREFIX}" || exit 1
wget -q -O - http://www.gaisler.com/j25/anonftp/rcc/bin/linux/sparc-rtems-4.10-gcc-4.4.6-1.2.21-linux.tar.bz2 | sudo tar jxvf -
if [ $? -ne 0 ] ; then
    echo "Downloading Gaisler's RTEMS 4.10 toolchain has failed."
    echo Aborting...
    exit 1
fi
