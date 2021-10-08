#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

# Fetch and install latest ASN1SCC release
mkdir -p "${PREFIX}/share/asn1scc/" || exit 1
cd "${PREFIX}/share/" || exit 1
VER=$(~/tool-inst/share/asn1scc/asn1scc -v |  head -1 | awk '{print $NF}')
if [ "${VER}" != "4.2.4.7f" ] ; then
    wget -q -O - https://github.com/ttsiodras/asn1scc/releases/download/4.2.4.7f/asn1scc-bin-4.2.4.7f.tar.bz2 \
        | tar jxvf -
fi
# Delete the AST cache folder in case the new version of the compiler generates different XML/Python output
find $HOME/.taste_AST_cache/ -type f -delete

# Add to PATH
PATH_CMD='export PATH=$PATH:'"${PREFIX}/share/asn1scc/"
UpdatePATH
