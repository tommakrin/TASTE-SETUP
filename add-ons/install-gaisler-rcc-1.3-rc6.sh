#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

DESCRIPTION="Gaisler's RCC1.3-rc6"
PREFIX="/opt"
INSTALL_PATH="$PREFIX/rcc-1.3.-rc6"
URL="https://www.gaisler.com/anonftp/rcc/bin/linux/sparc-rtems-5-gcc-7.2.0-1.3-rc6-linux.txz"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"
DownloadAndExtract "${DESCRIPTION}" "${URL}" "${PREFIX}" "J"
