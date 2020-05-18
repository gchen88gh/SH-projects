function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head -15 $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function getPass()
{
. ~gchen1/scripts/nocjmx &>/dev/null && return
read -p "Enter host password for user '"$USER"': " -s PASSCODE
echo
[ -z "$PASSCODE" ] && echo "No password entered, quitting." && exit 1
}

function isLogonFailed()
{
  curl --user "$USER":"$PASSCODE" http://$1.myweb.com/jmx-console/ | grep -q "This request requires HTTP authentication" && return 0
#
  return 1
}

function getActivePod()
{ 
  local lvs=$(curl -s https://reports.myweb.com/akamai/gtm/ | sed -n '/^myweb.com/,/^myweb.www/,/origin/p' | grep lvs | sed -e 's/^.*:.\([0-9]*\)\..*lvs\(0.\)-.*$/lvs\2=\1/') lvs01=0 lvs02=0 ACTIVEPOD=$(sudo grep 'ACTIVEPOD=' "/nas/utl/NOC/check_SDRJob_FL.ctrl" | sed -e 's/^.*=\(...\).*$/\1/')
  eval "$lvs"
#
#
  [ "$lvs01" -eq 100 ] && echo p01 && return
  [ "$lvs02" -eq 100 ] && echo p02 && return
  [ -n "$ACTIVEPOD" ] && echo $ACTIVEPOD && return
  [ "$lvs01" -gt "$lvs02" ] && echo p01 || echo p02
}

function getActivePod()
{ 
  local LVS=$(curl -s https://reports.myweb.com/akamai/gtm/ | sed -n '/^myweb.com/,/^myweb.www/,/origin/p' | grep lvs | sed -e 's/^.*:.\([0-9]*\)\..*lvs\(..\)-.*$/p\2=\1/') ACTIVEPOD=$(sudo grep -s 'ACTIVEPOD=' "/nas/utl/NOC/check_SDRJob_FL.ctrl" | grep -v '^#' | sed -e 's/^.*ACTIVEPOD=.*\(p[0-9][0-9]\).*$/\1/')
  local POD100=$(echo "$LVS" | grep 100)
  [ -n "$POD100" ] && echo "${POD100:0:3}" && return
  local PODS=$(echo $LVS | sed -e "s/p\(..\)=[^ ]*/\1/g" -e "s/ /|/g")
  ACTIVEPOD=$(echo "$ACTIVEPOD" | egrep "^p($PODS)$" | tail -1)
  [ -n "$ACTIVEPOD" ] && echo $ACTIVEPOD && return
#
  MAXVAL=-1
  for PODVAL in $LVS; do
    PODVAL=$(echo "$PODVAL" | sed -e 's/^\(.*\)=\(.*\)$/POD=\1;VAL=\2/')
    eval "$PODVAL"
    [ "$VAL" -gt "$MAXVAL" ] && ACTIVEPOD="$POD" && MAXVAL="$VAL"
  done
  echo $ACTIVEPOD
}

function isJmxUp()
{
#
  curl --user "$USER":"$PASSCODE" http://$1.myweb.com/jmx-console/ | grep -iq "$1"
}

function isJmxUp()
{
#
  JMXCONTENT=`/usr/bin/curl --user "$USER":"$PASSCODE" http://$1.myweb.com/jmx-console/ 2>/dev/null`
  echo "$JMXCONTENT" | grep -iq "Service Temporarily Unavailable" && JMXSTATUS='down, the server is temporarily unavailable' && return 1
  echo "$JMXCONTENT" | grep -iq "$1" && JMXSTATUS='up.' && return 0
  echo "$JMXCONTENT" | grep -q "This request requires HTTP authentication" && JMXSTATUS='up, requiring HTTP authentication' && return 0
  JMXSTATUS='down, or in unexpected/unknown status'
  return 1
}

function curl()
{
  /usr/bin/curl --max-time 1 --retry 5 -s $@
}

function showServers()
{
  local PRE SERVER
  echo "Matched host(s):"
  for SERVER in $SERVERS; do
    [ "$PRE" = "${SERVER:0:9}" ] && continue
##  [ "${PRE:6:3}" = "${SERVER:6:3}" ] && echo -n "        " || echo -n "  ${SERVER:6:3} - "; echo -n "P${SERVER:4:2}: "
    PRE=${SERVER:0:9}
    echo -n "  ${PRE:6:3} - P${PRE:4:2}: "
    SVRS=`echo "$SERVERS" | grep $PRE`
    echo $SVRS | tr ' ' ','
  done
  echo "if the above host list is not exactly expected, enter an empty password to quit."
}

function authenticationTest()
{
  local SERVER SERVERS
  . ~gchen1/scripts/get_hosts.sh mci,byx,slx,myx
  [ -z "$PASSCODE" ] && getPass
  for SERVER in $SERVERS; do
    isJmxUp $SERVER && return
    isLogonFailed $SERVER && break
  done
  echo "Authentication failed, quitting." && exit 1
}

function functionCall()
{
  local SERVER="$1" NAME="$2" METHODNAME="$3" OKSTR="$4" ARG0
  [ -z "$5" ] && ARG0="" || ARG0="&argType=java.lang.String&arg0=${5}"
  [ -z "OKSTR" ] && OKSTR='.'
  curl --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/$NAME" | grep -q "$METHODNAME" || return 0 # return 2
  STATUS="$STATUS $INFUNC"
  curl --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/$(echo $NAME | sed -e 's/inspectMBean/invokeOpByName/')&methodName=${METHODNAME}${ARG0}" | egrep -q "$OKSTR"
#
}

function printString()
{
  local STR=$1 WIDTH=$2 ALIGN=$3 TRIM=$4 LEN LEADING TRAILING
  STR=$(echo "$STR" | sed -e 's/\\e[^m]*m//g')
  LEN=${#STR}
  [ "$LEN" -le "$WIDTH" ] && let LEN=WIDTH-LEN || LEN=0
  TRAILING="$LEN"; LEADING=0
  [ "$ALIGN" = r ] && LEADING="$LEN" && TRAILING=0
#
  [ "$ALIGN" = m ] && let LEADING=LEN/2 && let TRAILING=LEN-LEADING
  printf -v STR "%${LEADING}s%s%${TRAILING}s" '' "$1" ''
  echo -ne "$STR"
}


