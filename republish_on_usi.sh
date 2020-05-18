#!/bin/bash
#
#

####LINKNAME:TicketStats-15,Category-17,Grouping-18,Performer-19,Geography-20,Event-21,Venue-22,ActiveInventory-23,Inventory-101,Order-201,Payment-301,BuyerOrder-401


. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function create_link()
{
#
  for LINKNAME in $(echo "$LINKNAMES" | sed -e 's/-.*$//'); do
    echo creating repub_$LINKNAME
#
    ln -sf $0 repub_$LINKNAME.sh
  done
}

function republish()
{
  local SHEIDS=$1 # arg1=23 arg2=comma separated eids
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=search%3AApplication%3Dcdc%2CType%3DChangeDataCaptureMBean%2CName%3DchangeDataCaptureMBean&methodName=realTimeRepublish&argType=java.lang.String&arg0=&argType=java.lang.Integer&arg1=$LINKNUM&argType=java.lang.String&arg2=$SHEIDS"
}

LINKNAMES=$(grep '^####LINKNAME:' $0 | sed -e 's/^####LINKNAME://' | tr ',' '\n')
echo $0 | grep -q usi && create_link && exit 1

SERVER=$(~gchen1/scripts/get_jmx-console_status.sh $(getActivePod)usi | grep up | awk '{ print $1; }' | tail -1)
[ -z "$SERVER" ] && echo "no available usi, quitting." && exit 2

authenticationTest
#
ITYPE=$(basename $0 | cut -d_ -f2 | sed -e 's/.sh$//')
LINKNUM=$(echo "$LINKNAMES" | grep -w $ITYPE | cut -d- -f2)
#

[ -f "$1" ] && UIDS=`cat "$1"` && shift
UIDS="$UIDS $@"
UIDS=$(echo "$UIDS" | tr -s ', \n\t' ' ')

echo "realTimeRepublish on ${SERVER}.myweb.com..."
for SID in $UIDS; do
#
  echo -n "republishing $ITYPE ID=$SID, "
  ! echo $SID | egrep -q "^[0-9]+$" && echo "wrong id, skipped" && continue
  republish $SID | grep -q "see more information about real time republish job" && echo "OK" || echo "err: please use jmx console to check"
done
