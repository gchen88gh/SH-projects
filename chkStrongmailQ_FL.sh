#!/bin/bash
function getQnum()
{
  curl -s "http://$1.myweb.com:8161/admin/queues.jsp" | grep -A$(($3-1)) "^$2" | sed -n $3p | sed 's/[^0-9]*\([0-9]*\).*/\1/'
}

echo "TABLE tblSMailQueueChk"
totalQ=0
totalEnQ=0
totalDeQ=0
for host in srwp00mqm001 srwp00mqm002 srwp00mqm003;do
echo "START_SAMPLE_PERIOD"
echo "strHost.String.id=${host}"
#
smQ=`getQnum ${host} "StrongMailQueue" 2`
enQ=`getQnum ${host} "StrongMailQueue" 4`
deQ=`getQnum ${host} "StrongMailQueue" 5`
coQ=`getQnum ${host} "Consumer.orderLifeCycle.strongmail" 2`
echo "intMsgInQ:count=$((smQ+coQ))"
echo "intMsgEnQ:count=$enQ"
echo "intMsgDeQ:count=$deQ"
totalQ=$((totalQ+smQ+coQ))
totalEnQ=$((totalEnQ+enQ))
totalDeQ=$((totalDeQ+deQ))
echo "END_SAMPLE_PERIOD"
done
echo "START_SAMPLE_PERIOD"
echo "strHost.String.id=Total"
echo "intMsgInQ:count=${totalQ}"
echo "intMsgEnQ:count=${totalEnQ}"
echo "intMsgDeQ:count=${totalDeQ}"
echo "END_SAMPLE_PERIOD"
echo "END_TABLE"
