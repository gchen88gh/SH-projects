#!/bin/bash
#### Usage: $0 [start|stop|reset] abi_hosts...
#### Check and/or start/stop SDR job on specified abi blades.
#### Example: 1) $0 <cr>                       to print SDR job status on abi pool
####          2) $0 start srwp01abi001 <cr>    to start SDR job on srwp01abi001
####          3) $0 reset srwp01abi001 <cr>    to reset SDR job on srwp01abi001

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function jmxMethod()
{
  local METHODNAME=$1 ARGU=$2
  [ -z "$METHODNAME" ] && return 1
  local MBEAN='Gen3-sh-ecomm-ears-abiprocessear%3Aname%3DCentralizedMbean'
  local COMMON_PART=".myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=$MBEAN&argType=java.lang.String"
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}${COMMON_PART}&methodName=$METHODNAME&arg0=$ARGU"
}

function isJobRunning()
{
  # getJobStatus arg0 jobname, ex: SDRJob
  jmxMethod getJobStatus "$1" | grep -q "Running"
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
SDRJOBHOSTS=$(~gchen1/scripts/get_hosts.sh abi001)
DATAFILE=`ls /nas/utl/NOC/*SDR*.ctrl`
[ -f $DATAFILE ] && [ -r $DATAFILE ] && . $DATAFILE

SDRJOBHOSTS=$(~gchen1/scripts/get_hosts.sh "$SDRJOBHOSTS" -f abi)
RTAPOD=$(getActivePod)
SDRJOBHOST=$(~gchen1/scripts/get_hosts.sh "$SDRJOBHOSTS" -f "$RTAPOD")
[ $(echo "$SDRJOBHOSTS" | grep -c abi) -eq 1 ] && SDRJOBHOST=$SDRJOBHOSTS && RTAPOD=${SDRJOBHOSTS:3:3}
[ "$RTAPOD" = "$ACTIVEPOD" ] || sudo sed -i.bak -e "s/^SDRJOBHOST=.*$/SDRJOBHOST=$SDRJOBHOST/;s/^ACTIVEPOD=.*/ACTIVEPOD=$RTAPOD/" $DATAFILE

authenticationTest

#
. ~gchen1/scripts/get_hosts.sh `echo "$SDRJOBHOSTS" | sed -e 's/...\(p[0-9][0-9]abi\).../\1/g'`
ABISERVERS=$SERVERS
CMLSETTO="$1"
shift
#
. ~gchen1/scripts/get_hosts.sh -f abi $@
echo $CMLSETTO | grep -iq reset && [ -z "$SERVERS" ] && SERVERS=$ABISERVERS

echo "Check/set SDR job status..."
for SERVER in $ABISERVERS; do
#
  ! isJmxUp $SERVER && echo "$SERVER: jmx-console unavailable" && continue

  echo -n "$SERVER: `isJobRunning SDRJob && echo "running" || echo "stopped"`"
  echo "$SERVERS" | grep -q $SERVER || eval "echo && continue"
  SETTO=$CMLSETTO
  echo $CMLSETTO | grep -iq reset && SETTO="stop" && [ $SDRJOBHOST = $SERVER ] && SETTO="start"
  startOrStopJob $SETTO SDRJob
#
  echo " --> `isJobRunning SDRJob && echo "running" || echo "stopped"`"
done
exit
