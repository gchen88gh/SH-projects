#!/bin/bash
function getQnum()
{
  curl -s "http://$1.myweb.com:8161/admin/queues.jsp" | grep -A$(($3-1)) "^$2" | sed -n $3p | sed 's/[^0-9]*\([0-9]*\).*/\1/'
#
}

echo "TABLE tblSMailQueueChk"
echo "START_SAMPLE_PERIOD"
totalQ=0
totalEnQ=0
totalDeQ=0
#
for host in `~gchen1/scripts/get_hosts.sh 00mqm`;do
#
smQ=`getQnum ${host} "StrongMailQueue" 2`
enQ=`getQnum ${host} "StrongMailQueue" 4`
deQ=`getQnum ${host} "StrongMailQueue" 5`
coQ=`getQnum ${host} "Consumer.orderLifeCycle.strongmail" 2`
echo "MsgInQ_${host}:count=$((smQ+coQ))"
echo "MsgEnQ_${host}:count=$enQ"
echo "MsgDeQ_${host}:count=$deQ"
totalQ=$((totalQ+smQ+coQ))
totalEnQ=$((totalEnQ+enQ))
totalDeQ=$((totalDeQ+deQ))
done
#
echo "MsgInQ_total:count=${totalQ}"
echo "MsgEnQ_total:count=${totalEnQ}"
echo "MsgDeQ_total:count=${totalDeQ}"
echo "END_SAMPLE_PERIOD"
echo "END_TABLE"
