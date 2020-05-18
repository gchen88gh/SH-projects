#!/bin/bash
#
#
#

function clearCache()
{
  /usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=$PRE$NAME%3Aname%3DGen3+CacheManager&methodIndex=$INDX" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

! grep -q "$1_NAMES" $0 && echo "Clearing cache on $1 is not supported, quitting." && exit 2
#! grep -q "$1_NAMES" $0 && /nas/home/gchen1/scripts/clear_cache1.sh "$1" "$2" && exit 2
. ~gchen1/scripts/get_Green_Blade.sh "$1" "$2"
[ -z "$LIST" ] && echo "no available blade to clear cache on, quitting." && exit 1
brx_NAMES="Codes-AboutUsAPI Codes-FeedServices Codes-HelpApp Codes-TicketAPI EventApp SearchApp"
byx_NAMES="Codes-CheckoutApp"
edl_NAMES="Codes-Confirm"
mci_NAMES="Codes-MultipleCatalogInternal"
myx_NAMES="Codes-AddressRefServices Codes-LoginApp Codes-MyAccountAPI MyAccountApp"
sli_NAMES="Codes-SellListener"
slx_NAMES="Codes-StubhubSLXRole FulfillmentApp"
#

PRE="Gen3-"
INDX=6 # clear content cache
#
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
