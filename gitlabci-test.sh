#!/bin/bash
source ~/.bashrc
set -e
export GIT_SSL_NO_VERIFY=true 
export TASTE_IN_DOCKER=1 
git fetch 
git checkout -f "${CI_COMMIT_BRANCH}" 
git submodule init
git submodule update dmt
/etc/init.d/postgresql start 
cd dmt 
pip3 install -r requirements.txt 
LANG=C LC_ALL=C PATH=$PATH:$HOME/tool-inst/share/asn1scc/ make flake8 || exit 1
LANG=C LC_ALL=C PATH=$PATH:$HOME/tool-inst/share/asn1scc/ make pylint || exit 1
cd ..
./Update-TASTE.sh
cd kazoo 
apt-get install -y --force-yes xvfb 
Xvfb & 
export DISPLAY=:0 
make test || exit 1
cd ..
cd opengeode
make test-ada || exit 1
