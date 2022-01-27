#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=common.sh
. "${DIR}/common.sh"

DESCRIPTION="ZynQ RTEMS 5.1"
PREFIX="/opt"
INSTALL_PATH="$PREFIX/rtems-5.1-2020.04.29"
URL="https://download.tuxfamily.org/taste/rtems-5.1-2020.04.29.tar.bz2"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"
DownloadAndExtract "${DESCRIPTION}" "${URL}" "${PREFIX}"

DESCRIPTION="Bambu 0.9.7"
PREFIX="/opt"
INSTALL_PATH="$PREFIX/bambu"
URL="https://download.tuxfamily.org/taste/bambu-0.9.7.tar.bz2"

CheckTargetFolder "${DESCRIPTION}" "${INSTALL_PATH}"
DownloadAndExtract "${DESCRIPTION}" "${URL}" "${PREFIX}"
