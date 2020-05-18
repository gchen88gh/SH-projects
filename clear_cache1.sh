#!/bin/bash
#
#

function clearCache()
{
  /usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=$PRE$NAME%3Aservice%3DrequestChainServletMonitor&methodIndex=$INDX" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

! grep -q "$1_NAMES" $0 && echo "Clearing cache on $1 is not supported, quitting." && exit 2
#! grep -q "$1_NAMES" $0 && /nas/home/gchen1/scripts/clear_cache1.sh "$1" "$2" && exit 2
. ~gchen1/scripts/get_Green_Blade.sh "$1" "$2"
[ -z "$LIST" ] && echo "no available blade to clear cache on, quitting." && exit 1
buy_NAMES="content"
#
brs_NAMES="content"
#

PRE="com.myweb.framework."
INDX=2 # clear all cache

eval NAMES='$'$1_NAMES

for SERVER in $LIST; do
  echo -n "clearing cache on ${SERVER}..."
  STATUS=""
  for NAME in $NAMES; do
    clearCache $SERVER $NAME $INDX || clearCache $SERVER.myweb.com $NAME $INDX || STATUS=`echo "$STATUS $PRE$NAME"`
    sleep 5
  done
  [ -z "$STATUS" ] && echo "done" || echo "problem:$STATUS"
done
