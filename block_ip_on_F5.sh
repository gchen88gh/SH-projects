. ~gchen1/scripts/basic_func.sh &>/dev/null
ACTION=2 #add=2 delete=3
LIST=1 # 1-blacklist 2-whitelist 3-hackercrackerlist
getPass
[ -f "$1" ] && IPS=`cat "$1"`
IPS="$IPS $@"
echo '/nas/utl/tools/Cloak-uncloak <<EOF' > $0.tmp
echo `whoami` >> $0.tmp
echo "$PASSCODE" >> $0.tmp
for IP in $IPS; do
  [ "$ACTION" -eq 2 ] && grep -q "$IP" $0.log && continue
#
  echo $IP | egrep -q "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" && IPS2=$IPS2' '$IP
done
[ -n "$IPS2" ] && echo -e "$LIST\n$ACTION\n${IPS2:1}\ny\nb\nq\nEOF\n" >> $0.tmp && echo -e 'blocking ip(s) in progress...\c' && sh $0.tmp &>/dev/null && echo done && ~gchen1/scripts/grep_blacklist.sh $IPS2 && echo "$IPS2" >> $0.log || echo 'no new ip to add'
#
#
#
#
#
rm -f $0.tmp &>/dev/null
#
