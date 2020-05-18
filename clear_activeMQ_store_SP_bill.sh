#!/bin/bash
#### Usage: $0 [host_name]...
#### Clear ActiveMQ Broker Store Space.
#### Example: $0 srwp01mqm002
#### Wiki: https://wiki.myweb.com/pages/viewpage.action?pageId=19826999

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function store_used()
{
  EXTRACTNUMBER='s/[^0-9]*\([0-9]*\).*/\1/'
  SOURCE=`/usr/bin/curl --user nocjmx:"$MQMQUEUE" "http://${SERVER}.myweb.com:8161/admin/index.jsp" 2>/dev/null`
  echo "$SOURCE" | grep -A1 "Store percent used" | sed -n 2p | sed -e "$EXTRACTNUMBER"
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1
#

MQMQUEUE=`sudo cat /nas/utl/NOC/Config/secure`
. /opt/splunkforwarder/etc/apps/myweb.sh `[ -n "$*" ] && echo "$*" || echo "mqm,act"` -f mqm,act
[ -z "$SERVERS" ] && echo "No valid hostname specified, quitting!" && exit 1

DATAFILE="/nas/utl/NOC/"`basename "$0" | sed -e "s/sh$/ctrl/"`
[ -f $DATAFILE ] && [ -r $DATAFILE ] && QTOPURGE=$(cat $DATAFILE 2>/dev/null)
QTOPURGE=$(echo "$QTOPURGE"; echo -e "DLQ\nesb" | sed -e 's/ //g' | grep -v '^$')
QTOPURGE=$(echo $QTOPURGE | sed -e 's/ /|/g')

echo "clear ActiveMQ broker store..."
for SERVER in $SERVERS; do
  echo "${SERVER}:"
  echo "Store percent used: `store_used` (before)"
  SOURCE=`/usr/bin/curl --user nocjmx:"$MQMQUEUE" "http://${SERVER}.myweb.com:8161/admin/queues.jsp" 2>/dev/null`
  SOURCE=$(echo "$SOURCE" | grep -v '^</a></td>$' | sed -e "s/^.*\.\.\. <span>//")
  for PURGELINK in `echo "$SOURCE" | grep "purgeDestination.action" | egrep $QTOPURGE | sed -e 's/^[^"]*"\([^"]*\)".*/\1/'`; do
    /usr/bin/curl --user nocjmx:"$MQMQUEUE" "http://${SERVER}.myweb.com:8161/admin/$PURGELINK" &>/dev/null
#
  done
##  sleep 2
  echo "Store percent used: `store_used` (now)"
done
