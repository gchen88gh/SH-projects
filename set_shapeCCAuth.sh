#!/bin/bash
#### Usage: $0 [true|false] byx_hosts...
#### Check/set property shape.auth.creditcard=true/false on Gen3-buy-services-webapp on specified byx blades.
#### Example: 1) $0 <cr>                       to print current property value on byx pool
####          2) $0 false lvsp01byx001 <cr>    to set property to false on lvsp01byx001

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function jmxMethod()
{
  local METHODNAME=$1
  [ -z "$METHODNAME" ] && return 1
  local MBEAN='Gen3-buy-services-webapp%3Aname%3DCentralizedMbean'
  local NUM=0 URL="http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=$MBEAN&methodName=$METHODNAME"
  shift
  while [ $# -gt 0 ]; do
    URL=$URL"&argType=java.lang.String&arg$NUM=$1"
    shift; NUM=$((NUM+1))
  done
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "$URL"
}

function getProperty()
{
  jmxMethod getProperty "$1" | grep -oE "true|false"
}

function setProperty()
{
  jmxMethod setProperty "$1" "$2" | grep -xq "OK"
}

function startOrStopJob() {
#
#

  [ -z "$2" ] && return 1
  echo "$1" | egrep -qxi 'start|stop' || return 1
  local ACTION=`echo $1 | tr A-Z a-z`
  jmxMethod ${ACTION}Job $2 | grep -q "OK"
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1
echo "$1" | grep -q "-" && usage && echo "\"${1}\": unknown option." && exit 1

ARGU1=`grep Usage $0 | grep -v sed | sed -e "s/^.*\[\(.*\)\] .*/\1/" | tr '|' '\n'`
[ -n "$1" ] && echo "$ARGU1" | (! grep -qxi "$1") && usage && echo "\"$1\" is not a valid argument, quit." && exit 1

AUTO=off # on, or anything else: off
#
#
#

SETTO=$1;
ALLHOSTS=$(~gchen1/scripts/get_hosts.sh 0.byx)
shift; SERVERS=$(~gchen1/scripts/get_hosts.sh $@ -f byx)
#
#
#
#

authenticationTest

#
#
#
#
#
#

echo "Check/set SHAPE CC Auth..."
for SERVER in $ALLHOSTS; do
  ! isJmxUp $SERVER && echo "$SERVER: jmx-console unavailable" && continue
  echo -n "$SERVER: shape.auth.creditcard = [`getProperty 'shape.auth.creditcard'`]"
  [ -z $SETTO ] && echo && continue
  ! echo "$SERVERS" | grep -q "$SERVER" && echo && continue
  setProperty 'shape.auth.creditcard' $SETTO
  echo " --> [`getProperty 'shape.auth.creditcard'`]"
#
#
#
#
#
done
exit
