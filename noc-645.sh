#!/usr/bin/bash
#
msg=$(/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server lvsp20kfk101.myweb.com:9092,lvsp20kfk102.myweb.com:9092,lvsp20kfk103.myweb.com:9092 --new-consumer --group activeInventoryIndexerGroup --describe 2>/dev/null)
echo "$msg"
lags=$(echo "$msg" | awk '{print $5}')
echo "$lags"
echo $lags
sum=0
for i in $lags; do
   sum=$((sum+i))
done
echo nocscript=noc-645.sh sum_LAG=$sum
