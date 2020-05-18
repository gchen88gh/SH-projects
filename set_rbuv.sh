#! /bin/bash
###---sage: $0 [on|true|off|false] [p01|p06]
#### Usage: $0 pool_name [on|off] switch_name...
#### Turn on/off specified RBUV switch(es) on given pool.
#### Example: on MYX,BYX,SLX:
####          telesign.phone.validation.switch       –-> Global
####          telesign.phone.validation.switch.com   --> US only
####          telesign.phone.validation.switch.co.uk --> UK only
#### Example: on MYX:
####          login.user.verification.telesign.switch
#### Example: 1) $0 <cr>             to print FARE states
####          2) $0 on <cr>          to turn FARE feature on
###-          3) $0 false p06 <cr>   to turn off FARE on Canary
#
#

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function getPass()
{
read -p "Enter host password for user '`whoami`': " -s PASSCODE
echo
}

function isLogonFailed()
{
  /usr/bin/curl --user `whoami`:"$PASSCODE" http://$1.myweb.com/jmx-console/ 2>/dev/null | grep -q "This request requires HTTP authentication" && return 0
#
  return 1
}

function getProperty()
{
  local UNAME
  UNAME=`whoami`
  SWSTATE=[`/usr/bin/curl --user "$UNAME":"$PASSCODE" http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor -d "action=invokeOp&name=Gen3-sh-ecomm-ears-${DNTAG}%3Aname%3DCentralizedMbean&methodIndex=1&arg0=${SWNAME}" 2>/dev/null | grep -oE "^on|^off|^Operation"`]
}

function setProperty()
{
#
  /usr/bin/curl --user `whoami`:"$PASSCODE" http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor -d "action=invokeOp&name=Gen3-sh-ecomm-ears-${DNTAG}%3Aname%3DCentralizedMbean&methodIndex=0&arg0=${SWNAME}&arg1=${SWSTATUS}" 2>/dev/null | grep -q "OK"
}

[ $# -lt 3 ] && usage && exit 2

GLOBAL='telesign.phone.validation.switch'
US="${GLOBAL}.com"
UK="${GLOBAL}.co.uk"

byx_DNTAG=byxear
myx_DNTAG=myxbigear
slx_DNTAG=slxbigear

eval DNTAG='$'$1_DNTAG

ARGU2=`grep Usage $0 | grep -v sed | sed -e "s/^.*\[\(.*\)\].*/\1/" | tr '|' '\n'`
[ -n "$2" ] && echo "$ARGU2" | (! grep -qxi "$2") && usage && echo "\"$2\" is not a valid argument, quit." && exit 1

#
#
LIST=`/nas/utl/NOC/lhosts.sh "$1"`
[ -z "$LIST" ] && echo "no available $1, quitting." && exit 2
#
#
echo "$2" | egrep -qi "on|true" && SETTO='on'
echo "$2" | egrep -qi "off|false" && SETTO='off'

#

getPass
isLogonFailed $LIST && echo "Authentication failed, quitting." && exit 1

shift 2
SWNAME="$@"
#
#
#

for SERVER in $LIST; do
  echo "${SERVER}:"
  for SWNAME in $@; do
    getProperty $SWNAME
    echo -n "  ${SWNAME}: $SWSTATE"
    [ -z $SETTO ] && echo && continue
    SWSTATUS=$SETTO
    setProperty $SWNAME $SWSTATUS
    getProperty $SWNAME
    echo " --> $SWSTATE"
  done
done
