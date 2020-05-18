#

[ $# -ne 1 ] && echo "Usage: `basename $0` [clean|10|11|12|14]" && exit

SERVERS=`grep Usage $0 | grep -v sed | sed -e "s/^.*\[\(.*\)\].*/\1/" | tr '|' '\n'`
echo "$SERVERS" | (! grep -qxi "$1") && echo "\"$1\" is not a valid argument, quit." && exit 1
echo "$1" | grep -qi clean && SERVERS=`echo "$SERVERS" | grep -v clean` || SERVERS=$1

read -p "Password: " -s PASS; echo
export test='#!'s#\([^%]\)$#\1#g#$PASS

for SERVER in $SERVERS; do
  [ $SERVER -le 11 ] && CMD=stop_bpm || CMD="bpm stop"
  echo -n "stopping TeamWorks Process Server on srwc01bpm0${SERVER}... "
  ~gchen1/scripts/ssh_cmds1.exp "" "" srwc01bpm0${SERVER} "sudo /etc/init.d/${CMD}" "BUILD SUCCESSFUL" 30 "pwd"
  [ $? -gt 1 ] && echo "having login issue, exit" && exit || echo "Ok"
done
read -s -t 30 -n 1 -p "waiting 30 seconds, hit any key to start the server(s) now "; echo
#
for SERVER in $SERVERS; do
  [ $SERVER -le 11 ] && CMD=start_bpm || CMD="bpm start"
  echo -n "starting TeamWorks Process Server on srwc01bpm0${SERVER}... "
#
  ~gchen1/scripts/ssh_cmds1.exp "" "" srwc01bpm0${SERVER} "sudo /etc/init.d/${CMD};ps -ef" "TWEMS" 30 "pwd"
  [ $? -gt 1 ] && echo "having login issue, exit" && exit || echo "Ok"
done

echo "$1" | grep -qi clean && . ~gchen1/scripts/bpm_smoke_test.sh
