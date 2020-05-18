#! /bin/bash

function getPass()
{
read -p "Enter host password for user '`whoami`': " -s PASSCODE
echo
}

function isJmxUp()
{
#
  JMXCONTENT=`/usr/bin/curl --user "$USER":"$PASSCODE" http://$1.myweb.com/jmx-console/ 2>/dev/null`
  echo "$JMXCONTENT" | grep -iq "Service Temporarily Unavailable" && JMXSTATUS='down, the server is temporarily unavailable' && return 1
  echo "$JMXCONTENT" | grep -iq "$1" && JMXSTATUS='up.' && return 0
  echo "$JMXCONTENT" | grep -q "This request requires HTTP authentication" && JMXSTATUS='up,   requiring HTTP authentication' && return 0
  JMXSTATUS='down, or in unexpected/unknown status'
  return 1
}

#
. ~gchen1/scripts/get_hosts.sh $*
USER=dummy
#
#
for SERVER in $SERVERS; do
  echo -n "$SERVER jmx-console is "
#
  isJmxUp $SERVER; echo $JMXSTATUS
done
