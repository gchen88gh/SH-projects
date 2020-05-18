#!/bin/bash
function getFARE()
{
  FARESTATE=`/usr/bin/curl http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor -d "action=inspectMBean&name=Stubhub-Properties-FraudPrevention%3Aname%3DStubHub+Properties" 2>/dev/null | grep -o "${FAREPROP}.........." | grep -o "\[.*\]" | tail -1`
#
}

function setFARE()
{
  /usr/bin/curl -s "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=Gen3-sh-ecomm-ears-fraudpreventionear%3Aname%3DCentralizedMbean&methodName=setProperty&argType=java.lang.String&arg0=${FAREPROP}&argType=java.lang.String&arg1=$1" | grep -q "OK"
#
}

FAREPROP='fraud.internal.riskscoringengine.flow.enabled'
HOSTS="srwp01rfi001 srwp01rfi002 srwp01rfi003 srwp01rfi004 srwp01rfi005 srwp01rfi006"
AUTO=off # on, or anything else: off
DATAFILE="/nas/utl/NOC/"`basename "$0" | sed -e "s/sh$/ctrl/"`
[ -f $DATAFILE ] && [ -r $DATAFILE ] && . $DATAFILE

echo "TABLE tblFareStateChk"
echo "START_SAMPLE_PERIOD"

for SERVER in $HOSTS; do
  getFARE
  [ "$FARESTATE" = "[true]" ] && continue
  WRONGSTATE="${WRONGSTATE}***${SERVER}: ${FARESTATE} (should be [true])\t"
  [ "$AUTO" != "on" ] && continue
  setFARE true
  WRONGSTATE="${WRONGSTATE}   auto turned back on [true]\t"
done
[ -z "$WRONGSTATE" ] && echo -e "MsgNum=0\nMsg.String=\"FARE feature are [true] on all rfi hosts\"\nEND_SAMPLE_PERIOD\nEND_TABLE" && exit 0
echo -e "MsgNum=1\nMsg.String=$WRONGSTATE\nEND_SAMPLE_PERIOD\nEND_TABLE"
exit 1
