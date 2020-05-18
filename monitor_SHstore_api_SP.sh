#!/bin/bash
#

function api_status()
{
  DEFAULTTOKEN='gWwh4zP4l90Cj4wQCslKHpB67_8a'
  for LINK in `egrep ^https?: $0 | sort -u | sed -e "s/ /+/g"`; do
    URL=`echo "$LINK" | cut -d'|' -f1`
    TOKEN=`echo "$LINK" | cut -d'|' -f2`
    NAME=`echo "$LINK" | cut -d'|' -f3 | sed -e "s/+/ /g"`
    MSG=`curl -v -k -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Accept-Language: en-US" -X GET "$URL" 2>&1 | egrep '[<{(]'`
##  STATUS=`curl -v -k -H "Authorization :Bearer $TOKEN" -H "Accept: application/json" "$URL" 2>&1 | grep 'HTTP' | grep "<" | head -1 | sed -e "s/^.*<//"`
    STATUS=`echo "$MSG" | grep -m 1 'HTTP' | sed -e "s/^.*< //" -e "s/.$//"`
#
    CURLMSG=`echo "$MSG" | grep 'curl' | sed -e 's/^[^)]*)//' -e 's/,.*$//'`
    printf "%23s:%s%s\n" "$NAME" "$STATUS" "$CURLMSG"
    echo "$STATUS" | grep -q "200 OK" && continue
    logger "nocscript=`basename $0` api_name=\"$NAME\" api_call_status=\"$STATUS$CURLMSG\""
  done
}
TITLE="Issue - Global Registry API Enhancements for SHStore [NOC-434]"
STATUS=$(api_status)
echo "$STATUS"
#
exit

https://api.myweb.com/i18n/shstoreresolution/v1/?region=us|gWwh4zP4l90Cj4wQCslKHpB67_8a|SH-Store Resolution API
https://api.myweb.com/i18n/globalregistry/v2/shstores/1|gWwh4zP4l90Cj4wQCslKHpB67_8a|Global Registry V2 API
https://api.myweb.com/i18n/localefallback/v1/|gWwh4zP4l90Cj4wQCslKHpB67_8a|Locale Fallback API
