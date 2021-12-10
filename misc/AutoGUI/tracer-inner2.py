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
# current state of SDL functions
g_currentState = defaultdict(str)

# filters
g_instanceFilters = set()
g_messageFilters = defaultdict(list) # {instance: [pi names]}
g_timestampFilters = defaultdict(list) # {instance : [pi names]}

g_strMscFilename = "trace.msc"

# Offset for placing messages, increase when there is a timer
Y_OFFSET = 100

# vertical distance betwwen two events in the MSC
INTERDIST = 90

def saveMSC():
    global Y_OFFSET
    with open(g_strMscFilename, "w") as f:
        # Add 2 mscdocuments (and and leaf), needed for the end-to-end view in space creator
        f.write('mscdocument taste_recorded /* MSC AND */;\n'
                '   language ASN.1;\n'
                '   data dataview-uniq.asn;\n\n')
        f.write(f'/* CIF MSCDOCUMENT (0, 0) ({len(list(g_instances))*700+300}, {len(list(g_completeMessages))*45}) */\n' )
        f.write('mscdocument automade;\n')
        inst_x = 500
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
            if 'timer_manager' in k or k.lower() in g_instanceFilters:
                continue

            f.write(f'   /* CIF INSTANCE ({instances_x[k]}, 35) (200, 70) (800, 800) */\n')
            f.write(f'   instance {k};\n')

            content = {}
            for idx in index_list:
                # Compute the full CIF coordinates of each event and generate
                # the event string. However do not emit immediately in the file
                # because some ordering based on the y position will be needed
                # first.
                # depending of the event (PI, RI, timer, condition) the y value
                # that is used for the ordering can be the one of the event
                # start or end. We put the vaue we need in "y_sort"
                y_sort = 0

                msg, fromId, toId, nb1, nb2, timestamp = g_completeMessages[idx]
                cif = 'MESSAGE'
                comment = ''
                if toId == '#reset' or toId.startswith('#set'):
                    cif = 'TIMEOUT'
                    x1 = instances_x[fromId] + 100
                    #Y_OFFSET += 50
                    y_sort = y1 = (nb1 * INTERDIST) + Y_OFFSET
                    x2 = 186
                    y2 = 39
                    first = 'starttimer' if toId.startswith('#set') else 'stoptimer'
                    second = ''
                    who = ''
                    if toId.startswith('#set'):
                        # Add the timer value in a comment box
                        comment=f"\n/* CIF COMMENT ({x1+115}, {y1+75}) (220, 65) */\ncomment '{toId.split()[1]} ms'"
                elif fromId == '#timeout':
                    cif = 'TIMEOUT'
                    x1 = instances_x[toId] + 100
                    #Y_OFFSET += 50
                    y_sort = y1 = (nb1 * INTERDIST) + Y_OFFSET
                    x2 = 76
                    y2 = 39
                    first = 'timeout'
                    second = ''
                    who = ''
                elif toId.startswith('#state'):
                    stateVal = toId.split()[1]
                    cif = 'CONDITION'
                    x1 = instances_x[fromId]
                    #Y_OFFSET += 40
                    y_sort = y1 = (nb1 * INTERDIST) + Y_OFFSET
                    x2 = 200
                    y2 = 35
                    first = 'condition'
                    msg = stateVal.replace('_0_', '.').title()
                    second = ''
                    who = ''
                elif toId == k:
                    first = 'in'
                    second = 'from'
                    who = fromId
                    x2 = instances_x[k] + 100
                    y_sort = y2 = (nb2 * INTERDIST) + Y_OFFSET
                    if fromId != 'env':
                        x1 = instances_x[fromId] + 100
                        y1 = (nb1 * INTERDIST) + Y_OFFSET
                        if nb2 == nb1 + 1:
                            # if execution is immediately after sending,
                            # use a straight line to save space on the diagram
                            y_sort = y2 = y1
                    else:
                        x1 = -30
                        y1 = (nb2 * INTERDIST) + Y_OFFSET
                    if k.lower() in list(g_timestampFilters.keys()) \
                            and msg in g_timestampFilters[k.lower()]:
                        # Add timestamp for this message
                        comment=f"\n/* CIF COMMENT ({x2+100}, {y2-35}) (328, 70) */\ncomment 'at {timestamp} ms'"
                else:
                    first = 'out'
                    second = 'to'
                    who = toId
                    x1 = instances_x[k] + 100
                    y_sort = y1 = (nb1 * INTERDIST) + Y_OFFSET
                    x2 = instances_x[toId] + 100
                    if nb2 == nb1 + 1:
                        y2 = y1
                    else:
                        y2 = (nb2 * INTERDIST) + Y_OFFSET
                content[y_sort] = [
                     f'      /* CIF {cif} ({x1}, {y1}) ({x2}, {y2}) */\n',
                     f'      {first} {msg} {second} {who}{comment};\n']
            # sort the elements based on y position
            for cif, event in dict(sorted(content.items())).values():
                f.write(cif)
                f.write(event)
            f.write('   endinstance;\n\n')
        f.write('   endmsc;\n')
        f.write('endmscdocument;\n')
        f.write('endmscdocument;\n')
        f.close()


def Message(kind, timestamp, message, messageData, sender, receiver):
    ''' Process a message
        messageData is a list of tuples (ASN.1 Type, FieldName Value).
        kind is "RI" or "PI"
    '''
    #messageWithParams = RenderParameterFields(message, ",".join(
    #                                         [tup[1] for tup in messageData]))
    #if not g_bNoParams:
    #    message = messageWithParams
    #print(messageWithParams)

    global g_messageId

    if sender.lower() in g_instanceFilters or receiver.lower() in g_instanceFilters:
        # if the message is linked to a filtered instance, ignore it
        return

    if "timer_manager" not in receiver or kind != 'PI':
        g_messageId += 1

    if kind == "RI":
        if receiver.lower() in list(g_messageFilters.keys()) and \
                message.lower() in g_messageFilters[receiver.lower()]:
            # is the message filtered for the receiving instance?
            g_messageId -= 1
        else:
            g_pendingRIs.append((message, sender, receiver, g_messageId))
    elif kind == "PI":
        filtered = False
        if receiver.lower() in list(g_messageFilters.keys()) and \
                message.lower() in g_messageFilters[receiver.lower()]:
            # if message is filtered, we wont add it to g_instances
            filtered = True
            g_messageId -= 1
        for each in g_pendingRIs:
            # find corresponding RI, and store the message with two ids:
            # the RI and PI numbers. This is needed to compute the coordinates
            # of the two ends of the arrow on the MSC
            msg, fromId, toId, msgNb = each
            if msg == message and toId == receiver:
                g_pendingRIs.remove(each)
                if not filtered:
                    g_completeMessages.append(
                            (msg, fromId, toId, msgNb, g_messageId, timestamp))
                    # For each instance name, point to the message
                    g_instances[fromId].append(len(g_completeMessages) - 1)
                    g_instances[toId].append(len(g_completeMessages) - 1)
                break
        else:
            # no break, meaning no correspondig RI (-> cyclic)
            if "timer_manager" not in receiver and not filtered:
                # (ignore the tick of the timer manager)
                g_completeMessages.append(
                        (message, "env", receiver, g_messageId, g_messageId, timestamp))
                g_instances[receiver].append(len(g_completeMessages) - 1)
    elif kind == 'SET':
        # get the value of the timer
        try:
            _, val = messageData[0]
        except IndexError:
            print(f'[?] Parsing error: {messageData}, please report this line if it happens again')
        timerValueInMs = val.split()[1]
        g_completeMessages.append(
                (message, sender, f'#set {timerValueInMs}', g_messageId, g_messageId, timestamp))
        g_instances[sender].append(len(g_completeMessages) - 1)
    elif kind == 'RESET':
        g_completeMessages.append(
                (message, sender, '#reset', g_messageId, g_messageId, timestamp))
        g_instances[sender].append(len(g_completeMessages) - 1)
    elif kind == 'TIMEOUT':
        g_completeMessages.append(
                (message, '#timeout', receiver, g_messageId, g_messageId, timestamp))
        g_instances[receiver].append(len(g_completeMessages) - 1)
    elif kind == 'STATE':
        # when SDL state has changed
        g_completeMessages.append(
                (message, message, f'#state {messageData}', g_messageId, g_messageId, timestamp))
        g_instances[sender].append(len(g_completeMessages) - 1)
    else:
        print(f"[-] Tracer: ignoring unsupported event kind {kind}")


def loadFilters():
    ''' User can provide an optional file named "filters" and listing
        the signals names that shall be filtered from the MSC
        format of the file: one filter per line
        one line is either:
        input <name> to <function name>
        or
        instance <function name>
    '''
    with open('filters', 'r') as f:
        for line in f:
            if not line or line.startswith('#') or line.startswith('--'):
                continue
            elems = line.split()
            if not elems:
                continue
            if elems[0] == 'instance':
                g_instanceFilters.add(elems[1].lower())
                print(f'[-] Filtering instance {elems[1]}')
            elif elems[0] == 'input' and len(elems) == 4 and elems[2] == 'to':
                g_messageFilters[elems[3].lower()].append(elems[1].lower())
                print(f'[-] Filtering message {elems[1]} sent to instance {elems[3]}')
            elif elems[0] == 'timestamp' and elems[1] == 'input' and len(elems) == 5 and elems[3] == 'to':
                g_timestampFilters[elems[4].lower()].append(elems[2].lower())
                print(f'[-] Adding execution timestamps when message {elems[2]} is executed by function {elems[4]}')
            else:
                print('[X] Incorrect syntax: ', line)


def main():
    if "-noParams" in sys.argv:
        global g_bNoParams
        g_bNoParams = True
        sys.argv.remove("-noParams")
    if len(sys.argv) != 2:
        print("[-] Usage:", sys.argv[0], "[-noParams] <application>")
        print('[-] You can filter messages and instances by creating a file '
              ' named "filters" containing a sequence of lines with syntax:')
        print('     # filter out complete instance:')
        print('     instance functionName')
        print('     -- filter individual messages to an instance')
        print('     input PIname to functionName')
        print('     -- Add timestamp to a specific message')
        print('     timestamp input PIname to functionName')
        sys.exit(1)

    os.putenv("TASTE_INNER_MSC", "1")
    os.putenv("ASSERT_IGNORE_GUI_ERRORS", "1")

    p = None

    try:
        loadFilters()
        print('[-] Loaded filters')
    except IOError:
        print('[-] No filters file found')
        pass

    try:
        p = subprocess.Popen(sys.argv[1], stdout=subprocess.PIPE)
        messageData = {}
        tasks = {}
        for line in iter(p.stdout.readline, ''):
            if p.poll() is not None :
                print ("[-] Application was stopped")
                print ("[-] Generating MSC")
                saveMSC()
                break
            lline = line.decode('utf-8').strip()
            #if "tick" not in lline:
            #    print("WORKING ON:", lline)
            m = re.match('^INNERDATA: ([^:]*)::(.*)::(.*)$', lline)
            # group(1) = message name, (2) = param type (3) = 'fieldName value'
            if m:
                # Add type and value to the messageData
                # Type is used when storing the MSC to declare messages
                messageData.setdefault(m.group(1), []).append(
                                                (m.group(2), m.group(3)))
            elif lline.startswith('INNER_RI: '):
                sender, receiver, senderRI, remoteRI, timestamp = lline[10:].split(',')
                if senderRI in list(messageData.keys()):
                    # Has parameters -> update message declaration with ASN.1 types
                    # not robust to 2 messages with the same name and different signatures
                    # but this not supported by msc anyway
                    if senderRI not in list(g_messagesDecl.keys()) and 'timer_manager' not in receiver:
                        # do it only once
                        for (sort, _) in messageData[senderRI]:
                            g_messagesDecl[senderRI].append(sort)
                else:
                    # no parameters
                    messageData[senderRI] = []
                    # Update message declaration (no param)
                    if 'timer_manager' not in receiver:
                        # filter timer 'set' and 'reset' functions
                        g_messagesDecl[senderRI] = []
                if 'timer_manager' in receiver:
                    # update list of timers
                    if senderRI.startswith('reset_'):
                        preLen = len(f'reset_{sender}_')
                        kind = 'RESET'
                    elif senderRI.startswith('set_'):
                        preLen = len (f'set_{sender}_')
                        kind = 'SET'
                    nameRI = remoteRI[preLen:]
                    if nameRI not in g_timers:
                        g_timers.append(nameRI)
                else:
                    kind = 'RI'
                    nameRI = remoteRI
                Message(kind, timestamp, nameRI, messageData[senderRI],
                        sender, receiver)
                messageData[senderRI] = []
            elif lline.startswith('INNER_PI: '):
                receiver, pi, timestamp = lline[10:].split(',')
                #print sender, receiver, ri, timestamp
                if pi not in list(messageData.keys()):
                    # no parameters
                    messageData[pi] = []
                    # Update message declaration (no param)
                    if pi not in g_timers:
                        g_messagesDecl[pi] = []
                if pi in g_timers:
                    kind = 'TIMEOUT'
                else:
                    kind = 'PI'
                Message(kind, timestamp, pi, messageData[pi], 'env', receiver)
                messageData[pi] = []
            elif lline.startswith('INNER_SDL_STATE: '):
                fctName, stateValue = lline[17:].split(',')
                stateValue = stateValue[7:]  # remove asn1scc prefix
                if stateValue != g_currentState[fctName]:
                    g_currentState[fctName] = stateValue
                    Message('STATE', 0, fctName, stateValue, fctName, fctName)
            else:
                sys.stdout.write(lline)
                sys.stdout.write('\n')
                sys.stdout.flush()
    except KeyboardInterrupt:
        if p:
            print("[-] Sending SIGUSR1 to", sys.argv[1]) # to save the VCD in POHIC
            p.send_signal(signal.SIGUSR1) 
            time.sleep(1)
            print("[-] Sending SIGINT to", sys.argv[1])
            p.send_signal(signal.SIGINT)
            print ("[-] Generating MSC")
            saveMSC()
    if p:
        p.wait()
    print("[-] Clean shutdown")

if __name__ == "__main__":
    main()
