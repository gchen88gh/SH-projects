#!/bin/bash
#
#

function create_link()
{
  for LINKNAME in `grep ^INDX $0 | awk '{ print $4; }'`; do
    echo creating $LINKNAME
#
    ln -sf $0 $LINKNAME
  done
}

. ~/scripts/get_Green_Blade.sh lcm srw
[ -z "$LIST" ] && echo "no available lcm, quitting." && exit 2
SERVER=$(echo "$LIST" | tail -1)

STRINNAME=`echo $0 | sed -e "s/^[^_]*_\(.*\)\.sh$/\1/"`
echo $STRINNAME
eval `grep ^INDX $0 | grep -i $STRINNAME`
echo index=$INDX

[ -z $INDX ] && create_link && exit 1
STRINNAME=`echo $STRINNAME | sed -e "s/_/ /g"`
echo "publish $STRINNAME on ${SERVER}.myweb.com..."

for SID in $@; do
#
  echo -n "  ID = $SID, "
#
  echo done
done

exit
#
#
#
INDX=4  # republishListingSourceMap()
INDX=5  # publishTicketsUnderGeoId(arg0)    publish_Tickets_Under_Geo_Id.sh
INDX=6  # publishTicketsUnderGenreId(arg0)  publish_Tickets_Under_Genre_Id.sh
INDX=8  # republishDeliveryMethodMap()
INDX=12 # publishGenreTreeUnderId(arg0)     publish_Genre_Tree_Under_Id.sh
INDX=15 # publishGeoTreeUnderId(arg0)       publish_Geo_Tree_Under_Id.sh
INDX=20 # republishFulfillmentMethodMap
INDX=21 # publishGenreAndGeoTrees
INDX=24 # republishFullIndex
INDX=26 # masterOnlyRepublish
INDX=29 # publishAllTickets
