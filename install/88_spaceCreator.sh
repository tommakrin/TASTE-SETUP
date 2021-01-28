#!/bin/bash
dpkg -l | grep '^ii.*spacecreator.*0.1.33843' > /dev/null || {
    dpkg -l | grep spacecreator > /dev/null && {
        echo "[-] Uninstalling previously existing version..."
        sudo apt remove -y --force-yes spacecreator || exit 1
    }
    echo "[-] Installing the latest Space Creator..."
    NEW_DEB=/tmp/newSpaceCreator.$$.deb
    if wget -O $NEW_DEB "https://download.tuxfamily.org/taste/SpaceCreator-0.1.33843-Linux.deb" ; then
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
# install the taste configuration files for Space Creator (color scheme, etc.)
echo "Installing Space Creator configuration files"
mkdir -p ~/.local/share/qtcreator/colors || exit 1
mkdir -p ~/.local/share/QtProject/QtCreator/contextMenu || exit 1
cp -u misc/space-creator/default_colors.json ~/.local/share/qtcreator/colors/default_colors.json  || exit 1
cp -u misc/space-creator/contextmenu.json ~/.local/share/QtProject/QtCreator/contextMenu/ || exit 1
cp -u misc/space-creator/default_attributes.xml ~/.local/share/QtProject/QtCreator/ || exit 1
