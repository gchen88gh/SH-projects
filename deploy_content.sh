#

#

read -p "Password: " -s PASS; echo
export test='#!'s#\([^%]\)$#\1#g#$PASS
SERVER=srwp01stj001
CMD=$1
FMT='+%Y-%m-%d %H:%M:%S %Z'
echo -n "executing content deployment on ${SERVER}... "
TS=`date "$FMT"`
#
~gchen1/scripts/ssh_cmds1.exp "" "" ${SERVER} "sudo su deploy;${CMD};" "OK" 15 "pwd"
TE=`date "$FMT"`
[ $? -gt 1 ] && echo "having login issue, exit" || echo "Ok"
echo -e "Start time: $TS\nEnd   time: $TE"

#
#
#
#
