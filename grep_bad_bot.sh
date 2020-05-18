#!/bin/bash
#
#

num=0
echo -n '' > blocked_bad_bot_ip.txt
for botip in $(cat badBot.txt); do
  num=$((num+1))
  [ $((num%100)) -eq 0 ] && echo -n '.'
  grep ^$(echo $botip | sed -e 's/\./\\./g')$ IPBLOCKed.txt >> blocked_bad_bot_ip.txt
done
