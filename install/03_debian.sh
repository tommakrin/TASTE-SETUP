#!/bin/bash
ARCH=$(uname -m)
if [ "${ARCH}" == "x86_64" ] ; then
    dpkg --print-foreign-architectures | grep i386 >/dev/null || {
        sudo dpkg --add-architecture i386
    }
fi
sudo apt-get update
if [ "${ARCH}" == "x86_64" ] ; then
    sudo apt-get install --no-install-recommends -y --force-yes libc6:i386 libgcc1:i386 libxft2:i386 libxss1:i386 libcairo2:i386 libc6-dev-i386 
fi
sudo apt-get install --no-install-recommends -y --force-yes lsb-release

if [ -z "$VERSION" ] ; then
    VERSION="$(lsb_release -d)"
    if [ -f /.dockerenv ] ; then
        VERSION=${VERSION}-Dockerized
    fi
    echo "Version detected: ${VERSION}"
else
    echo "Version forced: ${VERSION}"
fi

case "$VERSION" in
    *Ubuntu*14.04* )
        sudo apt-get install --no-install-recommends -y --force-yes evince wget autoconf automake curl exuberant-ctags gcc git gnat gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libbonoboui2-0 libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgnome2-0 libgnome2-perl libgnome2-vfs-perl libgnomeui-0 libgnomevfs2-0 libgnomevfs2-common libgtk2-gladexml-perl libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client postgresql-client-common postgresql-common python-antlr python-sqlalchemy python-coverage python-gtk2-dev python-jinja2 python-lxml python-matplotlib python-pexpect expect python-pip python-ply python-psycopg2 python-pygraphviz python-pyside python3-pip qemu-system sqlite3 sudo tk8.5 tree vim-gtk wmctrl xmldiff xpdf xterm xterm zip openjdk-6-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-4.8-dev python-mako || exit 1
        ;;
    *Ubuntu*16.04* )
        sudo apt-get install --no-install-recommends -y --force-yes evince wget autoconf automake curl exuberant-ctags gcc git gnat gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libbonoboui2-0 libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgnome2-0 libgnome2-perl libgnome2-vfs-perl libgnomeui-0 libgnomevfs2-0 libgnomevfs2-common libgtk2-gladexml-perl libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev python-sqlalchemy libxslt1-dev libzmq3-dev mono-mcs mono-reference-assemblies-2.0 mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client postgresql-client-common postgresql-common python-antlr python-coverage python-gtk2-dev python-jinja2 python-lxml python-matplotlib python-pexpect expect python-pip python-psycopg2 python-pygraphviz python-pyside python3-pip qemu-system sqlite3 sudo tk8.5 tree vim-gtk wmctrl xmldiff xpdf xterm xterm zip openjdk-8-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-5-dev python-mako || exit 1
        ;;
    *Debian*stretch* | *Debian*stretch*Dockerized )
        sudo apt-get install --no-install-recommends -y --force-yes evince wget autoconf automake curl exuberant-ctags gcc git gnat gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libbonoboui2-0 libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgnome2-0 libgnome2-perl libgnome2-vfs-perl libgnomeui-0 libgnomevfs2-0 libgnomevfs2-common libgtk2-gladexml-perl libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-reference-assemblies-2.0 mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client python-sqlalchemy postgresql-client-common postgresql-common python-antlr python-coverage python-gtk2-dev python-jinja2 python-lxml python-matplotlib python-pexpect expect python-pip python-psycopg2 python-pygraphviz python-pyside python3-pip qemu-system sqlite3 sudo tk8.5 tree vim-gtk wmctrl xmldiff xpdf xterm xterm zip openjdk-8-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-6-dev libgnatcoll-python1.7-dev python-mako || exit 1
        ;;
    *Ubuntu*20.04* )
        sudo apt-get install --no-install-recommends -y --force-yes evince gdebi wget autoconf automake curl exuberant-ctags gcc git gnat-10 gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client postgresql-client-common postgresql-common python-coverage python-lxml python-pexpect expect python3-pip qemu-system sqlite3 sudo tk8.6 tree vim-gtk wmctrl xmldiff xterm xterm zip openjdk-11-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-8-dev python-mako gprbuild python3-singledispatch python3-stringtemplate3 python3-numpy python3-pyside2.* python3-pygraphviz python3-ply python3-matplotlib python3-lxml python3-pexpect python3-psycopg2 python3-antlr python3-antlr3 python3-websocket python-setuptools make python3-setuptools g++ psmisc bsdmainutils gnat-gps python-is-python2 || exit 1
	# pip2 is not available in ubuntu20.04 repos
	pip2 >/dev/null || (curl https://bootstrap.pypa.io/get-pip.py --output /var/tmp/get-pip.py && sudo python2 /var/tmp/get-pip.py) || exit 1
	# antlr2 for python2 (package python-antlr) is not available anymore either
	python2 -c "import antlr" &> /dev/null || (wget -O /tmp/python-pyside.deb "https://download.tuxfamily.org/taste/python2-antlr2-for-ubuntu20.deb" && sudo gdebi -n -o=--no-install-recommends /tmp/python-pyside.deb) || exit 1
	;;
    *Debian*buster* | Debian*buster*Dockerized )
        sudo apt-get install --no-install-recommends -y --force-yes evince gdebi wget autoconf automake curl exuberant-ctags gcc git gnat gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client postgresql-client-common postgresql-common python-antlr python-coverage python-gtk2-dev python-sqlalchemy python-jinja2 python-lxml python-matplotlib python-pexpect expect python-pip python-psycopg2 python3-pip qemu-system sqlite3 sudo tk8.6 tree vim-gtk wmctrl xmldiff xpdf xterm xterm zip openjdk-11-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-8-dev python-mako gprbuild python3-singledispatch python3-stringtemplate3 python3-numpy python3-pyside2.* python3-pygraphviz python3-ply python3-matplotlib python3-lxml python3-pexpect python3-psycopg2 python3-antlr python3-antlr3 python3-websocket python-setuptools make python3-setuptools g++ psmisc gnat-gps || exit 1
        pip3 install --user wheel || exit 1
        ;;
    * )
        echo 'Unrecognised distribution:' "${VERSION}"
        echo "Please update ~/tool-src/install/03_debian.sh to cover your distribution and send us a patch."
        exit 1
esac
