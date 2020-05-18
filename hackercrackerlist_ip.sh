#!/bin/bash
#
function get_list()
{
  local LIST
  echo -e '/nas/utl/tools/Cloak-uncloak <<EOF'"\ngchen1\n71Z902jy8" > $0.tmp
  echo -e "$LISTNO\n1\nb\nEOF\n" >> $0.tmp
  LIST=`. $0.tmp 2>/dev/null | egrep "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -nu`
  echo "$LIST"
}

ACTION=$1 #add=2 delete=3
LISTNO=3 # 1-blacklist 2-whitelist 3-hackercrackerlist
LIST=`get_list`
#
#
#
#
shift
#
[ -f "$1" ] && DATAFILE=" $1" && IPS=`cat "$1"`
[ -f "$0.log" ] || echo > $0.log
IPS="$IPS $@"
#
#
for IP in $IPS; do
#
  [ "$ACTION" -eq 2 ] && echo "$LIST" | grep -q "$IP" && continue
  [ "$ACTION" -eq 2 ] && [ "$IP" = "170.170.59.139" ] && continue
#
  echo $IP | egrep -q "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" && IPS2=$IPS2' '$IP
done
[ -z "$IPS2" ] && echo 'no new ip to work on' && exit 1
echo -e '/nas/utl/tools/Cloak-uncloak <<EOF'"\ngchen1\n71Z902jy8" > $0.tmp
echo -e "$LISTNO\n$ACTION\n${IPS2:1}\ny\nb\nEOF\n" >> $0.tmp
echo -e 'blocking/unblocking ip(s) in progress...\c'
. $0.tmp &>/dev/null
#
echo done
echo -e "--------\naction=$ACTION$DATAFILE\nip=$IPS2\n" >> $0.log
/nas/home/gchen1/scripts/grep_blacklist.sh "$IPS2" >> $0.log
echo -e "========\n" >> $0.log
#
#
#
#
#
rm -f $0.tmp &>/dev/null
#
