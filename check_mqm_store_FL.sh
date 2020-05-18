#!/bin/bash

NOCSCRIPT="/nas/home/gchen1/scripts/clear_activeMQ_store.sh"
#
[ -f "${NOCSCRIPT}.log" ] && NOCSTATUS=`cat "${NOCSCRIPT}.log"` || NOCSTATUS=`$NOCSCRIPT`
NOCSTATUS=`echo "$NOCSTATUS" | egrep -v 'before|broke' | sed -e 's/Store percent used: //'`
NOCSTATUS=`echo $NOCSTATUS | sed -e "s/ (now)/\\n/g" -e 's/ *//g' | grep -v ':$'`

echo "TABLE tblMqmStoreChk"
echo "START_SAMPLE_PERIOD"

WSTATE=''
WLEVEL=0
for STOREUSED in $NOCSTATUS; do
  SERVER=`echo $STOREUSED | cut -d: -f1`
  USED=`echo $STOREUSED | cut -d: -f2`
  [ "$USED" -lt 70 ] && continue
  WSTATE="${WSTATE}${SERVER}: ${USED}\t\t"
  [ "$WLEVEL" -eq 0 ] && WLEVEL=1
  [ "$USED" -ge 80 ] && WLEVEL=2
done

[ $WLEVEL -eq 0 ] && WSTATE='Normal'
echo -e "MsgNum=$WLEVEL\nMsg.String=$WSTATE\nEND_SAMPLE_PERIOD\nEND_TABLE"
exit
