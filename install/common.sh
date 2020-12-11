#!/bin/bash

export DISABLE_TASTE_BANNER=1
TASTE_PROFILE=$HOME/.bashrc.taste
PREFIX=$HOME/tool-inst

# shellcheck disable=SC1090
[ -e "${TASTE_PROFILE}" ] && . "${TASTE_PROFILE}"

UpdatePROFILE() {
    if [ -z "$1" ] ; then
        echo You forgot to pass argument. Aborting...
        exit 1
    fi
    grep "$1$" "${TASTE_PROFILE}" >/dev/null || echo "$1" >> "${TASTE_PROFILE}"
}

# kept for now for backward compatibility
UpdatePATH() {
    if [ -z "${PATH_CMD}" ] ; then
        echo You forgot to set your PATH_CMD. Aborting...
        exit 1
    fi
    UpdatePROFILE "${PATH_CMD}"
}
