#!/bin/bash
#### Usage: $0 [OPTION]... $1...
#### Start/Stop/Restart bpm server on host
#### Option:
####   -perf           select Performance server
####   -proc           select Process server [default]
####   -clean          clean restart of all Process servers
####   -stop           stop selected server on host
####   -start          start selected server on host
####   -restart        restart selected server on host [default]
####   -h, --help      display this help

cmd=$1
eval `cat ~gchen1/scripts/service_restart.dat | sed -ne "/\[$cmd/,/^\[/p" | grep -Ev '\[|\]'`
echo $start $stop
exit

function usage()
{
  echo $0 | grep -q proc && . ~gchen1/scripts/get_hosts.sh proc || . ~gchen1/scripts/get_hosts.sh bpm
  SEDSTR1="s/\$0/`basename $0`/g"
  SEDSTR2=$(echo "$SERVERS" | sed -e 's/^.*\(..\)$/\1/')
  SEDSTR2="s/\$1/[$(echo $SEDSTR2 | tr ' ' '|')]/"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR1" -e "$SEDSTR2"
}

function bpm_proc()
{
## cd /software/TWEMS/runtime/teamworks622_srwc01bpm0xx/process-server
## sudo ./startProcessServer.sh stop
## sudo ./startProcessServer.sh start
  local SERVER=$1 ACTION=$2 CMD
  [ ${SERVER:10:2} -le 11 ] && CMD=${ACTION}_bpm || CMD="bpm ${ACTION}"
  echo -n "${ACTION} Teamworks Process Server on ${SERVER}... "
  ~gchen1/scripts/ssh_cmds1.exp "" "" ${SERVER} "sudo /etc/init.d/${CMD}; sleep 1; echo -n O; echo K" "OK" 30 "pwd"
  [ $? -gt 1 ] && echo "having login issue, exit" && exit || echo "Ok"
#
}

function bpm_perf()
{
  local SERVER=$1 ACTION=$2 PROG CMD
  PROG="/software/TWEMS/runtime/teamworks622_${SERVER}/performance-server/startPerformanceServer.sh"
  CMD="sudo $PROG ${ACTION}; sleep 1; echo -n O; echo K"
  echo -n "${ACTION} Teamworks Performance Server on ${SERVER}... "
  ~gchen1/scripts/ssh_cmds1.exp "" "" ${SERVER} "${CMD}" "OK" 30 "pwd"
  [ $? -gt 1 ] && echo "having login issue, exit" && exit || echo "Ok"
#
}

function bpm_service()
{
  local SERVER=$1 SERVICE ACTION=$3 PROG CMD
  echo "$2" | grep -iq proc && SERVICE=Process
  echo "$2" | grep -iq perf && SERVICE=Performance
  [ -z "$SERVICE" ] && echo "Invalid service, quit" && exit 2
  PROG="/software/TWEMS/runtime/teamworks622_${SERVER}/p${SERVICE:1}-server/start${SERVICE}Server.sh"
  CMD="sudo $PROG ${ACTION}; sleep 4; echo -n O; echo K"
  echo -n "${ACTION} Teamworks $SERVICE Server on ${SERVER}... "
  ~gchen1/scripts/ssh_cmds1.exp "" "" ${SERVER} "${CMD}" "OK" 30 "pwd"
#
  [ $? -gt 1 ] && echo "having login issue, exit" && exit || echo "Ok"
#
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
      -perf)
           SERVICE="$SERVICE perf"
           ;;
      -proc)
           SERVICE="$SERVICE proc"
           ;;
      -clean)
           ACTION='clean stop start restart'
           SERVICE="proc"
           break
           ;;
      -restart)
           ACTION='stop start restart'
           ;;
      -stop)
           ACTION="$ACTION stop"
           ;;
      -start)
           ACTION="$ACTION start"
           ;;
      -status)
           ACTION='status'
           ;;
      *)
           [ "${OPT:0:1}" = "-" ] && echo "${OPT}: unknown option." && exit 1
           ARGV+=(${OPT})
           ;;
    esac
  done
}

[ $# -eq 0 ] && usage && exit 1
getopt $*
ARGUS=$(echo "${ARGV[@]}" | tr -s ', ' '|')
[ -z "$ACTION" ] && ACTION='stop start restart'
[ -z "$SERVICE" ] && eval echo $0 | grep -q perf && SERVICE='perf' || SERVICE='proc'

SERVERS=`grep Usage $0 | grep -v sed | sed -e "s/^.*\[\(.*\)\].*/\1/" | tr '|' '\n'`
. ~gchen1/scripts/get_hosts.sh bpm
##echo "$SERVERS" | (! grep -qxi "${ARGV[@]}") && echo "\"$1\" is not a valid argument, quit." && exit 1

echo argu=$ARGUS, Servers=$SERVERS
echo "${ACTION}" | grep -qi clean && . ~gchen1/scripts/get_hosts.sh proc || SERVERS=$(echo "$SERVERS" | egrep $ARGUS)
echo Service=$SERVICE, Action=$ACTION, Servers=$SERVERS

read -p "Password: " -s PASS; echo
export test='#!'s#\([^%]\)$#\1#g#$PASS

[ -z "$SERVERS" ] && echo "No valid bpm host specified, quitting" && exit 1

for SERVER in $SERVERS; do
  echo $SERVICE | grep -wq perf && echo $ACTION | grep -wq stop && bpm_service $SERVER perf stop
  echo $SERVICE | grep -wq proc && echo $ACTION | grep -wq stop && bpm_service $SERVER proc stop
##  echo $SERVICE | grep -wq perf && echo $ACTION | grep -wq stop && bpm_perf $SERVER stop
##  echo $SERVICE | grep -wq proc && echo $ACTION | grep -wq stop && bpm_proc $SERVER stop
done
echo $ACTION | grep -wq stop && echo $ACTION | grep -wq start && (read -s -t 30 -n 1 -p "waiting 30 seconds, hit any key to start the server(s) now "; echo)
#
for SERVER in $SERVERS; do
  echo $SERVICE | grep -wq perf && echo $ACTION | grep -wq start && bpm_service $SERVER perf start
  echo $SERVICE | grep -wq proc && echo $ACTION | grep -wq start && bpm_service $SERVER proc start
##  echo $SERVICE | grep -wq perf && echo $ACTION | grep -wq start && bpm_perf $SERVER start
##  echo $SERVICE | grep -wq proc && echo $ACTION | grep -wq start && bpm_proc $SERVER start
done

echo "$1" | grep -qi clean && . ~gchen1/scripts/bpm_smoke_test.sh
