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

function clearCache()
{
  [ -z "$4" ] && ARG0="" || ARG0="&argType=java.lang.String&arg0=${CACHE}"
  /usr/bin/curl --user `whoami`:"$PASSCODE" "http://$1/jmx-console/HtmlAdaptor?action=invokeOpByName&name=$PRE$NAME&methodName=${METHODNAME}${ARG0}" 2>/dev/null | egrep -q "Operation completed successfully without a return value|OK"
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 2
[ $# -lt 1 ] && usage && exit 2

##! grep -q "^$1_NAMES" $0 && echo "Clearing cache on $1 is not supported, quitting." && exit 2
##. ~gchen1/scripts/get_Green_Blade.sh "$1" "srw"
##SERVERS=$LIST
#
. /nas/home/gchen1/scripts/get_hosts.sh $1

SUPPORTED=`grep '^..._NAMES=' $0 | sed -e "s/^\([^_]*\).*$/\1/"`
SUPPORTED=`echo $SUPPORTED | sed -e 's/ /|/g'`
[ -n "$SERVERS" ] && UNSUPPORTED=`echo "$SERVERS" | egrep -v "$SUPPORTED" | sed -e "s/^[a-z]*[0-9]*\([a-z]*\).*/\1 is not supported/" | sort -u`
[ -n "$UNSUPPORTED" ] && echo "$UNSUPPORTED"
SERVERS=`echo "$SERVERS" | egrep "$SUPPORTED"`
[ -z "$SERVERS" ] && echo "No supported blade found to clear cache on, quitting." && exit 1
showServers
authenticationTest

abi_NAMES="sh-ecomm-ears-abiprocessear%3Aname%3DCentralizedMbean"
apx_NAMES="Codes-OrderReview%3Aname%3DGen3+CacheManager sh-ecomm-ears-orderreviewear%3Aname%3DCentralizedMbean"
byx_NAMES="Codes-CheckoutApp%3Aname%3DGen3+CacheManager buy-services-webapp:name=CentralizedMbean buyercosts-services-webapp:name=CentralizedMbean sh-ecomm-ears-byxear:name=CentralizedMbean"
ilg_NAMES="Codes-StubhubRulesApps%3Aname%3DGen3+CacheManager sh-ecomm-ears-ilgbigear%3Aname%3DCentralizedMbean"
job_NAMES="Codes-StubHubJob%3Aname%3DDedicated+SRWP+Gen3+CacheManager Codes-StubHubJob%3Aname%3DShared+Gen3+CacheManager Codes-StubhubJobs%3Aname%3DGen3+CacheManager sh-ecomm-ears-dedicatedjobsear%3Aname%3DCentralizedMbean sh-ecomm-ears-jobbigear%3Aname%3DCentralizedMbean sh-ecomm-ears-sharedjobsear%3Aname%3DCentralizedMbean"
lgi_NAMES="Codes-BuyAPI%3Aname%3DGen3+CacheManager sh-ecomm-ears-fulfillmentsvcear%3Aname%3DCentralizedMbean"
sli_NAMES="Codes-SellListener%3Aname%3DGen3+CacheManager sh-ecomm-ears-selllistenerear%3Aname%3DCentralizedMbean sh-ecomm-ears-lombardibridgeear%3Aname%3DCentralizedMbean"
stj_NAMES="Codes-CSToolApp%3Aname%3DGen3+CacheManager Codes-SecureCSToolApp%3Aname%3DGen3+CacheManager sh-ecomm-ears-cstoolear%3Aname%3DCentralizedMbean sh-ecomm-ears-securecstoolear%3Aname%3DCentralizedMbean"
slx_NAMES="Codes-StubhubSLXRole%3Aname%3DGen3+CacheManager Codes-UploadApp%3Aname%3DGen3+CacheManager sh-ecomm-ears-slxbigear%3Aname%3DCentralizedMbean sh-ecomm-ears-uploadear%3Aname%3DCentralizedMbean"
myx_NAMES="Codes-StubhubMYXRole%3Aname%3DGen3+CacheManager sh-ecomm-ears-myxbigear:name=CentralizedMbean Codes-preferenceAPI%3Aname%3DGen3+CacheManager sh-ecomm-ears-preferencesvcear%3Aname%3DCentralizedMbean"
brx_NAMES="Codes-EventApp Codes-StubhubBRXRole%3Aname%3DGen3+CacheManager sh-ecomm-ears-brxbigear:name=CentralizedMbean sh-ecomm-ears-eventear%3Aname%3DCentralizedMbean"

PRE="Gen3-"
##eval NAMES='$'$1_NAMES

shift
CACHES=$(echo "$*" | tr -s ', ' ' ')

for SERVER in $SERVERS; do
  echo -n "clearing code cache on ${SERVER}..."
  ! isJmxUp $SERVER && echo "jmx unavailable" && continue
  STATUS=""
  eval NAMES='$'${SERVER:6:3}_NAMES
  for NAME in $NAMES; do
    METHODNAME='clearCodeCache'
    clearCache $SERVER.myweb.com $NAME $METHODNAME || STATUS=`echo "$STATUS $NAME"`
#
    METHODNAME='clearCache'
    for CACHE in $CACHES; do
      clearCache $SERVER.myweb.com $NAME $METHODNAME $CACHE || STATUS=`echo "$STATUS ${NAME}->${CACHE}"`
#
      sleep 2
    done
  done
  echo -ne "\e[3D: "
  [ -z "$STATUS" ] && echo "done" || echo "problem:$STATUS"
done
