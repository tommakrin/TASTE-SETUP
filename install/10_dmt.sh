#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${DIR}/common.sh"

# Setup the tools in ~/.local/bin
cd "$DIR/../dmt" || exit 1

./configure || exit 1

# Launching "dmt --version" reports the wrong (local!) version number 
# if we are inside "dmt"... so cd outside first!
cd .. || exit 1

# Skip install if the version installed is the same and the tree is clean
HEAD="$(grep version= dmt/setup.py 2>/dev/null | awk -F\" '{print $2}')"
VERSION_INSTALLED="$(dmt --version 2>/dev/null | grep ^TAST | awk '{print $NF}')"

# Return back inside dmt, now that we're done with "dmt --version"
cd dmt || exit 1

if [ "$HEAD" == "" ] ; then
    TREE_DIRTY=1
else
    GIT_OUTPUT=$(git status --porcelain)
    if [ "${GIT_OUTPUT}" == "" ] ; then
        TREE_DIRTY=0
    else
        TREE_DIRTY=1
    fi
fi

if [ ${TREE_DIRTY} -eq 0 ] && [ "${HEAD}" == "${VERSION_INSTALLED}" ] ; then
    echo "DMT tree is clean and already installed (${VERSION_INSTALLED}). Skipping DMT install..."
    exit 0
fi

echo -e "\nInstalling DMT, since..."

if [ ${TREE_DIRTY} -ne 0 ] ; then
    echo "- working tree is not clean."
fi

if [ "${HEAD}" != "${VERSION_INSTALLED}" ] ; then
    echo "- installed version ${VERSION_INSTALLED} is not ${HEAD}."
fi

echo -e "\n"

make install || exit 1

# Add .local/bin to PATH
PATH_CMD='export PATH=$PATH:$HOME/.local/bin'
UpdatePATH
