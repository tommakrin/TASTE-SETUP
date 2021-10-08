#!/bin/bash
[ -d /usr/lib/python3.5 ] || {
    echo "[-] Installing support files from old Debian for Leon3 simulation..."
    OLD_PY=/tmp/python3.5.tar.gz
    if wget --no-check-certificate -O $OLD_PY "https://download.tuxfamily.org/taste/python3.5.tar.bz2" ; then
        cd /usr/lib
        sudo tar xpvf $OLD_PY || {
            echo "[x] Failed to install $OLD_PY..."
            ls -l $OLD_PY
            echo "[x] Aborting."
            exit 1
        }
        rm -f $OLD_PY
    else
        echo "[x] Failed to download the dependencies for the Leon3 simulator... Aborting."
        exit 1
    fi
} && exit 0
