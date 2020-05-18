#!/bin/bash
#

role=`/bin/hostname | cut -c 7-9`

pool="/var/www/maintenance/in-pool.html"
pool2="/opt/wso2am/repository/deployment/server/jaggeryapps/maintenance/in-pool.html"

console="http://localhost/jmx-console"
console2="https://localhost/carbon/admin/login.jsp"

health=false
if [[ $role == ag* ]]; then
  if [ -f $pool2 ]; then
    if [ `/bin/cat ${pool2}` == 'true' ]; then
      health=true
    fi
  fi
else
  if [ -f $pool ]; then
    if [ `/bin/cat ${pool}` == 'true' ]; then
      health=true
    fi
  fi
fi

if [ $health == 'true' ]; then
  if [[ $role == ag* ]]; then
    /usr/bin/wget -O --dns-timeout=3 --read-timeout=3  --tries=3 --no-check-certificate - ${console2} 2>/dev/null 1>/dev/null || health=false
  elif [ $role == 'sws' ]; then
    health=true
  else
    /usr/bin/wget -O --dns-timeout=3 --read-timeout=3  --tries=3 - ${console} 2>/dev/null 1>/dev/null || health=false
  fi
fi

if [ $health == 'true' ]; then
  /bin/echo -e '\033[1m\033[32m'GOOD'\033[0m'
else
  /bin/echo -e '\033[1m\033[31m'BAD'\033[0m'
fi
