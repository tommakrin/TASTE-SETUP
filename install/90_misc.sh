#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

cd ${DIR}/../misc || exit 1

# taste-config
mkdir -p ${PREFIX}/bin
sed -e "s:INSTALL_PREFIX:${PREFIX}:g" taste-config.pl > taste-config.pl.tmp
install -m 755 taste-config.pl.tmp ${PREFIX}/bin/taste-config
rm -f taste-config.pl.tmp

# TASTE-Directives.asn
mkdir -p ${PREFIX}/share/taste
cp taste-directives/TASTE-Directives.asn ${PREFIX}/share/taste/TASTE-Directives.asn || exit 1

# TASTE types
mkdir -p ${PREFIX}/share/taste-types
cp taste-common-types/taste-types.asn ${PREFIX}/share/taste-types/ || exit 1

# Gnuplot
cp gnuplot/driveGnuPlotsStreams.pl ${PREFIX}/bin/taste-gnuplot-streams || exit 1

# PeekPoke component
mkdir -p ${PREFIX}/share/peekpoke
cp peek-poke/peekpoke.py ${PREFIX}/share/peekpoke/peekpoke.py || exit 1
cp peek-poke/PeekPoke.glade ${PREFIX}/share/peekpoke/PeekPoke.glade || exit 1

# Shared function types
cp -ru SharedTypes ${PREFIX}/share/

# Helper scripts
cp -a helper-scripts/* ${PREFIX}/bin/

# GUI User-defined widgets
TARGET=${PREFIX}/share/AutoGUI
mkdir -p ${TARGET}
cp -a AutoGUI/UserWidgets.py ${TARGET}

# Copy AADL Libraries to Ocarina and ellidiss folders
make -C aadl-library install

# Ellidiss - point the PATH to the repo
# REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-linux/bin")
REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-v1-linux/bin")
PATH_CMD='export PATH=$PATH:'"${REAL_ELLIDISS}"
UpdatePATH

REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-v1-linux")
PATH_CMD='export PATH=$PATH:'"${REAL_ELLIDISS}"
UpdatePATH

REAL_ELLIDISS=$(realpath "${DIR}/../ellidiss-GUI/TASTE-linux/bin")
PATH_CMD='export PATH=$PATH:'"${REAL_ELLIDISS}"
UpdatePATH

# Setup bash completion
grep bash_completion $HOME/.bashrc.taste >/dev/null || {
    echo '. /etc/bash_completion' >> $HOME/.bashrc.taste
}
