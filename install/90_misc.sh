#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

cd ${DIR}/../misc || exit 1

# taste-config
echo "[-] Installing taste-config"
mkdir -p ${PREFIX}/bin
sed -e "s:INSTALL_PREFIX:${PREFIX}:g" taste-config.pl > taste-config.pl.tmp
install -m 755 taste-config.pl.tmp ${PREFIX}/bin/taste-config
rm -f taste-config.pl.tmp

# TASTE-Directives.asn
echo "[-] [DEPRECATED] Installing taste directives datamodel"
mkdir -p ${PREFIX}/share/taste
cp taste-directives/TASTE-Directives.asn ${PREFIX}/share/taste/TASTE-Directives.asn || exit 1

# TASTE types
echo "[-] Installing taste-types.asn"
mkdir -p ${PREFIX}/share/taste-types
cp taste-common-types/taste-types.asn ${PREFIX}/share/taste-types/ || exit 1

# Gnuplot
echo "[-] Installing driveGnuPlotsStreams.pl"
cp gnuplot/driveGnuPlotsStreams.pl ${PREFIX}/bin/taste-gnuplot-streams || exit 1

# PeekPoke component
echo "[-] Installing the PeekPoke component"
mkdir -p ${PREFIX}/share/peekpoke
cp peek-poke/peekpoke.py ${PREFIX}/share/peekpoke/peekpoke.py || exit 1
cp peek-poke/PeekPoke.glade ${PREFIX}/share/peekpoke/PeekPoke.glade || exit 1

# Shared function types
echo "[-] Installing the shared function types"
cp -ru SharedTypes ${PREFIX}/share/

# msc templates for Space Creator (to convert MSC to Python)
echo "[-] Installing Space Creator templates for model conversions"
cp -ru msc ${PREFIX}/share

# Space creator templates to convert XML to AADL
cp -ru space-creator/xml2aadl ${PREFIX}/share  # interface view to aadl
cp -ru space-creator/dv2aadl ${PREFIX}/share   # deployment view to aadl
cp -ru space-creator/iv2dv-coverage ${PREFIX}/share  # same as dv2aadl but with coverage enabled
cp -ru space-creator/xml2dv ${PREFIX}/share    # interface view to deployment view

# Helper scripts
echo "[-] Installing helper scripts"
cp -a helper-scripts/* ${PREFIX}/bin/

# GUI User-defined widgets
echo "[-] Installing tools for auto-generated GUIs, including inner-tracer"
TARGET=${PREFIX}/share/AutoGUI
mkdir -p ${TARGET}
cp -a AutoGUI/UserWidgets.py ${TARGET}

# Copy AADL Libraries to Ocarina and ellidiss folders
echo "[-] Installing AADL libraries"
make -C aadl-library install

# Ellidiss - point the PATH to the repo
# REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-linux/bin")
echo "[-] Setting up the PATH to Ellidiss tools"
#    REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-v1-linux/bin")
#    PATH_CMD='export PATH=$PATH:'"${REAL_ELLIDISS}"
#    UpdatePATH

#    REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-v1-linux")
#    PATH_CMD='export PATH=$PATH:'"${REAL_ELLIDISS}"
#    UpdatePATH

#    REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-linux/bin")
#    PATH_CMD='export PATH=$PATH:'"${REAL_ELLIDISS}"
#    UpdatePATH

echo "[-] Installing BRAVE Large FreeRTOS runtime"
mkdir -p  ${PREFIX}/share/BRAVE_Large_FreeRTOS/
cp -a BRAVE_Large/freertos/ ${PREFIX}/share/BRAVE_Large_FreeRTOS/

# 64-bits version
REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-linux64/bin")
PATH_CMD='export PATH='"${REAL_ELLIDISS}"':$PATH'
UpdatePATH

# Setup bash completion
echo "[-] Setting up bash completion"
grep bash_completion $HOME/.bashrc.taste >/dev/null || {
    echo '. /etc/bash_completion' >> $HOME/.bashrc.taste
}
