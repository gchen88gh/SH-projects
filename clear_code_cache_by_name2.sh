#!/bin/bash
#### Usage: $0 host_pattern(s) [cache_name...]
#### Clear code cache on host(s) and in addition the specific code cache(s) if supplied on command line. 
#### Example: $0 myx01b
####          $0 ilg FulfillmentMethodWindowDAOImpl.findById
#### fee change:
#### buy/sell fee only: $0 byx,job,abi,ilg com.myweb.business.manager.CodesMgr FeesAdapterDAOImpl.findByLocation FulfillmentMethodWindowDAOImpl.findById
#### with delivery fee: $0 byx,job,abi,ilg,lgi,stj com.myweb.business.manager.CodesMgr FeesAdapterDAOImpl.findByLocation FulfillmentMethodWindowDAOImpl.findById
#### Wiki: https://wiki.myweb.com/display/NOC/How+To+Clear+Code+Cache+for+Fee+Changes

. ~gchen1/scripts/basic_func.sh &>/dev/null

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 2
[ $# -lt 1 ] && usage && exit 2

. /nas/home/gchen1/scripts/get_hosts.sh $1
[ -z "$SERVERS" ] && echo "No supported blade found to clear cache on, quitting." && exit 1
showServers
authenticationTest

shift
CACHES=$(echo "$*" | tr -s ', ' ' ')
INFUNC=INFUNC
OKSTR='Operation completed successfully without a return value|OK'

for SERVER in $SERVERS; do
  echo -n "clearing code cache on ${SERVER}..."
  ! isJmxUp $SERVER && echo -e "\e[3D: jmx unavailable" && continue
  STATUS=""
  NAMES=$(curl --user "$USER":"$PASSCODE" "http://$SERVER.myweb.com/jmx-console/HtmlAdaptor" | grep -i '=Gen3' | grep -iv BigIpHealthCheckMbean | sed -e 's/^[^\"]*\"\([^\"]*\).*/\1/' | sed -e "s/&amp;/\&/g")
  for NAME in $NAMES; do
    functionCall $SERVER "$NAME" clearCodeCache "$OKSTR" || STATUS="$STATUS $NAME"
    sleep 1
    for CACHE in $CACHES; do
      functionCall $SERVER "$NAME" clearCache "$OKSTR" $CACHE || STATUS="$STATUS ${NAME}->${CACHE}"
      sleep 1
    done
  done
  [ -z "$STATUS" ] && echo -e "\e[3D: not supported" && continue
  STATUS=`echo $STATUS | tr -s ' ' '\n'`
  NALL=$(echo "$STATUS" | grep -cx "$INFUNC")
  STATUS=`echo "$STATUS" | grep -vx "$INFUNC"`
  NERR=$(echo "$STATUS" | wc -l)
  echo -ne "\e[3D: "
  [ -z "$STATUS" ] && echo "success($NALL/$NALL)" || echo "problem($NERR/$NALL): "$(echo "$STATUS" | sed -e 's/^.*=Gen3/Gen3/')
done
