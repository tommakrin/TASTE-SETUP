#!/bin/bash
/etc/init.d/postgresql start 
source ~/.bashrc
set -e
export GIT_SSL_NO_VERIFY=true 
export TASTE_IN_DOCKER=1
rm -rf *
git fetch || exit 1
git checkout -f "${CI_COMMIT_SHA}" || exit 1
git submodule init || exit 1
git submodule update || exit 1
./Update-TASTE.sh
#echo y | ./add-ons/install-msp430-gcc.sh  || exit 1
#./add-ons/install-gnat2020-for-arm.sh  || exit 1
#echo y | ./add-ons/install-adac-hybrid-msp430.sh  || exit 1
#echo y | ./add-ons/install-freertos.sh  || exit 1
source ~/.bashrc.taste || echo "[-] Sourced new environment."
cd kazoo 
export PATH=$HOME/tool-inst/bin:$HOME/.local/bin:$HOME/tool-inst/share/asn1scc:$PATH
export PATH=$HOME/tool-inst/share/kazoo:$PATH
export PATH=/opt/rtems-5.1-2019.07.25/bin:$PATH
export OCARINA_PATH=$HOME/tool-inst
export LD_LIBRARY_PATH=$HOME/tool-inst/lib:$LD_LIBRARY_PATH
export ZYNQZC706=${CI_PROJECT_DIR}/misc/ZynQzc706/TASTE-VHDL-DESIGN.tar.bz2
make test || exit 1
cd ..
cd dmt
git log | head
./configure
pip3 install --upgrade .
pip3 uninstall --yes typing 
PATH=$PATH:/asn1scc/ LANG=C LC_ALL=C make
cd ..
cd opengeode
make test-ada || exit 1
