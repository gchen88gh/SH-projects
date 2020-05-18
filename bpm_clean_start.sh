#!/bin/bash
read -p "Password: " -s PASS
echo
USERNAME=`whoami`
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm010 "sudo /etc/init.d/stop_bpm" "BUILD SUCCESSFUL" 30 "pwd" && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm011 "sudo /etc/init.d/stop_bpm" "BUILD SUCCESSFUL" 30 "pwd" && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm012 "sudo /etc/init.d/bpm stop" "BUILD SUCCESSFUL" 30 "pwd" && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm014 "sudo /etc/init.d/bpm stop" "BUILD SUCCESSFUL" 30 "pwd" && \
sleep 10 && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm010 "sudo /etc/init.d/start_bpm" "Starting TeamWorks Process Server" 30 "pwd" && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm011 "sudo /etc/init.d/start_bpm" "Starting TeamWorks Process Server" 30 "pwd" && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm012 "sudo /etc/init.d/bpm start" "Starting TeamWorks Process Server" 30 "pwd" && \
~gchen1/scripts/ssh_cmds.exp $USERNAME $PASS srwc01bpm014 "sudo /etc/init.d/bpm start" "Starting TeamWorks Process Server" 30 "pwd"

. ~gchen1/scripts/bpm_smoke_test.sh

exit
