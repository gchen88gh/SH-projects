#!/bin/bash
#
. ~gchen1/scripts/basic_func.sh &>/dev/null || return
#
#
#
#
SERVER=$(~gchen1/scripts/get_jmx-console_status.sh 01abi | grep up | cut -d" " -f1 | tail -1).myweb.com
[ -z "$SERVER" ] && echo "no available abi, quitting." && exit 2
authenticationTest
echo "resume Or Reprocess Lastest Queue For Autobulk Stale Data Report on ${SERVER}..."
#
resumeOrReprocessLastestQueueForStaleDataReport=11
viewStaleDataReport=12
viewStaleDataReport=`/usr/bin/curl --user "$USER":"$PASSCODE" "http://${SERVER}/jmx-console/HtmlAdaptor?action=inspectMBean&name=autobulklite%3Aname%3DSupportTools" 2>/dev/null | grep -A9 viewStaleDataReport | grep "methodIndex" | sed -e "s/.*value=.\([0-9]*\).*/\1/"`
#
QIDS=`/usr/bin/curl --user "$USER":"$PASSCODE" http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=autobulklite%3Aname%3DSupportTools&methodIndex=$viewStaleDataReport" 2>/dev/null | grep Abort | wc -l`
[ $QIDS -eq 0 ] && echo "No stale data." && exit 0
echo -n "$QIDS Autobulk QID stuck in queue, "
#
#
#
/usr/bin/curl --user "$USER":"$PASSCODE" "http://${SERVER}/jmx-console/HtmlAdaptor?action=invokeOpByName&name=autobulklite%3Aname%3DSupportTools&methodName=resumeOrReprocessLastestQueueForStaleDataReport" &>/dev/null

#
sleep $(($QIDS/4+1))
#
#
#

#

TBALIST=`/usr/bin/curl --user "$USER":"$PASSCODE" http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=autobulklite%3Aname%3DSupportTools&methodIndex=$viewStaleDataReport" 2>/dev/null | grep Abort | sed -e 's/.*arg0=\(.*\)".*/\1/'`
#
[ -z "$TBALIST" ] && echo "all queue resumed and stale data cleared." && exit 0
echo "tried resuming and following still stuck."
echo "`date "+%I:%M%P %Z"` - QID=[`echo $TBALIST`] scheduled to abort in 15 minutes."
(sleep 900
/nas/home/gchen1/scripts/abort_Stale_Queue.sh "$TBALIST" "$1"
)&
exit 1
