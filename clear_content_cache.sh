#!/bin/bash
#
#
#

[ $# -eq 1 ] && ([ "$1" == /? ] || [ "$1" == Usage ] || [ "$1" == usage ]) && echo "Script Usage: `basename $0` pool_name(eg. byx)" && exit
[ $# -eq 0 ] && echo "Script Usage: `basename $0` pool_name(eg. byx)" && exit

function clearCache-G3()
{
  /usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=$PRE$NAME%3Aname%3DGen3+CacheManager&methodIndex=$INDX" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

function clearCache-G2()
{
  /usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=$PRE$NAME%3Aservice%3DrequestChainServletMonitor&methodIndex=$INDX" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

##! grep -q "^$1_NAMES" $0 && echo "Clearing cache on $1 is not supported, quitting." && exit 2

#
#
##SERVERS=`/nas/utl/NOC/lhosts.sh "$1"`
. ~gchen1/scripts/get_hosts.sh "$@"

SUPPORTED=`grep '^..._NAMES=' $0 | sed -e "s/^\([^_]*\).*$/\1/"`
SUPPORTED=`echo $SUPPORTED | sed -e 's/ /|/g'`
[ -n "$SERVERS" ] && UNSUPPORTED=`echo "$SERVERS" | egrep -v "$SUPPORTED" | sed -e "s/^[a-z]*[0-9]*\([a-z]*\).*/\1 is not supported/" | sort -u`
[ -n "$UNSUPPORTED" ] && echo "$UNSUPPORTED"
SERVERS=`echo "$SERVERS" | egrep "$SUPPORTED"`
[ -z "$SERVERS" ] && echo "no supported blade to clear cache on, quitting." && exit 1

brx_NAMES="Codes-StubhubBRXRole Codes-EventApp"
byx_NAMES="Codes-CheckoutApp"
edl_NAMES="Codes-Confirm"
mci_NAMES="Codes-MultipleCatalogInternal"
#
myx_NAMES="Codes-StubhubMYXRole Codes-preferenceAPI"
sli_NAMES="Codes-SellListener"
slx_NAMES="Codes-StubhubSLXRole UploadApp"
job_NAMES="Codes-StubhubJobs"
stj_NAMES="Codes-CSToolApp Codes-SecureCSToolApp"

#
brs_NAMES="content"
buy_NAMES="content"

##eval NAMES='$'$1_NAMES

for SERVER in $SERVERS; do
  echo -n "clearing cache on ${SERVER}..."
  STATUS=""
  ROLE=${SERVER:6:3}
  if [ "$ROLE" = "brs" ] || [ "$ROLE" = "buy" ]
    then 
      clearCache="clearCache-G2"
      PRE="com.myweb.framework."
      INDX=2
    else 
      clearCache="clearCache-G3"
      PRE="Gen3-"
      INDX=6
  fi
  eval NAMES='$'${ROLE}_NAMES
  for NAME in $NAMES; do
    $clearCache $SERVER $NAME $INDX || $clearCache $SERVER.myweb.com $NAME $INDX || STATUS=`echo "$STATUS $PRE$NAME"`
    sleep 5
  done
  [ -z "$STATUS" ] && echo "done" || echo "problem:$STATUS"
done
