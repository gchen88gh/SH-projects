#!/bin/bash
#
#

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function create_link()
{
  for LINKNAME in Events; do
    echo creating push_$LINKNAME
#
    ln -sf $0 push_$LINKNAME.sh
  done
}

function republish()
{
  local FUNC=$1 SHEIDS=$2 # arg1=23 arg2=comma separated eids
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=ShDataPushApp%3Aname%3DShDataPushJmxBean&methodName=push$FUNC&argType=java.lang.String&arg0=$SHEIDS"
}

echo $0 | grep -q cat && create_link && exit 1

SERVER=$(~gchen1/scripts/get_jmx-console_status.sh 01cat | grep up | awk '{ print $1; }' | tail -1)
[ -z "$SERVER" ] && echo "no available usi, quitting." && exit 2

authenticationTest
#
ITYPE=$(basename $0 | cut -d_ -f2 | sed -e 's/.sh$//')

[ -f "$1" ] && UIDS=`cat "$1"` && shift
UIDS="$UIDS $@"
UIDS=$(echo "$UIDS" | tr -s ', \n\t' ' ')

echo "push$ITYPE on ${SERVER}.myweb.com..."
for SID in $UIDS; do
  echo -n "pushing $ITYPE ID=$SID, "
  ! echo $SID | egrep -q "^[0-9]+$" && echo "wrong id, skipped" && continue
  republish $ITYPE $SID | grep -q 'Number of events in queue = 1.' && echo "OK" || echo "err: please use jmx console to check"
done
