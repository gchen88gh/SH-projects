#!/bin/bash
#### Usage: $0 [OPTION]... [on|off|start|stop mci_host_pattern...]
#### Check pumps info on all mci hosts, set selected mci pump (via option) state on specified mci hosts.
#### Example: 1) $0 <cr>                        to print pump status of all mci hosts
####          2) $0 --listing on 06mci <cr>     to start listing pump on all mci hosts in P06
#### Option:
####   -l, --listing   select Listing pump
####   -o, --order     select Order pump
####   -p, --payment   select SellerPayment pump
####   -h, --help      display this help
#### Wiki: https://wiki.myweb.com/pages/viewpage.action?pageId=xxxxxxxx

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head -11 $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function latencyStatus()
{
  local PUMPNAME=$1
  echo "$LATENCYSTR" | grep -A6 "<td>$SERVER" | grep "${PUMPNAME}Pump" | sed -e 's/^.*Status=\(.*\),.*=\(.*\) .*$/\1(\2)/'
}

function setPump()
{
  local PUMPACTION=$1 PUMPID
  echo "$2" | grep -iqw listing && PUMPID=1
  echo "$2" | grep -iqw order   && PUMPID=2
  echo "$2" | grep -iqw payment && PUMPID=3
  [ -z "$PUMPID" ] && return 1
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=MCI-Pump%3Aname%3DmciPumpConfig&methodName=${PUMPACTION}PumpJob&argType=java.lang.String&arg0=&argType=java.lang.Integer&arg1=$PUMPID" | egrep -q "true|false"
}

#
#
#
#
#
#
#

function getPumpStr()
{
  local JMXSTR="http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=MCI-Pump%3Aname%3DmciPumpConfig&methodName"
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "$JMXSTR=checkAllPumpStatus"
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "$JMXSTR=isPumpInProgress"
}

function pumpStatus()
{
  local PUMPNAME=$1
  [ "$PUMPSTR" = down ] && echo '[--]' && return 1
  echo "$PUMPSTR" | grep -q "${PUMPNAME}PumpInProgress=true" && echo -n '\e[0;32m'
  echo "$PUMPSTR" | grep -q "${PUMPNAME}PumpRunning=true" && echo -n '[\e[0mon' || echo -n '[\e[0;31moff'
  echo "$PUMPSTR" | grep -q "${PUMPNAME}PumpInProgress=true" && echo -n '\e[0;32m]' || echo -n '\e[0m]'
  echo -n '\e[0m'
}

function getopt()
{
  ARGV=()
  while [ $# -gt 0 ]; do
    OPT=$1
    shift
    case ${OPT} in
      -h|--help)
           usage && exit 1
           ;;
      -l|--listing)
           CMLSETPUMPS="$CMLSETPUMPS listing"
           ;;
      -o|--order)
           CMLSETPUMPS="$CMLSETPUMPS order"
           ;;
      -p|--payment)
           CMLSETPUMPS="$CMLSETPUMPS payment"
           ;;
      *)
           [ "${OPT:0:1}" = "-" ] && echo "${OPT}: unknown option." && exit 1
           ARGV+=(${OPT})
           ;;
    esac
  done
}

getopt $*
HOSTARGUS=$(echo "${ARGV[@]}" | tr -s ', ' ' ' | cut -d' ' -f2-)

SWITCHARGUS=`grep Usage $0 | grep -v sed | sed -e "s/^.*\. \[\(.*\) .*/\1/" | tr '|' '\n'`
[ -n "${ARGV[0]}" ] && echo "$SWITCHARGUS" | (! grep -qxi "${ARGV[0]}") && usage && echo "\"${ARGV[0]}\" is not a valid switch, quit." && exit 1

echo "${ARGV[0]}" | egrep -qi "on|start" && SETTO='start'
echo "${ARGV[0]}" | egrep -qi "off|stop" && SETTO='stop'

authenticationTest

. ~gchen1/scripts/get_hosts.sh mci
MCISERVERS=$SERVERS
. ~gchen1/scripts/get_hosts.sh -f mci $HOSTARGUS

printf "    %-10s%15s%24s%26s%25s\n" "Host" "Listing" "Order" "Payment"
printf "%-14s%15s%24s%26s%25s\n" "------------" "-------" "-----" "-------"
while ( [ "$ANS" != 'q' ] ); do
  for SERVER in $MCISERVERS; do
    isJmxUp $SERVER && LATENCYSTR=`/usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=invokeOpByName&name=MCI-HealthCheck%3Aname%3DmciPumpLatency&methodName=checkAllBladeLatencyStatus"` && break
  done
  [ -z "$LATENCYSTR" ] && echo 'No mci host available, please check mci pool. Quitting.' && exit 1

  [ -n "$BACKROW" ] && echo -ne "\e[${BACKROW}A" || BACKROW=$((1 + 2 * $(echo "$MCISERVERS" | wc -l)))
  for SERVER in $MCISERVERS; do
#
    ! isJmxUp $SERVER && PUMPSTR='down' && echo -en "\e[0;35m" || PUMPSTR=`getPumpStr`
#
#
    echo -n "$SERVER"
    echo "$SERVERS" | grep -q $SERVER && SETPUMPS=$CMLSETPUMPS || SETPUMPS=''
    for NAME in Listing Order Payment; do
      OLDSTATUS="`latencyStatus $NAME``pumpStatus $NAME`"
      NEWSTATUS=""
#
      echo "$SETPUMPS" | grep -qi $NAME && setPump $SETTO $NAME && PUMPSTR=`getPumpStr` && NEWSTATUS="->`pumpStatus $NAME`"
##    printf -e "%18s%-7s" $OLDSTATUS $NEWSTATUS
      printString "$OLDSTATUS" 18 r
      printString "$NEWSTATUS" 7 l
    done
    echo -e "\e[0m\n"
  done
  SERVERS=''
  read -s -t 30 -n 1 -p "sleeping 30 seconds... (hit 'q' to exit, any other key to refresh immediately)" ANS; echo
done

