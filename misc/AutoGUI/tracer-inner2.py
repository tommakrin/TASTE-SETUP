#!/usr/bin/env python3
import os
import sys
import time
import subprocess
import socket
import re
import signal
from collections import defaultdict
from tracerCommon import RenderParameterFields

# This tracer does not use the tracerd daemon.


g_messageId = 0
g_bNoParams = True
g_pendingRIs = []
g_completeMessages = []
# list of messages per instances. messages are index references to g_completeMessages
g_instances = defaultdict(list)
# to store message declarations with their parameters:
g_messagesDecl = defaultdict(list)
# list of timers
g_timers = []

g_strMscFilename = "trace.msc"

def saveMSC():
    with open(g_strMscFilename, "w") as f:
        f.write('mscdocument automade;\n'
                '   language ASN.1;\n'
                '   data dataview-uniq.asn;\n\n')
        inst_x = 0
        instances_x = {}
        for k in g_instances.keys():
            # set the X position of the instance lines
            instances_x[k] = inst_x
            inst_x += 650

        # Declare all messages and type of their parameter(s)
        for msg, paramList in g_messagesDecl.items():
            params = (','.join(paramList)).replace('_', '-')
            if not params:
                f.write(f'   msg {msg};\n')
            else:
                f.write(f'   msg {msg} : ({params});\n')
        f.write('\n')

        f.write('    msc recorded;\n')

        for k, index_list in g_instances.items():
            if 'timer_manager' in k:
                continue

            f.write(f'   /* CIF INSTANCE ({instances_x[k]}, 35) (200, 70) (800, 800) */\n')
            f.write(f'   instance {k};\n')
            for idx in index_list:
                msg, fromId, toId, nb1, nb2 = g_completeMessages[idx]
                cif = 'MESSAGE'
                if toId in ('#set', '#reset'):
                    cif = 'TIMEOUT'
                    x1 = instances_x[fromId] + 100
                    y1 = nb1 * 90
                    x2 = 186
                    y2 = 39
                    first = 'starttimer' if toId == '#set' else 'stoptimer'
                    second = ''
                    who = ''
                elif fromId == '#timeout':
                    cif = 'TIMEOUT'
                    x1 = instances_x[toId] + 100
                    y1 = nb1 * 90
                    x2 = 76
                    y2 = 39
                    first = 'timeout'
                    second = ''
                    who = ''
                elif toId == k:
                    first = 'in'
                    second = 'from'
                    who = fromId
                    x2 = instances_x[k] + 100
                    y2 = nb2 * 90
                    if fromId != 'env':
                        x1 = instances_x[fromId] + 100
                        y1 = nb1 * 90
                    else:
                        x1 = -30
                        y1 = nb2 * 90
                else:
                    first = 'out'
                    second = 'to'
                    who = toId
                    x1 = instances_x[k] + 100
                    y1 = nb1 * 90
                    x2 = instances_x[toId] + 100
                    y2 = nb2 * 90

                f.write(f'      /* CIF {cif} ({x1}, {y1}) ({x2}, {y2}) */\n')
                f.write(f'      {first} {msg} {second} {who};\n')
            f.write('   endinstance;\n\n')
        f.write('   endmsc;\n')
        f.write('endmscdocument;\n')
        f.close()


def Message(kind, timestamp, message, messageData, sender, receiver):
    ''' Process a message
        messageData is a list of tuples (ASN.1 Type, FieldName Value).
        kind is "RI" or "PI"
    '''
    if not g_bNoParams:
        message = RenderParameterFields(message, ",".join(
                                             [tup[1] for tup in messageData]))
    global g_messageId

    if "timer_manager" not in receiver or kind != 'PI':
        g_messageId += 1

    if kind == "RI":
        g_pendingRIs.append((message, sender, receiver, g_messageId))
    elif kind == "PI":
        for each in g_pendingRIs:
            # find corresponding RI, and store the message with two ids:
            # the RI and PI numbers. This is needed to compute the coordinates
            # of the two ends of the arrow on the MSC
            msg, fromId, toId, msgNb = each
            if msg == message and toId == receiver:
                g_pendingRIs.remove(each)
                g_completeMessages.append(
                        (msg, fromId, toId, msgNb, g_messageId))
                # For each instance name, point to the message
                g_instances[fromId].append(len(g_completeMessages) - 1)
                g_instances[toId].append(len(g_completeMessages) - 1)
                break
        else:
            # no break, meaning no correspondig RI (-> cyclic)
            if "timer_manager" not in receiver:
                # (ignore the tick of the timer manager)
                g_completeMessages.append(
                        (message, "env", receiver, g_messageId, g_messageId))
                g_instances[receiver].append(len(g_completeMessages) - 1)
    elif kind == 'SET':
        g_completeMessages.append(
                (message, sender, '#set', g_messageId, g_messageId))
        g_instances[sender].append(len(g_completeMessages) - 1)
    elif kind == 'RESET':
        g_completeMessages.append(
                (message, sender, '#reset', g_messageId, g_messageId))
        g_instances[sender].append(len(g_completeMessages) - 1)
    elif kind == 'TIMEOUT':
        g_completeMessages.append(
                (message, '#timeout', receiver, g_messageId, g_messageId))
        g_instances[receiver].append(len(g_completeMessages) - 1)
    else:
        print(f"Tracer: ignoring unsupported event kind {kind}")


def main():
    if "-noParams" in sys.argv:
        global g_bNoParams
        g_bNoParams = True
        sys.argv.remove("-noParams")
    if len(sys.argv) != 2:
        print("Usage:", sys.argv[0], "[-noParams] <application>")
        sys.exit(1)

    os.putenv("TASTE_INNER_MSC", "1")
    os.putenv("ASSERT_IGNORE_GUI_ERRORS", "1")

    p = None
    try:
        p = subprocess.Popen(sys.argv[1], stdout=subprocess.PIPE)
        messageData = {}
        tasks = {}
        for line in iter(p.stdout.readline, ''):
            lline = line.decode('utf-8').strip()
            # print("WORKING ON:", lline)
            m = re.match('^INNERDATA: ([^:]*)::(.*)::(.*)$', lline)
            # group(1) = message name, (2) = param type (3) = 'fieldName value'
            if m:
                # Add type and value to the messageData
                # Type is used when storing the MSC to declare messages
                messageData.setdefault(m.group(1), []).append(
                                                (m.group(2), m.group(3)))
                # Update message declaration with ASN.1 type
                g_messagesDecl[m.group(1)].append(m.group(2))
            elif lline.startswith('INNER_RI: '):
                sender, receiver, ri, timestamp = lline[10:].split(',')
                #print sender, receiver, ri, timestamp
                if ri not in list(messageData.keys()):
                    # no parameters
                    messageData[ri] = []
                    # Update message declaration (no param)
                    if 'timer_manager' not in receiver:
                        # filter timer 'set' and 'reset' functions
                        g_messagesDecl[ri] = []
                if 'timer_manager' in receiver:
                    # update list of timers
                    if ri.startswith('reset_'):
                        preLen = len(f'reset_{sender}_')
                        kind = 'RESET'
                    elif ri.startswith('set_'):
                        preLen = len (f'set_{sender}_')
                        kind = 'SET'
                    nameRI = ri[preLen:]
                    if nameRI not in g_timers:
                        g_timers.append(nameRI)
                else:
                    kind = 'RI'
                    nameRI = ri
                Message(kind, timestamp, nameRI, messageData[ri],
                        sender, receiver)
                messageData[ri] = []
            elif lline.startswith('INNER_PI: '):
                # we can't detect timeout messages for now
                receiver, pi, timestamp = lline[10:].split(',')
                #print sender, receiver, ri, timestamp
                if pi not in list(messageData.keys()):
                    # no parameters
                    messageData[pi] = []
                    # Update message declaration (no param)
                    g_messagesDecl[pi] = []
                if pi in g_timers:
                    kind = 'TIMEOUT'
                else:
                    kind = 'PI'
                Message(kind, timestamp, pi, messageData[pi], 'env', receiver)
                messageData[pi] = []
            else:
                sys.stdout.write(lline)
                sys.stdout.write('\n')
                sys.stdout.flush()
    except KeyboardInterrupt:
        if p:
            print("Sending SIGUSR1 to", sys.argv[1]) # to save the VCD in POHIC
            p.send_signal(signal.SIGUSR1) 
            time.sleep(1)
            print("Sending SIGINT to", sys.argv[1])
            p.send_signal(signal.SIGINT)
            saveMSC()
    if p:
        p.wait()
    print("Clean shutdown")

if __name__ == "__main__":
    main()
