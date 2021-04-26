#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=common.sh
. "${DIR}/common.sh"

# Fetch and install latest AdaCore ARM release
SIG=$(/opt/GNAT/gnat-arm-2020/bin/arm-eabi-gcc -v 2>&1 | tail -1)
if [ "${SIG}" != "gcc version 9.3.1 20200430 (for GNAT Community 2020 20200429) (GCC) " ] ; then
    cd /opt/ || exit 1
    sudo wget -O gnat-2020-arm-bin https://community.download.adacore.com/v1/2b8ddb644a06808e7d2c6b62edf16d31b02f514f?filename=gnat-2020-20200429-arm-elf-linux64-bin || {
        echo "Failed to download AdaCore's ARM toolchain. Aborting..."
        exit 1
    }
    sudo chmod +x ./gnat-2020-arm-bin || exit 1
    sudo git clone https://github.com/AdaCore/gnat_community_install_script || {
        echo "Could not clone AdaCore's install scripts. Aborting..."
        sudo rm -rf gnat-2020-arm-bin gnat_community_install_script
        exit 1
    }
    sudo gnat_community_install_script/install_package.sh ./gnat-2020-arm-bin /opt/GNAT/gnat-arm-2020 || {
        echo "Failed installing AdaCore's ARM toolchain"
        sudo rm -rf gnat-2020-arm-bin gnat_community_install_script
        exit 1
    }
    sudo rm -rf gnat-2020-arm-bin gnat_community_install_script
fi

# Add to PATH
UpdatePROFILE "export PATH=\$PATH:/opt/GNAT/gnat-arm-2020/bin"
