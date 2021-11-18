#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}"/common.sh

#
# TASTE-SAMV71-Runtime
#

echo "Installing TASTE-SAMV71-Runtime"

cd "$DIR"/../TASTE-SAMV71-Runtime || exit 1

git submodule init
git submodule update

mkdir -p "${PREFIX}"/include/TASTE-SAMV71-Runtime
# delete old files
rm -rf "${PREFIX}"/include/TASTE-SAMV71-Runtime/*
# install
cp -r FreeRTOS-Kernel "${PREFIX}"/include/TASTE-SAMV71-Runtime/
cp -r SAMV71-BSP "${PREFIX}"/include/TASTE-SAMV71-Runtime/
cp -r src/Init "${PREFIX}"/include/TASTE-SAMV71-Runtime/
cp -r src/Hal "${PREFIX}"/include/TASTE-SAMV71-Runtime/
