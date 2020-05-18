#!/bin/bash
CMD='LOGFILE=/software/TWEMS/runtime/teamworks622_`hostname| cut -d. -f1`/process-server/logs/server.log;MQBCMD="grep -c key.orderLifeCycle $LOGFILE";SLICMD="grep -c confirmMsgUCA $LOGFILE";MQBMSG0=`$MQBCMD`;SLIMSG0=`$SLICMD`;COUNTER=0;while [[ $COUNTER -lt 60 ]];do sleep 5;MQBMSG1=`$MQBCMD`;SLIMSG1=`$SLICMD`;echo $MQBMSG0 $MQBMSG1 $SLIMSG0 $SLIMSG1;[ $MQBMSG0 -ne $MQBMSG1 ] && [ $SLIMSG0 -ne $SLIMSG1 ] && echo -n "MQBSLI" && echo "OK";let COUNTER=COUNTER+1;done'
#
[ -z "$PASS" ] && read -p "Password: " -s PASS && echo
USERNAME=`whoami`
export test='#!'s#\([^%]\)$#\1#g#$PASS
echo "testing up to 5 minutes to see if BPM servers receive messages from both MQB & SLI servers"
for SERVER in srwc01bpm012 srwc01bpm014; do
  echo -n "on $SERVER... "
  ~gchen1/scripts/ssh_cmds1.exp "" "" $SERVER "$CMD" "MQBSLIOK" 300
#
  [ $? -eq 0 ] && echo "Passed" || echo "Failed"
done
exit





CMD=<<EOF
LOGFILE=/software/TWEMS/runtime/teamworks622_`hostname| cut -d. -f1`/process-server/logs/server.log
MQBCMD='grep -c key.orderLifeCycle '$LOGFILE
SLICMD='grep -c confirmMsgUCA '$LOGFILE
MQBMSG0=`$MQBCMD`
SLIMSG0=`$SLICMD`
while [[ $COUNTER -lt 50 ]] ; do
  sleep 5
  MQBMSG1=`$MQBCMD`
  SLIMSG1=`$SLICMD`
  [ $MQBMSG0 -ne $MQBMSG1 ] && [ $SLIMSG0 -ne $SLIMSG1 ] && echo "OK"
  let COUNTER=COUNTER+1
done
EOF

#
curl -k -o "$TMP_OUT" "$URL" >/dev/null 2>&1

#
grep "$GENERIC_ERROR" "$TMP_OUT" && PAGE_STATUS='1' PAGE_ERROR='true'

#
HTTP_RESPONSE=`curl -sk -w "%{http_code}" "$URL" -o /dev/null`

