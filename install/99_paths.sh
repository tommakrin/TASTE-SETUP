#!/bin/bash
TMP=${TMP:-/tmp}

if [ -t 0 ] ; then
    COLORON="\e[1m\e[31m"
    COLOROFF="\e[0m"
else
    COLORON=""
    COLOROFF=""
fi
INFO="${COLORON}[INFO]${COLOROFF}"

echo $PATH | sed 's,:,\n,g' | sort -u > ${TMP}/oldPaths
bash -c '. ~/.bashrc.taste > /dev/null ; echo $PATH' | sed 's,:,\n,g' | sort -u > ${TMP}/newPaths

diff -u  ${TMP}/oldPaths ${TMP}/newPaths || {
    echo -e "${INFO} A new PATH folder was introduced in your ~/.bashrc.taste"
    echo -e "${INFO} Source it now with..."
    echo -e "${INFO} "
    echo -e "${INFO}     source ~/.bashrc.taste"
    echo -e "${INFO} "
    echo -e "${INFO} ...and make sure your ~/.bashrc is sourcing it as well."
    echo -e "${INFO} (if you are using the TASTE VM, this has already been done)."
}

RTEMS_TOOLS=$(grep opt/rtems ${TMP}/newPaths | wc -l)
if [ $RTEMS_TOOLS -ne 1 ] ; then
    echo -e "${INFO} =====================    WARNING     ======================="
    echo -e "${INFO} Your new PATH (check ~/.bashrc.taste) contains more than one"
    echo -e "${INFO} RTEMS toolchains:"
    grep opt/rtems ${TMP}/newPaths  | sed 's,^,\t,'
    echo -e "${INFO} Depending on the settings of your builds (target, BSP, etc),"
    echo -e "${INFO} this can cause hard to diagnose failures. We strongly advise"
    echo -e "${INFO} that only one RTEMS toolchain exists in your PATH; edit"
    echo -e "${INFO} your .bashrc.taste and comment out (prefix with '#')"
    echo -e "${INFO} all but one of the lines that update the PATH to add them in."
    echo -e "${INFO} =====================    WARNING     ======================="
fi

rm -f ${TMP}/oldPaths ${TMP}/newPaths
