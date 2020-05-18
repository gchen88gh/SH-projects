#!/bin/bash
#

#
[ -n "$2" ] && [ "$2" != "srw" ] && DC="sjr" || DC="srw"
pushd ~ &>/dev/null
LIST=`cap check_pool -s blades="$1" -s target=int,ext -s dc="$DC" 2>/dev/null | grep "$1" | grep green | awk '{ print $1; }' | sort -u`
#
popd &>/dev/null
echo $0 | grep -q "get_Green_Blade.sh" && echo $LIST | sed "s/ /,/g"
#
LIST=$(echo "$LIST" | grep -v 06$1)
