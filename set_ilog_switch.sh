#! /bin/bash
#### Usage: $0 [pri_hosts [on|off|true|false]]
#### Check and/or turn on/off FARE feature on specified pri hosts.
#### Example: 1) $0 <cr>                                to print FARE state of all pri hosts
####          2) $0 on pri <cr>                         to turn on FARE feature on all pri hosts
####          3) $0 false pri06 <cr>                    to turn off FARE on hosts in Canary
####          4) $0 on srwp01pri001 srwp01pri002 <cr>   to turn on FARE on srwp01pri001 & srwp01pri002
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

function getValue()
{
#
  /usr/bin/curl -s "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?$ACTIONSTR" | sed -ne '/<pre>/,/<\/pre>/p' | grep -v 'pre>'
}

function setValue()
{
  /usr/bin/curl -s http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor -d "$(echo $ACTIONSTR | sed -e "s/getV/setV/")&argType=java.lang.String&arg1=$1" | grep -qE "OK|Operation completed successfully without a return value"
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1
echo "$1" | grep -q "-" && usage && echo "\"${1}\": unknown option." && exit 1

ARGU2=`grep Usage $0 | grep -v sed | sed -e "s/^.* \[\(.*\)\]\].*/\1/" | tr '|' '\n'`
[ -n "$2" ] && echo "$ARGU2" | (! grep -qxi "$2") && usage && echo "\"$2\" is not a valid switch, quit." && exit 1

FAREPROP='gen3OrderServiceFeeEnabled'
ACTIONSTR='action=invokeOpByName&name=pricingDomain%3AApplication%3DpricingAIPApp%2CName%3DSHConfig&methodName=getValue&argType=java.lang.String&arg0=buyerCost.gen3OrderServiceFeeEnabled'
echo "$2" | egrep -qi "on|true" && SETTO='true'
echo "$2" | egrep -qi "off|false" && SETTO='false'

echo -e "Check/Set FARE feature...\c"
. ~gchen1/scripts/get_hosts.sh pri
RFISERVERS=$SERVERS
. ~gchen1/scripts/get_hosts.sh -f pri $1
[ -z "$SERVERS" ] && SERVERS=$RFISERVERS SETTO='' && echo "no pri host specified/available." || echo
[ -z "$SETTO" ] && RFISERVERS=$SERVERS

for SERVER in $RFISERVERS; do
  ! isJmxUp $SERVER && echo "$SERVER: jmx-console unavailable" && continue
  echo -n "${SERVER}: [`getValue`]"
  [ -z $SETTO ] && echo && continue
  ! echo "$SERVERS" | grep -q "$SERVER" && echo && continue
  setValue $SETTO
  echo " --> [`getValue`]"
done
