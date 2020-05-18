#!/bin/bash
#
#

. ~/scripts/get_Green_Blade.sh mci $2
[ -z "$LIST" ] && echo "no available mci, quitting." && exit 2
SERVER=$(echo "$LIST" | tail -1)
echo "Update seller payment index by ID on ${SERVER}.myweb.com..."
INDX=5 # updateSellerPayment(), Update seller Payment index by ID

for SID in $1; do
  echo -n "republishing Seller ID=$SID, "
  echo "`/usr/bin/curl http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=MCI-Republish-Pump-Data%3Aname%3DmciBuyerSellerIndexUpdate&methodIndex=$INDX&arg0=$SID" 2>/dev/null | grep -oG ^\[0-9]*$` payments republished." && continue
  echo "Error: No Return Value."
done
