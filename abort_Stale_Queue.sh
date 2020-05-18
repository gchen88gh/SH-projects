#!/bin/bash
#
#
. ~gchen1/scripts/basic_func.sh &>/dev/null || return
#
#
#
SERVER=$(~gchen1/scripts/get_jmx-console_status.sh abi | grep up | cut -d" " -f1 | tail -1).myweb.com
[ -z "$SERVER" ] && echo "no available abi, quitting." && exit 2
authenticationTest
#
#
#
viewStaleDataReport=`/usr/bin/curl --user "$USER":"$PASSCODE" "http://${SERVER}/jmx-console/HtmlAdaptor?action=inspectMBean&name=autobulklite%3Aname%3DSupportTools" 2>/dev/null | grep -A9 viewStaleDataReport | grep "methodIndex" | sed -e "s/.*value=.\([0-9]*\).*/\1/"`
SDR=`/usr/bin/curl --user "$USER":"$PASSCODE" http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=autobulklite%3Aname%3DSupportTools&methodIndex=$viewStaleDataReport" 2>/dev/null`

for QID in $1; do
#
  echo "$SDR" | grep -q "arg0=$QID"
  [ $? -ne 0 ] && echo "`date` - QID=$QID no longer exists" >> $0.log && continue

#
  /usr/bin/curl --user "$USER":"$PASSCODE" "http://${SERVER}/jmx-console/HtmlAdaptor?action=invokeOpByName&name=autobulklite%3Aname%3DSupportTools&methodName=abortUncompleteQueue&argType=java.lang.Long&arg0=$QID" 2>/dev/null | grep -q "Operation completed successfully without a return value" && echo "`date` - QID=$QID successfully aborted" >> $0.log && continue
  echo "`date` - Aborting QID=$QID operation failed, Check!" | tee -a $0.log
done
