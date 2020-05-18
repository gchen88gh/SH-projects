#!/bin/bash
#
. ~gchen1/scripts/get_hosts.sh 00mqm
while true ; do

  totalQ=0
#
  echo
  echo `date`
#
  for host in $SERVERS
  do
    smQ=`curl -s "http://${host}.myweb.com:8161/admin/queues.jsp" | grep -A1 "^StrongMailQueue" | sed -n '2p' | sed 's/[^0-9]*\([0-9]*\).*/\1/'`
    sleep 1
    smQ1=`curl -s "http://${host}.myweb.com:8161/admin/queues.jsp" | grep -A1 "^Consumer.orderLifeCycle.strongmail" | sed -n '2p' | sed 's/[^0-9]*\([0-9]*\).*/\1/'`
#
    echo "$host: $smQ + $smQ1"
    totalQ=$((totalQ+smQ+smQ1))
  done
#
#
#
#
  echo  "Total Messages In Queue = $totalQ"
  echo -e "\nsleeping 60 seconds"
  sleep 60

done
