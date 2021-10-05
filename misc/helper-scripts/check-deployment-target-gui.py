#!/usr/bin/env python3

import sys
import os
from PySide2.QtGui import *
from PySide2.QtCore import *
from PySide2.QtWidgets import *
from PySide2.QtUiTools import *

def install_gr740_rtems410_gaisler_posix():
    """ $ $HOME/tool-src/add-ons/install-gaisler-4.10.sh """
    os.system("xterm -e $HOME/tool-src/add-ons/install-gaisler-4.10.sh")

def install_gr740_rtems51_posix():
    """ $ $HOME/tool-src/install/85_rtems.sh """
    os.system("xterm -e $HOME/tool-src/install/85_rtems.sh")

def install_gr740_rcc13rc9_posix():
    """ $ $HOME/tool-src/add-ons/install-gaisler-rcc-1.3-rc9.sh """
    os.system("xterm -e $HOME/tool-src/add-ons/install-gaisler-rcc-1.3-rc9.sh")

def install_msp430_gcc_freertos():
    """$HOME/tool-src/add-ons/install-msp430-gcc.sh
$HOME/tool-src/add-ons/install-freertos.sh"""
    os.system("xterm -e $HOME/tool-src/add-ons/install-msp430-gcc.sh")
    os.system("xterm -e $HOME/tool-src/add-ons/install-freertos.sh")

def install_gnat2020_arm():
    """ $ $HOME/tool-src/add-ons/install-gnat2020-for-arm.sh """
    os.system("xterm -e $HOME/tool-src/add-ons/install-gnat2020-for-arm.sh")

def install_rpi_posix():
    """$ sudo apt install gcc-arm-linux-gnueabihf"""
    os.system("xterm -e sudo apt install -y gcc-arm-linux-gnueabihf gnat-8-arm-linux-gnueabihf g++-arm-linux-gnueabihf")

def check_rpi_posix():
    if not os.path.isfile("/usr/bin/arm-linux-gnueabihf-gcc"):
        raise NotImplementedError(install_rpi_posix)

def check_gr740_rtems410_gaisler_posix():
    if not os.path.isdir("/opt/rtems-4.10"):
        raise NotImplementedError(install_gr740_rtems410_gaisler_posix)

def check_gr740_rtems51_posix():
    if not os.path.isdir("/opt/rtems-5.1-2019.07.25"):
        raise NotImplementedError(install_gr740_rtems51_posix)

def check_gr740_rcc13rc9_posix():
    if not os.path.isdir("/opt/rcc-1.3-rc9"):
        raise NotImplementedError(install_gr740_rcc13rc9_posix)

def check_msp430_freertos():
    if not os.path.isdir("/opt/msp430-gcc"):
        raise NotImplementedError(install_msp430_gcc_freertos)
    if not os.path.isdir("/opt/FreeRTOSv10.2.1"):
        raise NotImplementedError()

def check_gnat2020_arm():
    if not os.path.isdir("/opt/GNAT/gnat-arm-2020/bin/"):
        raise NotImplementedError(install_gnat2020_arm)

# When editing, replace dot (.) with underscore (_)
# the TASTE GUI mixes them up if there is more than one underscore
PLATFORMS = { "crazyflie_v2_gnat"            : lambda: True,
              "stm32f4_discovery_gnat"       : lambda: True,
              "leon_rtems_posix"             : lambda: True,
              "leon2_rtems412_posix"         : lambda: True,
              "leon3_rtems412_posix"         : lambda: True,
              "gr712_rtems412_posix"         : lambda: True,
              "gr740_rtems412_posix"         : lambda: True,
              "rpi_posix"                    : check_rpi_posix,
              "leon3_AIR"                    : check_gr740_rtems51_posix,
              "stm32f407_discovery_gnat2020" : check_gnat2020_arm,
              "stm32f429_discovery_gnat2020" : check_gnat2020_arm,
              "gr740_rtems51_posix"          : check_gr740_rtems51_posix,
              "gr712rc_rtems51_posix"        : check_gr740_rtems51_posix,
              "leon2_rtems51_posix"          : check_gr740_rtems51_posix,
              "leon3_rtems51_posix"          : check_gr740_rtems51_posix,
              "n2x_rtems51_posix"            : check_gr740_rtems51_posix,
              "gr740_rtems410_gaisler_posix" : check_gr740_rtems410_gaisler_posix,
              "gr740_rcc13rc9_posix"         : check_gr740_rcc13rc9_posix,
              "n2x_rcc13rc9_posix"           : check_gr740_rcc13rc9_posix,
              "gr712rc_rcc13rc9_posix"       : check_gr740_rcc13rc9_posix,
              "leon3_rcc13rc9_posix"         : check_gr740_rcc13rc9_posix,
              "x86_linux"                    : lambda: True,
              "x86_win32"                    : lambda: True,
              "msp430fr5969_freertos"        : check_msp430_freertos,
              "x86_generic_linux"            : lambda: True
             }

def query_user(platform):
    msg_box = QMessageBox()
    msg_box.setWindowTitle("This plaform is not installed!")
    ok    = msg_box.addButton("Install now",   QMessageBox.AcceptRole)
    later = msg_box.addButton("Install later", QMessageBox.RejectRole)
    msg_box.setEscapeButton(later)
    msg_box.setDefaultButton(ok)
    msg_box.setIcon(QMessageBox.Warning)
    msg_box.setText("Do you want to install target\n{} ?".format(platform))
    msg_box.exec_()
    return msg_box.clickedButton() == ok

def main():
    app = QApplication(sys.argv)
    # check if the target in supported
    try:
        platform = sys.argv[1]
        PLATFORMS[platform.replace('.', '_')]()
    except KeyError:
        warn_box = QMessageBox()
        warn_box.setIcon(QMessageBox.Information)
        warn_box.setText("Unknown platform: {}".format(platform))
        warn_box.exec_()
        return 1
    except IndexError:
        print("You must specify the target in the command line")
    except NotImplementedError as exc:
        install_it, = exc.args
        if query_user(platform):
            install_it()
        else:
            warn_box = QMessageBox()
            warn_box.setIcon(QMessageBox.Information)
            warn_box.setText("You can install the platform later by typing:\n"
                              + str(install_it.__doc__))
            warn_box.exec_()

    else:
        print("Platform {} is installed".format(platform))
        sys.exit(0)

if __name__ == '__main__':
    main()
