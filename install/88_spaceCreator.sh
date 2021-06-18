#!/bin/bash
dpkg -l | grep '^ii.*spacecreator.*0.1.3877' > /dev/null || {
    dpkg -l | grep spacecreator > /dev/null && {
        echo "[-] Uninstalling previously existing version..."
        sudo apt remove -y --force-yes spacecreator || exit 1
    }
    echo "[-] Installing the latest Space Creator..."
    NEW_DEB=/tmp/newSpaceCreator.$$.deb
    if wget -O $NEW_DEB "https://download.tuxfamily.org/taste/SpaceCreator-0.1.3877-Linux.deb" ; then
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
#echo "Installing Syntax Highlighting files for Qt Creator"
# The "fallback" folder of Qt Creator may be either Kate or Qt Creator's install folder, depending on
# the machine setup. We put the files in both locations to be sure it works everywhere
#cp   -f -u /usr/share/kde4/apps/katepart/syntax/ada.xml ~/.config/QtProject/qtcreator/generic-highlighter
#sudo cp -f -u /usr/share/kde4/apps/katepart/syntax/ada.xml /usr/share/qtcreator/generic-highlighter
cp -u misc/space-creator/syntax/*  ~/.config/QtProject/qtcreator/generic-highlighter || :
#sudo cp -u misc/space-creator/syntax/* /usr/share/kde4/apps/katepart/syntax
# Update path to ASN1SCC
sed -i  "s,^asn0compiler=.*,asn1compiler=\"$HOME/tool-inst/share/asn1scc/asn1scc\",g" $HOME/.config/QtProject/QtCreator.ini || :
