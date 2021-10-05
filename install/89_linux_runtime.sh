#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}"/common.sh

#
# TASTE-Runtime-Common
#

echo "Installing TASTE-Runtime-Common"

cd "$DIR"/../TASTE-Runtime-Common || exit 1

git submodule init
git submodule update

mkdir -p "${PREFIX}"/include/TASTE-Runtime-Common
# delete old files
rm -rf "${PREFIX}"/include/TASTE-Runtime-Common/src
# install
cp -r src "${PREFIX}"/include/TASTE-Runtime-Common/

cd "$DIR"

#
# TASTE-Linux-Runtime
#

echo "Installing TASTE-Linux-Runtime"

cd "$DIR"/../TASTE-Linux-Runtime || exit 1

git submodule init
git submodule update

mkdir -p "${PREFIX}"/include/TASTE-Linux-Runtime
# delete old files
rm -rf "${PREFIX}"/include/TASTE-Linux-Runtime/src
# install
cp -r src "${PREFIX}"/include/TASTE-Linux-Runtime/

cd "$DIR"

#
# TASTE-Linux-Drivers
#

echo "Installing TASTE-Linux-Drivers"

cd "$DIR"/../TASTE-Linux-Drivers || exit 1

git submodule init
git submodule update

mkdir -p "${PREFIX}"/include/TASTE-Linux-Drivers
# delete old files
rm -rf "${PREFIX}"/include/TASTE-Linux-Drivers/src
rm -rf "${PREFIX}"/include/TASTE-Linux-Drivers/configurations
# install
cp -r src "${PREFIX}"/include/TASTE-Linux-Drivers/
cp -r configurations "${PREFIX}"/include/TASTE-Linux-Drivers/
