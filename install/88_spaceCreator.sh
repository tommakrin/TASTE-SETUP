#!/bin/bash
dpkg -l | grep '^ii.*spacecreator.*0.1.6d93e844' > /dev/null || {
    echo "Installing the latest Space Creator..."
    NEW_DEB=/tmp/newSpaceCreator.$$.deb
    if wget -O $NEW_DEB "https://download.tuxfamily.org/taste/SpaceCreator.deb" ; then
        sudo gdebi -n -o=--no-install-recommends $NEW_DEB || {
            echo Failed to install $NEW_DEB...
            ls -l $NEW_DEB
            echo Aborting.
            exit 1
        }
        rm -f $NEW_DEB
    else
        echo Failed to download the new Space Creator... Aborting.
        exit 1
    fi
}
