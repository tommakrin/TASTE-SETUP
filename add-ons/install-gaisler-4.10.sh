#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

DESCRIPTION="Gaisler's RTEMS 4.10"
PREFIX="/opt"
INSTALL_PATH="$PREFIX/rtems-4.10"
URL="http://www.gaisler.com/j25/anonftp/rcc/bin/linux/sparc-rtems-4.10-gcc-4.4.6-1.2.21-linux.tar.bz2"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"
DownloadAndExtract "${DESCRIPTION}" "${URL}" "${PREFIX}"
