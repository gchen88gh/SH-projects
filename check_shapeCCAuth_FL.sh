#!/bin/bash

CHKSCRIPT="/nas/utl/NOC/set_shapeCCAuth.sh"
CHKSTATUS=`$CHKSCRIPT`

AUTO=off # on, or anything else: off

DATAFILE="/nas/utl/NOC/"`basename "$0" | sed -e "s/sh$/ctrl/"`
[ -f $DATAFILE ] && [ -r $DATAFILE ] && . $DATAFILE

echo "TABLE tblccauthChk"
echo "START_SAMPLE_PERIOD"

ENDSTR=`echo -e "\nEND_SAMPLE_PERIOD\nEND_TABLE"`

[ `echo "$CHKSTATUS" | wc -l` -eq 1 ] && echo -e "MsgNum=3\nMsg.String=\"No available byx hosts, please check abi pool.\"$ENDSTR" && exit 2
TRUEHOSTS=`echo "$CHKSTATUS" | grep 'true' | sed -e "s/^\(.*\):.*$/\1/"`
TRUENUM=`echo "$CHKHOSTS" | grep -c true`

[ "$TRUENUM" -eq 0 ] && echo -e "MsgNum=0\nMsg.String=\"all good, no TRUE value was found.\"$ENDSTR" && exit 0
echo "MsgNum=1" && MSG="Property shape.auth.creditcard value was set to be [true] on host(s) $TRUEHOSTS. Please check with teams if this is intended. The value can be set via JMX console http://HOSTNAME.myweb.com/jmx-console/HtmlAdaptor?action=inspectMBean&name=Gen3-buy-services-webapp%3Aname%3DCentralizedMbean"
echo "$AUTO" | grep -iq "on" && MSG=$MSG" Auto Correct Mode is ON, corrective action has been performed.\t\t`$CHKSCRIPT false $TRUEHOSTS | tr '\n' '\t'`"
echo -e "Msg.String=\"$MSG\"$ENDSTR"
exit 1
