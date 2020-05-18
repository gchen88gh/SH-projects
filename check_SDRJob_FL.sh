#!/bin/bash

SDRSCRIPT="/nas/utl/NOC/set_SDRJob.sh"
SDRSTATUS=`$SDRSCRIPT`

AUTO=off # on, or anything else: off
SDRJOBHOST="srwp01abi001"

DATAFILE="/nas/utl/NOC/"`basename "$0" | sed -e "s/sh$/ctrl/"`
[ -f $DATAFILE ] && [ -r $DATAFILE ] && . $DATAFILE

echo "TABLE tblSDRJobChk"
echo "START_SAMPLE_PERIOD"

ENDSTR=`echo -e "\nEND_SAMPLE_PERIOD\nEND_TABLE"`

[ `echo "$SDRSTATUS" | wc -l` -eq 1 ] && echo -e "MsgNum=3\nMsg.String=\"No available abi hosts, please check abi pool.\"$ENDSTR" && exit 2
SDRHOSTS=`echo "$SDRSTATUS" | grep running | sed -e "s/^\(.*\):.*$/\1/"`
SDRNUM=`echo "$SDRHOSTS" | grep -c abi`

[ $SDRNUM -gt 1 ] && echo "MsgNum=2" && MSG="SDRJob is running on multiple hosts `echo $SDRHOSTS`. Only one SDR job is expected to be running, and only on designated host $SDRJOBHOST. Please check with teams and correct accordingly."
[ $SDRNUM -eq 1 ] && echo "$SDRHOSTS" | grep -q $SDRJOBHOST && echo -e "MsgNum=0\nMsg.String=\"SDRJob is running on designated host $SDRJOBHOST.\"$ENDSTR" && exit 0
[ $SDRNUM -eq 1 ] && ! echo "$SDRHOSTS" | grep -q $SDRJOBHOST && echo "MsgNum=1" && MSG="SDRJob is running on $SDRHOSTS which is different from the designated host $SDRJOBHOST. Please check with teams if this is intended and re-config the NOC script."
[ $SDRNUM -eq 0 ] && echo "MsgNum=3" && MSG="SDRJob is NOT running on any abi hosts. One and only one SDR job is expected to be running, on designated host $SDRJOBHOST."
echo "$AUTO" | grep -iq "on" && MSG=$MSG" Auto Correct Mode is ON, corrective action has been performed.\t\t`$SDRSCRIPT reset | egrep -v 'stopped --> stopped|running --> running|status...' | tr '\n' '\t'`"
echo -e "Msg.String=\"$MSG\"$ENDSTR"
exit 1
