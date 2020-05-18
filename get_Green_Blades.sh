#!/bin/bash
#
#

#
#
pushd /nas/utl/presidio &>/dev/null
#
#
LIST=`sudo /usr/local/bin/cap pool:status ROLES=sli01 2>1 | grep in-pool | sed -e "s/^.*:: \(.*\)].*/\1/"`
#
popd &>/dev/null
echo $0 | grep -q "get_Green_Blades.sh" && echo $LIST | sed "s/ /,/g"
#
#
