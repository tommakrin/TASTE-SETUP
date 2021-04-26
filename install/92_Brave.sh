#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

cd ${DIR} || exit 1
make -C ../misc/Brave/gr740rcc13rc5/ || exit 1
mkdir -p ${PREFIX}/share/Brave
cp -u ../misc/Brave/gr740rcc13rc5/Lib/libBrave.a ${PREFIX}/share/Brave/

grep BRAVE $HOME/.bashrc.taste >/dev/null || {
    echo 'export BRAVE=$HOME/tool-src/misc/Brave/TASTE-VHDL-DESIGN.tar.bz2' >> $HOME/.bashrc.taste
}
