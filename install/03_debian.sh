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
    *Ubuntu*18.04* )
        sudo apt-get install -y --force-yes wget gdebi evince autoconf automake curl exuberant-ctags gcc git gnat gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libbonoboui2-0 libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgnome2-0 libgnome2-perl libgnome2-vfs-perl libgnomeui-0 libgnomevfs2-0 libgnomevfs2-common libgtk2-gladexml-perl libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-reference-assemblies-2.0 mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client postgresql-client-common postgresql-common python-antlr python-coverage python-gtk2-dev python-jinja2 python-lxml python-matplotlib python-pexpect expect python-pip python-psycopg2 python-pygraphviz python-pyside python3-pip qemu-system sqlite3 sudo tk8.5 tree vim-gtk wmctrl xmldiff xpdf xterm xterm zip openjdk-8-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-6-dev gprbuild libgnat-6:i386 python3-singledispatch python3-stringtemplate3 python3-numpy python3-pyside2.* python3-pygraphviz python3-sqlalchemy python3-ply python3-matplotlib python3-lxml python3-pexpect python3-psycopg2 python3-antlr python3-antlr3 python3-websocket python-setuptools make python3-setuptools g++ psmisc bsdmainutils gnat-gps python-is-python2 bzip2 unzip rsync libncurses5:i386 libgmp10:i386 || exit 1
        ;;
    *Ubuntu*20.04* )
        sudo apt-get install --no-install-recommends -y --force-yes evince gdebi wget autoconf automake curl universal-ctags gcc git gnat-10 gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-runtime nedit net-tools python-coverage python-lxml python-pexpect expect python3-pip qemu-system sqlite3 sudo tk8.6 tree vim-gtk wmctrl xmldiff xterm xterm zip openjdk-11-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-8-dev python-mako gprbuild python3-singledispatch python3-stringtemplate3 python3-numpy python3-pyside2.* python3-pygraphviz python3-sqlalchemy python3-ply python3-matplotlib python3-lxml python3-pexpect python3-psycopg2 python3-antlr python3-antlr3 python3-websocket python-setuptools make python3-setuptools g++ psmisc bsdmainutils gnat-gps python-is-python2 bzip2 unzip rsync libncurses5:i386 libgmp10:i386 qt5-default xdg-utils python3-mako python3-gi sqlitebrowser || exit 1
	# pip2 is not available in ubuntu20.04 repos
	pip2 >/dev/null || (curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /var/tmp/get-pip.py && sudo python2 /var/tmp/get-pip.py) || exit 1
	# antlr2 for python2 (package python-antlr) is not available anymore either
	python2 -c "import antlr" &> /dev/null || (wget --no-check-certificate -O /tmp/python-pyside.deb "https://download.tuxfamily.org/taste/python2-antlr2-for-ubuntu20.deb" && sudo gdebi -n -o=--no-install-recommends /tmp/python-pyside.deb) || exit 1
	;;
    *Debian*buster* | Debian*buster*Dockerized )
        sudo apt-get install --no-install-recommends -y --force-yes evince gdebi wget autoconf automake curl exuberant-ctags gcc git gnat gtkwave kate lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libdbd-sqlite3-perl libdbi-perl libfile-copy-recursive-perl libglib2.0-0 libgtk2-perl libgraphviz-dev libmono-system-data-linq4.0-cil libmono-system-numerics4.0-cil libmono-system-runtime-serialization-formatters-soap4.0-cil libmono-system-runtime4.0-cil libmono-system-web4.0-cil libmono-system-xml4.0-cil libmono-system4.0-cil libsqlite3-dev libtool libxml-libxml-perl libxml-libxml-simple-perl libxml-parser-perl libxml2-dev libxslt1-dev libzmq3-dev mono-mcs mono-runtime nedit net-tools pgadmin3 postgresql postgresql-client postgresql-client-common postgresql-common python-antlr python-coverage python-gtk2-dev python-sqlalchemy python-jinja2 python-lxml python-matplotlib python-pexpect expect python-pip python-psycopg2 python3-pip qemu-system sqlite3 sudo tk8.6 tree vim-gtk wmctrl xmldiff xpdf xterm xterm zip openjdk-11-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-8-dev python-mako gprbuild python3-singledispatch python3-stringtemplate3 python3-numpy python3-pyside2.* pyside2-tools python3-pygraphviz python3-ply python3-matplotlib python3-lxml python3-sqlalchemy python3-pexpect python3-psycopg2 python3-antlr python3-antlr3 python3-websocket python-setuptools make python3-setuptools g++ psmisc gnat-gps bzip2 bsdmainutils unzip rsync libncurses5:i386 libgmp10:i386 qt5-default xdg-utils python3-mako || exit 1
        # In case qterminal was the default for x-terminal-emulator: remove it, it is too buggy
        sudo update-alternatives --set x-terminal-emulator $(which xterm) || :
        python3 -m pip install --user wheel || exit 1
        ;;
    *Debian*bullseye* | Debian*bullseye*Dockerized )
	# removed after buster: pgadmin3 gnat-gps, python3-antlr3, python-pip
        sudo apt-get install --no-install-recommends -y --force-yes evince gdebi wget autoconf automake curl universal-ctags gcc git gnat gtkwave lcov libacl1 libacl1-dev libarchive-dev libattr1 libattr1-dev libglib2.0-0 libgraphviz-dev libsqlite3-dev libtool libxml2-dev libxslt1-dev net-tools expect python3-pip sqlite3 sudo tree vim-gtk wmctrl xmldiff xterm zip openjdk-17-jre python3-lxml bash-completion strace libusb-1.0-0-dev cmake dfu-util gnuplot libstdc++-10-dev gprbuild python3-singledispatch python3-stringtemplate3 python3-numpy python3-pygraphviz python3-ply python3-matplotlib python3-lxml python3-sqlalchemy python3-pexpect python3-psycopg2 python3-antlr python3-websocket  make python3-setuptools g++ psmisc bzip2 bsdmainutils unzip rsync libncurses5:i386 libgmp10:i386 xdg-utils qt5-qmake qtbase5-dev python3-mako python3-gi sqlitebrowser || exit 1
        # If you need postgresql install the following : postgresql postgresql-client postgresql-client-common postgresql-common 
	python3 -m pip install --user wheel || exit 1
	# bullseye version of pyside2 is buggy for qml support, we need the pip version
	python3 -m pip install --user --upgrade pyside2 || exit 1
	# pip2 is not available in debian 11 and Python2 is not installed by default
	# Install them manually until we don't need them anymore
	sudo apt install -y python2
	pip2 >/dev/null || (curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /var/tmp/get-pip.py && sudo python2 /var/tmp/get-pip.py) || exit 1
        # antlr2 for python2 (package python-antlr) is not available anymore either (needed by dmt's AADL parser)
	python2 -c "import antlr" &> /dev/null || (wget --no-check-certificate -O /tmp/python-antlr.deb "https://download.tuxfamily.org/taste/python2-antlr2-for-ubuntu20.deb" && sudo gdebi -n -o=--no-install-recommends /tmp/python-antlr.deb) || exit 1
        ;;
    * )
        echo 'Unrecognised distribution:' "${VERSION}"
        echo "Please update ~/tool-src/install/03_debian.sh to cover your distribution and send us a patch."
        exit 1
esac
