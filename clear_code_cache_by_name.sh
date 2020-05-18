#!/bin/bash
#### Usage: $0 pool_name cache_name...
#### Clear code cache by specifying the cache names on command line. 
#### Example: $0 ilg FulfillmentMethodWindowDAOImpl.findById
####          $0 byx com.myweb.business.manager.CodesMgr FeesAdapterDAOImpl.findByLocation
#### Wiki: https://wiki.myweb.com/display/NOC/How+To+Clear+Code+Cache+for+Fee+Changes
#
#
#

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function getPass()
{
read -p "Enter host password for user '`whoami`': " -s PASSCODE
echo
}

function isLogonFailed()
{
  /usr/bin/curl --user `whoami`:"$PASSCODE" http://$1.myweb.com/jmx-console/ 2>/dev/null | grep -q "This request requires HTTP authentication" && return 0
#
  return 1
}

function clearCache()
{
  [ -z "$4" ] && ARG0="" || ARG0="&arg0=${CACHE}"
  /usr/bin/curl --user `whoami`:"$PASSCODE" http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=$PRE$NAME&methodIndex=${INDX}${ARG0}" 2>/dev/null | egrep -q "Operation completed successfully without a return value|OK"
}

[ $# -lt 2 ] && usage && exit 2

#

! grep -q "^$1_NAMES" $0 && echo "Clearing cache on $1 is not supported, quitting." && exit 2
#
. ~gchen1/scripts/get_Green_Blade.sh "$1" "srw"
#
[ -z "$LIST" ] && echo "no available blade to clear cache on, quitting." && exit 1

getPass
isLogonFailed $LIST && echo "Authentication failed, quitting." && exit 1

abi_NAMES="sh-ecomm-ears-abiprocessear%3Aname%3DCentralizedMbean|5,2"
apx_NAMES="Codes-OrderReview%3Aname%3DGen3+CacheManager|2,5 sh-ecomm-ears-orderreviewear%3Aname%3DCentralizedMbean|5,2"
byx_NAMES="Codes-CheckoutApp%3Aname%3DGen3+CacheManager|2,5 buyercosts-services-webapp:name=CentralizedMbean|5,2 sh-ecomm-ears-byxear:name=CentralizedMbean|5,2"
ilg_NAMES="Codes-StubhubRulesApps%3Aname%3DGen3+CacheManager|2,5"
job_NAMES="Codes-StubHubJob%3Aname%3DDedicated+SRWP+Gen3+CacheManager|2,5 Codes-StubHubJob%3Aname%3DShared+Gen3+CacheManager|2,5 Codes-StubhubJobs%3Aname%3DGen3+CacheManager|2,5 sh-ecomm-ears-dedicatedjobsear%3Aname%3DCentralizedMbean|5,2 sh-ecomm-ears-jobbigear%3Aname%3DCentralizedMbean|5,2 sh-ecomm-ears-sharedjobsear%3Aname%3DCentralizedMbean|5,2"
lgi_NAMES="Codes-BuyAPI%3Aname%3DGen3+CacheManager|2,5 sh-ecomm-ears-fulfillmentsvcear%3Aname%3DCentralizedMbean|9,2"
sli_NAMES="Codes-SellListener%3Aname%3DGen3+CacheManager|2,5 sh-ecomm-ears-selllistenerear%3Aname%3DCentralizedMbean|5,2"
stj_NAMES="Codes-CSToolApp%3Aname%3DGen3+CacheManager|2,5 Codes-SecureCSToolApp%3Aname%3DGen3+CacheManager|2,5 sh-ecomm-ears-cstoolear%3Aname%3DCentralizedMbean|5,2 sh-ecomm-ears-securecstoolear%3Aname%3DCentralizedMbean|5,2"

PRE="Gen3-"
eval NAMES='$'$1_NAMES

shift
CACHES="$@"

for SERVER in $LIST; do
  echo -n "clearing specified cache on ${SERVER}..."
  STATUS=""
  for NAME in $NAMES; do
    INDS=`echo $NAME | cut -d"|" -f2`
    NAME=`echo $NAME | cut -d"|" -f1`
    INDX=`echo $INDS | cut -d"," -f1`
    clearCache $SERVER $NAME $INDX || clearCache $SERVER.myweb.com $NAME $INDX || STATUS=`echo "$STATUS $NAME"`
#
    INDX=`echo $INDS | cut -d"," -f2`
    for CACHE in $CACHES; do
      clearCache $SERVER $NAME $INDX $CACHE || clearCache $SERVER.myweb.com $NAME $INDX $CACHE || STATUS=`echo "$STATUS ${NAME}@${CACHE}"`
#
      sleep 2
    done
  done
  [ -z "$STATUS" ] && echo "done" || echo "problem:$STATUS"
done
