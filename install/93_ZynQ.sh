#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

cd ${DIR} || exit 1

# TODO build any needed libraries (e.g. AXI) and copy them under 'share'

grep ZYNQZC706 $HOME/.bashrc.taste >/dev/null || {
    echo 'export ZYNQZC706=$HOME/tool-src/misc/ZynQzc706/TASTE-VHDL-DESIGN.tar.bz2' >> $HOME/.bashrc.taste
}
