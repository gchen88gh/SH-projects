#!/bin/bash
#

#
#

#
#

. ~/scripts/get_Green_Blade.sh mci $1
[ -z "$LIST" ] && echo "no available mci, quitting." && exit 2
#
#
echo "checking mci pump status"
for SERVER in $LIST; do
  echo ""
  echo "on ${SERVER}"
  # invoke checkAllPumpStatus() methodIndex=2, change to 4 with RB1121 release
echo "Pump is Running:" `/usr/bin/curl http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=MCI-Pump%3Aname%3DmciPumpConfig&methodIndex=4" 2>/dev/null | grep -oG "\w*=true" | sed -e 's/PumpRunning=true//'`
  # invoke isPumpInProgress() methodIndex=3, change to 5 with RB1121 release
echo "Pump in Progress:" `/usr/bin/curl http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=MCI-Pump%3Aname%3DmciPumpConfig&methodIndex=5" 2>/dev/null | grep -oG "\w*=true" | sed -e 's/PumpInProgress=true//'`
  # http://srwp01mci004.myweb.com:8080/jmx-console/HtmlAdaptor?action=invokeOpByName&name=MCI-Pump%3Aname%3DmciPumpConfig&methodName=checkAllPumpStatus
done
