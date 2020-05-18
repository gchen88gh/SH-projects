#!/bin/bash
#
#

function clearCache()
{
  /usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=Gen3-EventApp%3Aname%3DGen3+CacheManager&methodIndex=5&arg0=com.myweb.common.business.manager.RedirectMapMgr.getByFromURL" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

. /nas/home/gchen1/scripts/get_Green_Blade.sh "brx" "$1"
[ -z "$LIST" ] && echo "no available blade to clear cache on, quitting." && exit 1

for SERVER in $LIST; do
  echo -n "clearing cache on ${SERVER}..."
  STATUS=""
  clearCache $SERVER || clearCache $SERVER.myweb.com || STATUS=" please check"
  sleep 5
  [ -z "$STATUS" ] && echo "done" || echo "problem:$STATUS"
done
