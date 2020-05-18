#!/bin/bash
#

. ~gchen1/scripts/basic_func.sh &>/dev/null

function curlCall()
{
  local SEDSTR='s/\$1/'$1'/' RETSTR="$3"
  local URLOUT=$(echo "$2" | sed -e $SEDSTR)
#
  curl --user "$USER":"$PASSCODE" "$URLOUT" | egrep -q "$RETSTR"
}

function processURL()
{
  local URLIN=$(echo "$1"  | sed -e "s/&amp;/\&/g")
  echo "$URLIN" | grep -iq '^http' && URLOUT=$(echo $URLIN | sed -e 's/\(^[^\/]*..\)[^.]*\(.*$\)/\1$1\2/') && return
  echo "$URLIN" | grep -q 'invokeOp' && URLOUT='http://$1.myweb.com/jmx-console/HtmlAdaptor?action=invokeOp'$(echo "$URLIN" | sed -e 's/^.*invokeOp\(.*$\)/\1/') && return
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 2
[ $# -lt 2 ] && usage && exit 2

. ~gchen1/scripts/get_hosts.sh $1
[ -z "$SERVERS" ] && echo "No matched blade found to apply jmx call, quitting." && exit 1
#
authenticationTest

processURL $2
[ -z "$URLOUT" ] && echo "Invalid/unexpected URL specified, quitting." && exit 2
#

for SERVER in $SERVERS; do
  echo -n "${SERVER}: "
#
  curlCall $SERVER "$URLOUT" "$3" && echo 'Ok' || echo 'Pls chk'
#
done
