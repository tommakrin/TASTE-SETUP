#!/usr/bin/env python3

import sys
import os

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

def install_zynq7000_rtems():
    """ $ /home/taste/tool-src/add-ons/install-zynqrtems-5.1.sh """
    os.system("xterm -e /home/taste/tool-src/add-ons/install-zynqrtems-5.1.sh")

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

def check_zynq7000_rtems():
    if not os.path.isdir("/opt/rtems-5.1-2020.04.29/"):
        raise NotImplementedError(install_zynq7000_rtems)

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
              "x86_generic_linux"            : lambda: True,
              "zynqzc706_rtems_posix"        : check_zynq7000_rtems,
             }


def cli_query_user(platform):
    print(f"[-] This plaform is not installed: {platform}")
    if not sys.stdout.isatty():
        # When not running from a terminal, just exit with error
        return False
    resp = input(f"[?] Do you want to install target {platform} ? [Y/n]")
    if not resp or resp.lower() == 'y':
        return True
    else:
        return False

def main():
    # check if the target in supported
    try:
        platform = sys.argv[1]
        PLATFORMS[platform.replace('.', '_')]()
    except (KeyError, IndexError):
        print(f"[X] Unknown or unspecified platform")
        print("[-] This is the list of supported platforms:")
        for each in PLATFORMS.keys():
            print(f"   {each}")
        return 1
    except NotImplementedError as exc:
        install_it, = exc.args
        if cli_query_user(platform):
            install_it()
        else:
            print("[-] You can install the platform later by typing:\n   "
                              + str(install_it.__doc__))
            return 0

    else:
        print(f"[-] Platform {platform} is installed")
        sys.exit(0)

if __name__ == '__main__':
    main()
