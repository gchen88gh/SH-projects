#!/bin/bash
#### Usage: $0 [host_name]...
#### Clear ActiveMQ Broker Store Space.
#### Example: $0 srwp01mqm002
#### Wiki: https://wiki.myweb.com/pages/viewpage.action?pageId=19826999

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function getQnum()
{
  echo "$QUEUEPAGE" | grep -A$(($2-1)) "^$1" | sed -n $2p | sed 's/[^0-9]*\([0-9]*\).*/\1/'
}

function getRole()
{
  local HOST SOURCE=''
#
  for HOST in `~gchen1/scripts/get_hosts.sh ${SERVER:4:5}`; do
#
    SOURCE=$(echo -e "$SOURCE\ngchen1-$HOST\n""$(/usr/bin/curl -s --user "$USER":"$PASSCODE" "http://$HOST.myweb.com:8161/admin/queueConsumers.jsp?JMSDestination=$QUEUENAME")")
  done
  ROLES=$(echo "$SOURCE" | grep ID: | grep -v href= | sed -e "s/^.*ID:....\(..\)\(...\).*$/\2\1/" | sort -u)
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1
authenticationTest
#
. ~gchen1/scripts/get_hosts.sh `[ -n "$*" ] && echo "$*" || echo "mqm,act"` -f mqm,act
[ -z "$SERVERS" ] && echo "No valid hostname specified, quitting!" && exit 1

#
echo "check/list queue with no consumer..."
for SERVER in $SERVERS; do
#
  QUEUEPAGE=$(/usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com:8161/admin/queues.jsp")
  QUEUEPAGE=$(echo "$QUEUEPAGE" | grep -v '^</a></td>$' | sed -e "s/^.*\.\.\. <span>//")
#
#
#
#
#
#
  QUEUENAMES=$(echo "$QUEUEPAGE" | egrep -A2 "^[^ <	]" | tr -d '\n' | sed -e "s/--/\n/g" | sed -e "s/<[^0-9]*/!/g" | grep '!0!$' | grep -v '!0!.')
#
QUEUENAME=autobulk.ship.file.processing.cmd.queue
QUEUENAME=autobulk.file.validate.cmd.queue
QUEUENAME=autobulk.ship.file.reporting.cmd.queue
#
#
  for QUEUENAME in $QUEUENAMES; do
#
#
#
#
#
    MESSAGES=$(echo $QUEUENAME | cut -d! -f2)
    CONSUMERS=$(echo $QUEUENAME | cut -d! -f3)
    QUEUENAME=$(echo $QUEUENAME | cut -d! -f1)
#
#
#
    getRole
#
#
#
    [ -z "$ROLES" ] && ACTION="report to SWAT" || ACTION=$(echo "slow roll "$ROLES)
    echo $SERVER - $QUEUENAME {Messages:$MESSAGES} - action: $ACTION
  done
#

#
#
#
#
#
##  sleep 2
#
done
