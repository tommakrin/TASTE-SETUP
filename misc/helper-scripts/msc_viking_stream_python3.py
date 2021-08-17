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

path_to_msceditor = spawn.find_executable ("spacecreator.AppImage")

if not path_to_msceditor:
    print("[ERROR] msceditor not in the PATH")
    sys.exit(1)

# Open a new window of the MSC Editor
editor = subprocess.Popen ([path_to_msceditor, "--mscstreaming", "-p", "5116"])

# Prepare a command to the MSC Editor
cmds = ['{"CommandType": "Instance", "Parameters": {"name": "InstanceA"}}',
       '{"CommandType": "Instance", "Parameters": {"name": "InstanceB"}}',
       '{"CommandType": "Condition","Parameters": {"name": "StateBlah", "instanceName": "InstanceA", "shared": "true"}}',
        '{"CommandType": "Action", "Parameters": {"name": "Welcome to TASTE", "instanceName": "InstanceA"}}',
        '{"CommandType": "Save", "Parameters": {"fileName": "helloWorld.msc", "asn1File": "DataView.asn"}}']

# These are the possible commands:
#{"CommandType": "VisibleItemLimit", "Parameters": {"number": "10"}}
#{"CommandType": "Instance", "Parameters": {"name": "Instance_A"}}
#{"CommandType": "Message", "Parameters": {"name": "Message_A-B","srcName": "Instance_A","dstName": "Instance_B"}}
#{"CommandType": "Timer", "Parameters": {"name": "Timer_A_1","instanceName": "Instance_A","TimerType": "Start"}}
# TimerType can then be "Stop" and "Timeout"
#{"CommandType": "Condition","Parameters": {"name": "Condition_1", "instanceName": "Instance_B", "shared": "true"}}
#{"CommandType": "Action", "Parameters": {"name": "SomeAction", "instanceName": "InstanceA"}}
#{"CommandType": "Message","Parameters": {"name": "Message_C-dynamic", "srcName": "Instance_C","dstName": "Instance_dynamic", "MessageType": "Create"}}
#{"CommandType": "StopInstance", "Parameters": {"name": "Instance_dynamic_2"}}
#{"CommandType": "Undo"}
#{"CommandType": "Redo"}
#{"CommandType": "Save", "Parameters": {"fileName": "helloWorld.msc", "asn1File": "dataview-uniq.asn"}}

# Give some time for the MSC Editor process to open the socket
time.sleep(0.5)

# Establish a connection with the MSC Editor
ws = create_connection ("ws://localhost:5116/")

# Send the commands
for cmd in cmds:
    ws.send(cmd)

input ("Press enter to close")

# Close and kill everything
ws.close()
editor.kill()
