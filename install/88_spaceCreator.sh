#!/bin/bash
dpkg -l | grep '^ii.*spacecreator.*0.1.32074' > /dev/null || {
    dpkg -l | grep spacecreator > /dev/null && {
        echo "[-] Uninstalling previously existing version..."
        sudo apt remove -y --force-yes spacecreator || exit 1
    }
    echo "[-] Installing the latest Space Creator..."
    NEW_DEB=/tmp/newSpaceCreator.$$.deb
    if wget -O $NEW_DEB "https://download.tuxfamily.org/taste/SpaceCreator-0.1.32074-Linux.deb" ; then
        sudo gdebi -n -o=--no-install-recommends $NEW_DEB || {
            echo "[x] Failed to install $NEW_DEB..."
            ls -l $NEW_DEB
            echo "[x] Aborting."
            exit 1
        }
        rm -f $NEW_DEB
    else
        echo "[x] Failed to download the new Space Creator... Aborting."
        exit 1
    fi
}
