#!/bin/bash
#

. ~gchen1/scripts/get_hosts.sh act
for SERVER in $SERVERS; do
  /usr/bin/curl "http://${SERVER}/jmx-console/HtmlAdaptor?action=inspectMBean&name=accounttex2%3Aname%3DStaleDataRecovery" 2>/dev/null | grep -q executeBatchRetransmissionByBatchId && STATUS=`echo -e $STATUS"\n"$SERVER` && break
done
[ -z "$STATUS" ] && echo "no available act jmx-console, quitting" && exit 2

echo "Execute Batch Retransmission By BatchId on ${SERVER}..."

for BID in $@; do
  echo -n "  retransmitting BatchID=$BID, "
  /usr/bin/curl "http://${SERVER}/jmx-console/HtmlAdaptor?action=invokeOpByName&name=accounttex2%3Aname%3DStaleDataRecovery&methodName=executeBatchRetransmissionByBatchId&argType=java.lang.Long&arg0=$BID" 2>/dev/null | grep -q "Operation completed successfully without a return value" && echo "done" || echo "error: unexpected return value"
done
