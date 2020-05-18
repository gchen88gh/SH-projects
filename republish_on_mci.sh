#!/bin/bash
#
#

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function create_link()
{
  for LINKNAME in Seller_Listing Seller_Order Seller_Payment Buyer_Order; do
    echo creating repub_$LINKNAME
#
    ln -sf $0 repub_$LINKNAME.sh
  done
}

function republish()
{
  local FUNC=$1 SHUID=$2
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=MCI-Republish-Pump-Data%3Aname%3DmciBuyerSellerIndexUpdate&methodName=update${FUNC}&argType=java.lang.Long&arg0=$SHUID"
}

echo $0 | grep -q mci && create_link && exit 1
#
#
#
SERVER=$(~gchen1/scripts/get_jmx-console_status.sh 0.mci | grep up | awk '{ print $1; }' | head -1)
[ -z "$SERVER" ] && echo "no available mci, quitting." && exit 2

authenticationTest
UTYPE=$(basename $0 | cut -d_ -f2)
ITYPE=$(basename $0 | cut -d_ -f3 | sed -e 's/.sh$//')

[ -f "$1" ] && UIDS=`cat "$1"` && shift
UIDS="$UIDS $@"
UIDS=$(echo "$UIDS" | tr -s ', \n\t' ' ')

echo "Update $UTYPE $ITYPE index by ID on ${SERVER}.myweb.com..."
for SID in $UIDS; do
  echo -n "republishing $UTYPE ID=$SID, "
  echo $SID | egrep -q "^[0-9]+$" && echo "`republish $UTYPE$ITYPE $SID | grep -oG ^\[0-9]*$` ${ITYPE}(s) republished." || echo "wrong id, skipped"
done
