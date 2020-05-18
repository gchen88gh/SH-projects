#!/bin/bash
#

[ -z $1 ] && echo "Usage: `basename $0` mci_blade" && exit
pushd ~ &>/dev/null
cap restart:jbossblade HOSTS=$1
popd &>/dev/null

#
/usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=Gen3-mci-solr%3Aname%3DCentralizedMbean&methodIndex=17" &>/dev/null
#
STATUS=`/usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=Gen3-mci-solr%3Aname%3DCentralizedMbean&methodIndex=6" 2>/dev/null | grep -oG "mci.....ListenerContainer-broker0(ContainerProxy): ......."`
echo
[ `echo "$STATUS" | grep -c "Running"` -eq 3 ] && echo -e "All 3 $1 listeners are running!\n" && exit 0
echo -e "Problem: Start $1 listeners failed!\n$STATUS\n"
exit 1
