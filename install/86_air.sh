#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

cd "$DIR"/../air || exit 1
git submodule init
git submodule update air/pos/rtems5

cd air || exit 1

# As per request of Laura Gouveia (mail discussions at 22/10/2019):
#
# AIR doesn't check during 'make' for a changed target board; it depends on
# a 'make clean' done first, if the chosen configuration changes.
#
# To make the final delivery use LEON4-specific functionality,
# it is therefore not sufficient to choose a different number
# in the second question (see below) and just commit an updated config;
# we need to somehow trigger this 'make clean' - BUT not always!
# We only want to do this once, otherwise 'Update-TASTE.sh' will take
# a lot longer, because of AIR being rebuilt from scratch every time.
#
# So we need this hack:

# Is there a previous AIR build?
if [ -f .air_config ] ; then
    # Yes, there is. Did the previous build target leon4?
    OLD_TARGET=$(python3 -c 'import pickle; print(pickle.load(open(".air_config", "rb"))[1])')
    if [ "$OLD_TARGET" != "leon4" ] ; then
        # It didn't! Cleanup the universe, to trigger a rebuild from scratch
        make clean
    fi
fi

# Pass the following configuration to AIR's "configure" script:
#
# Select the target architecture:
# * [0]: sparc
# Select the target board support package:
# * [0]: leon3_or_tsim2
#   [1]: tsim
#   [2]: leon4
# Select if FPU is:
# * [0]: Enabled
#   [1]: Disabled
# Select debug monitor:
# * [0]: GRMON
#   [1]: DMON
# Install All RTOS ?
# * [0]: No
#   [1]: Yes
# Install posixrtems5?
#   [0]: No
# * [1]: Yes
# Install rtems48i?
# * [0]: No
#   [1]: Yes
# Install rtems5?
#   [0]: No
# * [1]: Yes
# Install bare?
# * [0]: No
#   [1]: Yes
#
# Sadly, air's "configure" doesn't show these options in the same order;
# e.g. under a 32bit VM the order is different to that under a 64bit VM!
#
# So we can't do this..
# echo -e "0\n0\n0\n0\n0\n1\n0\n1\n0\n\n" | ./configure
# 
# Instead, we do this - which is arguably a hack:
../../install/air.expect || exit 1
make || exit 1

# Add to PATH
AIR_REAL_PATH="$(realpath $(pwd))"
PATH_CMD='export PATH=$PATH:"'"${AIR_REAL_PATH}"'"'
UpdatePATH

PATH_CMD='export AIR="'"${AIR_REAL_PATH}"'"'
UpdatePATH
