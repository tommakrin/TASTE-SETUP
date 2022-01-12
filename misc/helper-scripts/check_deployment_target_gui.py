#!/usr/bin/env python3

import sys
import os
from PySide2.QtGui import *
from PySide2.QtCore import *
from PySide2.QtWidgets import *
from PySide2.QtUiTools import *

from check_deployment_target_cli import *

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
