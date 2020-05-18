#! /bin/bash
#### Usage: $0 [rfi_hosts [on|off|true|false]]
#### Check and/or turn on/off FARE feature on specified rfi hosts.
#### Example: 1) $0 <cr>                                to print FARE state of all rfi hosts
####          2) $0 rfi on <cr>                         to turn on FARE feature on all rfi hosts
####          3) $0 rfi06 false <cr>                    to turn off FARE on hosts in Canary
####          4) $0 srwp01rfi001,srwp01rfi002 on <cr>   to turn on FARE on srwp01rfi001 & srwp01rfi002
#### Wiki: https://wiki.myweb.com/pages/viewpage.action?pageId=20350775

#
#

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function isJmxUp()
{
  # version w/o authentication
  /usr/bin/curl http://$1/jmx-console/ 2>/dev/null | grep -iq "$1"
#
}

function getFARE()
{
#
  /usr/bin/curl -s "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=Gen3-sh-ecomm-ears-fraudpreventionear%3Aname%3DCentralizedMbean&methodName=getProperty&argType=java.lang.String&arg0=${FAREPROP}" | grep -oE "true|false"
}

function setFARE()
{
  /usr/bin/curl -s "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=Gen3-sh-ecomm-ears-fraudpreventionear%3Aname%3DCentralizedMbean&methodName=setProperty&argType=java.lang.String&arg0=${FAREPROP}&argType=java.lang.String&arg1=$1" | grep -q "OK"
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1
echo "$1" | grep -q "-" && usage && echo "\"${1}\": unknown option." && exit 1

ARGU2=`grep Usage $0 | grep -v sed | sed -e "s/^.* \[\(.*\)\]\].*/\1/" | tr '|' '\n'`
[ -n "$2" ] && echo "$ARGU2" | (! grep -qxi "$2") && usage && echo "\"$2\" is not a valid switch, quit." && exit 1

FAREPROP='fraud.internal.riskscoringengine.flow.enabled'
echo "$2" | egrep -qi "on|true" && SETTO='true'
echo "$2" | egrep -qi "off|false" && SETTO='false'

echo -e "Check/Set FARE feature...\c"
. ~gchen1/scripts/get_hosts.sh rfi
RFISERVERS=$SERVERS
. ~gchen1/scripts/get_hosts.sh -f rfi $1
[ -z "$SERVERS" ] && SERVERS=$RFISERVERS SETTO='' && echo "no rfi host specified/available." || echo
[ -z "$SETTO" ] && RFISERVERS=$SERVERS

for SERVER in $RFISERVERS; do
  ! isJmxUp $SERVER && echo "$SERVER: jmx-console unavailable" && continue
  echo -n "${SERVER}: [`getFARE`]"
  [ -z $SETTO ] && echo && continue
  ! echo "$SERVERS" | grep -q "$SERVER" && echo && continue
  setFARE $SETTO
  echo " --> [`getFARE`]"
done
