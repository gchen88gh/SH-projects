#!/bin/bash
#

#
#
#
#
LIST='srwp01act002 srwp01act001'
for SERVER in $LIST; do
  TMPPAGESOURCE=`/usr/bin/curl "http://${SERVER}/jmx-console/HtmlAdaptor?action=inspectMBean&name=accounttex2%3Aname%3DJobManager" 2>/dev/null`
  echo "$TMPPAGESOURCE" | grep -q MaxConcurrentConsumers && STATUS=`echo -e $STATUS"\n"$SERVER` && PAGESOURCE=$TMPPAGESOURCE
done
[ `echo "$STATUS" | grep -ci act` -eq 0 ] && echo "Warning! no available act jmx-console" && exit 2
[ `echo "$STATUS" | grep -ci act` -gt 1 ] && echo "Warning! found act servers that are running: "$STATUS", only one of them is supposed up" # && exit 2
SERVER=`echo "$STATUS" | tail -1`
echo "checking act jobs status on ${SERVER}"
PAGESOURCE=`echo "$PAGESOURCE" | grep MaxConcurrentConsumers: | sed -e "s/<br>/\n/g;s/[ \x09]//g" | sort`
echo -e "\njobs that are Running:\n======================"
#
echo "$PAGESOURCE" | grep Run | sed -e "s/^\(\w*\)(.*):Running\(.*\)$/\1\2/;s/\./ - /"
echo -e "\njobs that are Stopped:\n======================"
#
echo "$PAGESOURCE" | grep Stop | sed -e "s/^\(\w*\)(.*/\1/"

exit

