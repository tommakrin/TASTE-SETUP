#!/usr/bin/env python3
import re

def SimplifyString(s):
    tmp = s
    output = ''
    while tmp != '':
        if len(tmp)<2:
            return s
        value = int(tmp[:2], 16)
        if value>127:
            return s
        output += chr(value)
        tmp = tmp[2:]
    return output


def ConvertToASCII(output):
    # If all characters are printable, create string representations for OCTET STRINGs
    finalOutput = ''
    while True:
        m = re.match(r"^(.*?)'([^']+)'H(.*?)$", output, re.DOTALL)
        if m:
            finalOutput += m.group(1) + "'"
            simplified = SimplifyString(m.group(2))
            if simplified != m.group(2):
                finalOutput += simplified + "'"
            else:
                finalOutput += simplified + "'H"
            output = m.group(3)
        else:
            finalOutput += output
            break
    return finalOutput


def RenderParameterFields(message, messageData):
    if '{' not in messageData:
        return message + ':' + ConvertToASCII(messageData)
    else:
        messageData = messageData.replace(', ', ',')
        indent = ''
        output = message + ':'
        for c in messageData:
            if c in ['{', ',']:
                output += c + '\n'
                if c == '{':
                    indent += 4*' '
                output += indent
            elif c in ['}']:
                try:
                    indent = indent[4:]
                except:
                    pass
                output += '\n' + indent + c
            else:
                output += c
    # Compress empty arrays (i.e. {\s+})
    while True:
        m = re.match(r'^(.*?){\s+}(.*?)$', output, re.DOTALL)
        if m:
            output = m.group(1) + '{}' + m.group(2)
        else:
            break
    return ConvertToASCII(output)

if __name__ == "__main__":
    # print RenderParameterFields("router_put_tc", "{intVal 0, int2Val 0, int3Val 0, intArray {0,0,0,0,0,0,0,0,0,0}, realArray {0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000}, octStrArray {'616263'H,'62'H,''H,''H,''H,''H,''H,''H,''H,''H}, boolArray {FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE}, enumArray {green,green,green,green,green,green,green,green,green,green}, enumValue green, enumValue2 truism, label ''H, bAlpha FALSE, bBeta FALSE, sString ''H, arr {}, arr2 {}}")
    print(RenderParameterFields("router_put_tc", "tm: '616263'H"))
