#!/bin/bash
set -euo pipefail
export DISPLAY=:0 
export GIT_SSL_NO_VERIFY=true 
export LD_LIBRARY_PATH=/lib
source ~/.bashrc
export TASTE_IN_DOCKER=1 
/etc/init.d/postgresql start 
cd dmt 
pip3 install -r requirements.txt 
LANG=C LC_ALL=C PATH=$PATH:$HOME/tool-inst/share/asn1scc/ make
git fetch 
git checkout -f "${CI_COMMIT_BRANCH}" 
./Update-TASTE.sh
cd ../kazoo 
apt-get install -y --force-yes xvfb 
Xvfb & 
make test
