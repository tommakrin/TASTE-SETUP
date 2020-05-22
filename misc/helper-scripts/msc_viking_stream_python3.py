#!/usr/bin/env python3

# Example of use of the MSC Editor from Viking SW in streaming mode
# using websockets.
# The tool must be in th PATH to run
# (c) Maxime Perrotin / ESA 2020

import sys
import time

# install websocket with apt install python3-websocket
# NOT WITH pip3 install websocket: it is a different library!
# With pip3, the name of the library is websocket-client
from websocket import create_connection
from distutils import spawn
import subprocess

path_to_msceditor = spawn.find_executable ("msceditor")

if not path_to_msceditor:
    print("[ERROR] msceditor not in the PATH")
    sys.exit(1)

# Open a new window of the MSC Editor
editor = subprocess.Popen ([path_to_msceditor, "-p", "5116"])

# Prepare a command to the MSC Editor
cmd = '{"CommandType": "Instance", "Parameters": {"name": "InstanceA"}}'

# Give some time for the MSC Editor process to open the socket
time.sleep(0.5)

# Establish a connection with the MSC Editor
ws = create_connection ("ws://localhost:5116/")

# Send the command
ws.send(cmd)

input ("Press enter to close")

# Close and kill everything
ws.close()
editor.kill()
