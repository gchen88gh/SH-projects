#!/bin/bash
#
#

. ~/scripts/get_Green_Blade.sh lcm $2
[ -z "$LIST" ] && echo "no available lcm, quitting." && exit 2
SERVER=$(echo "$LIST" | tail -1)
echo "publish Geo Tree Under ID on ${SERVER}.myweb.com..."
INDX=4  # republishListingSourceMap()
INDX=5  # publishTicketsUnderGeoId(arg0)
INDX=6  # publishTicketsUnderGenreId(arg0)
INDX=8  # republishDeliveryMethodMap()
INDX=12 # publishGenreTreeUnderId(arg0)
INDX=15 # publishGeoTreeUnderId(arg0)
INDX=20 # republishFulfillmentMethodMap
INDX=21 # publishGenreAndGeoTrees
INDX=24 # republishFullIndex
INDX=26 # masterOnlyRepublish
INDX=29 # publishAllTickets

STRINNAME=`echo $0 | sed -e "s/^.*_\(.*\)\.sh.*$/\1/"`
echo $STRINNAME
eval `grep ^INDX $0 | grep -i $STRINNAME`
echo index=$INDX
exit

for SID in $1; do
  echo -n "republishing Geo Tree under ID:$SID, "
  /usr/bin/curl http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=com.myweb.framework.lcsmaster%3Aservice%3DrequestChainServletMonitor&methodIndex=$INDX&arg0=$SID" 2>/dev/null | grep -q "Operation completed successfully without a return value" && echo "done" || echo "unexpected return value"
done

#
