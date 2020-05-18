#!/bin/bash
#

#
#
#
#

function startOrStopJob() {
#
#
  echo "$1" | grep -iq run && INDX=9
  echo "$1" | grep -iq stop && INDX=11
  [ -z "$INDX" ] && return 1
  /usr/bin/curl http://${SERVER}/jmx-console/HtmlAdaptor -d "action=invokeOp&name=accounttex2%3Aname%3DJobManager&methodIndex=$INDX&arg0=$3" 2>/dev/null | grep -q "Operation completed successfully without a return value"
}

ARCNUM=1 # default auto-restore-after-cycle
DATAFILE="/nas/utl/NOC/"`basename "$0"`
[ -f $DATAFILE ] && [ -r $DATAFILE ] || DATAFILE="$0"
grep -q "^<UploadCode>" "$DATAFILE" && sed -e "/^<UploadCode>/d" "$DATAFILE" | tee "$DATAFILE" > "$0" && chmod 750 "$0" && exec "$0"   # do we need chmod 750?
STOREDDATA=`cat "$DATAFILE"`
#
SERVERLIST='srwp01act002 srwp01act001'
for SERVER in $SERVERLIST; do
  TMPPAGESOURCE=`/usr/bin/curl "http://${SERVER}/jmx-console/HtmlAdaptor?action=inspectMBean&name=accounttex2%3Aname%3DJobManager" 2>/dev/null`
  echo "$TMPPAGESOURCE" | grep -q MaxConcurrentConsumers && STATUS=`echo -e $STATUS"\n"$SERVER` && PAGESOURCE=$TMPPAGESOURCE
done
echo -e "TABLE tblActJobStatus\nSTART_SAMPLE_PERIOD"
[ `echo "$STATUS" | grep -ci act` -eq 0 ] && echo -e "Host.String=\"\"\nMsgNum=2\nMsg.String=\"no available act jmx-console\"\nEND_SAMPLE_PERIOD\nEND_TABLE" && exit 2
[ `echo "$STATUS" | grep -ci act` -gt 1 ] && echo -e "Host.String=\"$STATUS\"\nMsgNum=3\nMsg.String=\"found act servers that are running: $STATUS, only one of them is supposed to be up\"\nEND_SAMPLE_PERIOD\nEND_TABLE" && echo -e "TABLE tblActJobStatus\nSTART_SAMPLE_PERIOD"
SERVER=`echo "$STATUS" | tail -1`
PAGESOURCE=`echo "$PAGESOURCE" | grep MaxConcurrentConsumers: | sed -e "s/<br>/\n/g" -e "s/[ \x09]//g" | sort`
JOBSTATUS=`echo "$PAGESOURCE" | sed -e "s/\(\w*\)(.*): \(\w*\).*/\1:\2/"`
ARCN=`echo "$STOREDDATA" | grep "^<AutoRestoreAfter:" | sed -e "s/^.*:\(.*\)>.*/\1/" | tr -cd 0-9-`
[ -z "$ARCN" ] && ARCN=$ARCNUM
WRONGSTATE=""
for STATUS in $JOBSTATUS; do
  JOBNAME=`echo $STATUS | cut -d: -f1`
  JOBSTATE=`echo $STATUS | cut -d: -f2`
#
  ! echo "$STOREDDATA" | grep -q "$JOBNAME" && STOREDDATA=`echo -e "$STOREDDATA\n$JOBNAME: $JOBSTATE"` && WFLAG=1 && continue # new job get added to the list.
  RIGHTSTATE=`echo "$STOREDDATA" | grep "$JOBNAME" | cut -d" " -f2`
  [ "$JOBSTATE" == "$RIGHTSTATE" ] && continue # current state matches expected state
  WRONGSTATE="${WRONGSTATE}***${JOBNAME} \t${JOBSTATE} (should be $RIGHTSTATE)\t"
  [ "$ARCN" -eq 0 ] && startOrStopJob $RIGHTSTATE $JOBNAME && [ $? -eq 0 ] && WRONGSTATE="${WRONGSTATE}auto restored to: $RIGHTSTATE\t"
done
[ -z "$WRONGSTATE" ] && STOREDDATA=`echo "$STOREDDATA" | sed -e "/^<AutoRestoreAfter:/d"`  # no job in wrong status, clear cycle control
[ "$ARCN" -eq 0 ] && STOREDDATA=`echo "$STOREDDATA" | sed -e "/^<AutoRestoreAfter:/d"`     # auto-restore triggerred, clear cycle control
[ "$ARCN" -gt 0 ] && let ARCN=ARCN-1 && STOREDDATA=`echo "$STOREDDATA" | sed -e "/^Control Section:/a <AutoRestoreAfter:$ARCN>"` # cycle-1
[ -n "$WFLAG" ] && echo "$STOREDDATA" > "$DATAFILE" && chmod 750 "$DATAFILE"
echo "Host.String=$SERVER"
[ -z "$WRONGSTATE" ] && echo -e "MsgNum=0\nMsg.String=\"no unexpected job state change\"\nEND_SAMPLE_PERIOD\nEND_TABLE" && exit 0
echo -e "MsgNum=1\nMsg.String=$WRONGSTATE\nEND_SAMPLE_PERIOD\nEND_TABLE"
exit 1




Control Section:
================
#
#
<UploadCode>
<AutoRestoreAfter:  -1234+567*890>




desired jobs status:
====================

jobs should be Running:
=======================
batchAggregatorJob: Running
batchCuttingJob: Running
batchTransmitJob: Running
ConfirmedDeliveredMainListenerContainer: Running
ConfirmedOnlyMainListenerContainer: Running
EventContingentMainListenerContainer: Running
fedexJob: Running
notifyPaymentCompletedSellerJob: Running
notifyPaymentFailedSellerJob: Running
notifyPaymentUnclaimedSellerJob: Running
OracleAqMessageListenerContainer: Running
PaymentExecuteMainListenerContainer: Running
paymentStatusRetrievalJob: Running
staleDataDetectJob: Running

jobs should be Stopped:
=======================
barcodeJob: Stoped
LMTJob: Stoped
pdfJob: Stoped
paperUKJob: Stoped

jobs can be either states:
==========================
jobname: Running|Stoped

New jobs auto added below:
==========================
