#!/bin/bash
function func_filter() {
#
#
  /usr/bin/curl "http://$1/jmx-console/" 2>/dev/null | grep -q FilterView && sed -ne "/$2/,/submit/p" || grep -B5 "$2"
}

function func_call() {
#
  [ -z "$4" ] && _FUNCPOS=1 || _FUNCPOS=$4
  _PAGESOURCE=`/usr/bin/curl "http://$1/$2" 2>/dev/null | func_filter $1 $3`
  _METHODNAME=`echo "${_PAGESOURCE}" | grep "name=.name" | sed -e "s/.*value='\(.*\)'.*/\1/" | sed -n ${_FUNCPOS}p | sed -e s/:/%3A/g | sed -e s/=/%3D/g`
  _METHODINDEX=`echo "${_PAGESOURCE}" | grep "methodIndex" | sed -e "s/.*value=.\([0-9]*\).*/\1/" | sed -n ${_FUNCPOS}p`
echo 'action=invokeOp&name='${_METHODNAME}'&methodIndex='$_METHODINDEX
  echo "`date` --- func_call $1 $2 $3 $4 --- action=invokeOp&name=${_METHODNAME}&methodIndex=$_METHODINDEX" >> $0.log
  /usr/bin/curl http://$1/jmx-console/HtmlAdaptor -d 'action=invokeOp&name='${_METHODNAME}'&methodIndex='$_METHODINDEX 2>/dev/null | tee -a $0.log
#
}
SERVER='srwp01abi001.myweb.com'
SERVER='srwp01api001.myweb.com'
#
URL='jmx-console/HtmlAdaptor?action=inspectMBean&name=autobulklite%3Aname%3DSupportTools'
URL='jmx-console/HtmlAdaptor?action=inspectMBean&name=Stubhub-Properties-StubHubAPI%3Aname%3DStubHub+Properties'
#
#
#
#
FUNCTIONNAME='viewStaleDataReport'
FUNCTIONNAME='refreshProperties'
#
#
#
FUNCTIONPOS=1
echo $SERVER
echo $URL
echo $FUNCTIONNAME
/usr/bin/curl "http://${SERVER}/jmx-console/" 2>/dev/null | grep -q FilterView && echo "new frame view" || echo "old Node view"

func_call $SERVER $URL $FUNCTIONNAME > /dev/null
