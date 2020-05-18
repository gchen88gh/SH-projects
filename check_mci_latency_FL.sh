#!/bin/bash
echo "TABLE tblMciLatencyChk"
echo "START_SAMPLE_PERIOD"

TEMPSTR=`/usr/bin/curl http://srwp01mci001/jmx-console/HtmlAdaptor -d "action=invokeOp&name=MCI-HealthCheck%3Aname%3DmciPumpLatency&methodIndex=1" 2>/dev/null | grep -A5 '<td>srwp0.mci' | sed -e "s/<td>//" -e "s/<\/td>/@/"`
echo $TEMPSTR" " | sed -e "s/-- /\n/g" | sed -e "s/\(srwp.*\)@ \(.*\)@ \(.*\)@ ....-..-.*-..-.*@ \(.*\)@ /\2_\1:count=\3\4/" -e "s/.myweb.com//" -e "s/true//" -e "s/false.*/0/"

echo "END_SAMPLE_PERIOD"
echo "END_TABLE"

