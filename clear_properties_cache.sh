#!/bin/bash
#
#
#
#

function clearCache()
{
  /usr/bin/curl --user $USER:$PASSCODE http://$1/jmx-console/HtmlAdaptor -d "action=invokeOp&name=$NAME%3Aname%3DStubHub+Properties&methodIndex=$INDX" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

! grep -q "$1_NAMES" $0 && echo "Clearing cache on $1 is not supported, quitting." && exit 2
#
LIST=`/nas/utl/NOC/lhosts_srwp01.sh "$1"`
[ -z "$LIST" ] && echo "no available blade to clear cache on, quitting." && exit 1
job_NAMES="Stubhub-Properties-StubhubJobs"
brx_NAMES="Stubhub-Properties-StubhubBRXRole Stubhub-Properties-EventApp"
myx_NAMES="Stubhub-Properties-PreferenceAPI Stubhub-Properties-StubhubMYXRole"
byx_NAMES="Stubhub-Properties-CheckoutApp"
slx_NAMES="Stubhub-Properties-StubhubSLXRole Stubhub-Properties-UploadApp"
sli_NAMES="Stubhub-Properties-SellListener"
stj_NAMES="Stubhub-Properties-CSToolApp Stubhub-Properties-SecureCSToolApp"

#
#
INDX=1 # clear properity cache
#
eval NAMES='$'$1_NAMES

USER=`whoami`
read -p "Enter host password for user '$USER': " -s PASSCODE
echo

for SERVER in $LIST; do
  echo -n "clearing cache on ${SERVER}..."
  STATUS=""
  for NAME in $NAMES; do
    clearCache $SERVER $NAME $INDX || clearCache $SERVER.myweb.com $NAME $INDX || STATUS=`echo "$STATUS $PRE$NAME"`
    sleep 5
  done
  [ -z "$STATUS" ] && echo "done" || echo "problem:$STATUS"
done
