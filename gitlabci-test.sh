#!/bin/bash
source ~/.bashrc
set -e
export GIT_SSL_NO_VERIFY=true 
export TASTE_IN_DOCKER=1 
git fetch
git checkout -f "${CI_COMMIT_BRANCH}" 
./Update-TASTE.sh
cd kazoo 
export PATH=$HOME/tool-inst/bin:$HOME/.local/bin:$HOME/tool-inst/share/asn1scc:$PATH
export PATH=$HOME/tool-inst/share/kazoo:$PATH
export OCARINA_PATH=$HOME/tool-inst
export LD_LIBRARY_PATH=$HOME/tool-inst/lib:$LD_LIBRARY_PATH
make test || exit 1
cd ..
cd dmt
git log | head
/etc/init.d/postgresql start 
./configure
pip3 install --upgrade .
pip3 uninstall --yes typing 
PATH=$PATH:/asn1scc/ LANG=C LC_ALL=C make
cd ..
cd opengeode
make test-ada || exit 1
