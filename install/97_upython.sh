#!/bin/bash
# Installation of micropython is disabled in the buster branch
# for two reasons:
# (1) support is incomplete in kazoo (TODO: port from buildsupport)
# (2) the Makefile calls "python" which does not point to anything
#     in some recent Linux distros such as Ubuntu 20.04
exit 0
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

# Install the scripts
cd ${DIR} || exit 1

cd .. || exit 1

make -C upython-taste/mpy-cross/
