#
IPS=`echo "$*" | tr -s ', ' '|' | tr -cd '0-9.|' | sed -e "s/^|//;s/|$//;s/\./a./g" | tr a '\\'`
egrep "$IPS" /nas/utl/tools/Cloak-uncloak.log
