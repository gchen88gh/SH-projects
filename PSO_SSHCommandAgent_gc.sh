#!/bin/bash
#

for ((hostCount=0; hostCount<$hostList_rowCount; hostCount++));
do
  hostName=hostList_${hostCount}_hostName
  port=hostList_${hostCount}_port
  user=hostList_${hostCount}_user
  password=hostList_${hostCount}_password

  if [ -z ${!user} ]
    then user=globalUser
  fi

  if [ -z ${!password} ]
    then password=globalPassword
  fi

  export test='#!'s#\([^%]\)$#\1#g#${!password}@gsnoc#!@#'!@#$%gc^&*()'${!user}.asdfg=

  for ((commandCount=0; commandCount<$commandList_rowCount; commandCount++));
  do
    commandName=commandList_${commandCount}_commandName
    command=commandList_${commandCount}_command
    runType=commandList_${commandCount}_runType

    commandLine=${!command}
    if [ "${commandLine: -1}" != ";" ]
      then commandLine="$commandLine;"
    fi

#
    /nas/home/gchen1/scripts/sshExpect_gc.sh ${!hostName} ${!port} "${!commandName}" "{ ${commandLine} }" ${!runType}

  done

done

exit
