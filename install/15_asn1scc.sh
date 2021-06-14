#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

dpkg -l | grep '^ii.*packages-microsoft-prod.*1.0-debian10.1' > /dev/null || {
    dpkg -l | grep packages-microsoft-prod > /dev/null && {
        echo "[-] Uninstalling previously existing version..."
        sudo apt remove -y --force-yes packages-microsoft-prod || exit 1
    }
    echo "[-] Installing the latest .NET run-time..."
    NEW_DEB=/tmp/dotnetcore.$$.deb
    if wget -O $NEW_DEB "https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb" ; then
        sudo gdebi -n -o=--no-install-recommends $NEW_DEB || {
            echo "[x] Failed to install $NEW_DEB..."
            ls -l $NEW_DEB
            echo "[x] Aborting."
            exit 1
        }
        rm -f $NEW_DEB
    else
        echo "[x] Failed to download the latest .NET run-time... Aborting."
        exit 1
    fi
}
# Fetch and install latest ASN1SCC release
mkdir -p "${PREFIX}/share/asn1scc/" || exit 1
cd "${PREFIX}/share/" || exit 1
VER=$(mono ~/tool-inst/share/asn1scc/asn1.exe -v |  head -1 | awk '{print $NF}')
if [ "${VER}" != "4.2.4.6f" ] ; then
    wget -q -O - https://github.com/ttsiodras/asn1scc/releases/download/4.2.4.6f/asn1scc-bin-4.2.4.6f.tar.bz2 \
        | tar jxvf -
fi
# Delete the AST cache folder in case the new version of the compiler generates different XML/Python output
find $HOME/.taste_AST_cache/ -type f -delete

# Add to PATH
PATH_CMD='export PATH=$PATH:'"${PREFIX}/share/asn1scc/"
UpdatePATH
