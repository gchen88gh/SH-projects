#!/bin/bash
#
LIST='srwp01act002 srwp01act001'
for SERVER in $LIST; do
  PAGESOURCE=`/usr/bin/curl "http://${SERVER}/jmx-console/HtmlAdaptor?action=inspectMBean&name=accounttex2%3Aname%3DJobManager" 2>/dev/null`
  echo $PAGESOURCE | grep -q MaxConcurrentConsumers && break
  PAGESOURCE=""
done
echo -e "TABLE tblActJobStatus\nSTART_SAMPLE_PERIOD"
[ -z "$PAGESOURCE" ] && echo -e "Host.String=\"\"\nMsgNum=2\nMsg.String=\"no available act jmx-console\"\nEND_SAMPLE_PERIOD\nEND_TABLE" && exit 2
PAGESOURCE=`echo "$PAGESOURCE" | grep MaxConcurrentConsumers: | sed -e "s/[ \x09]//g" -e "s/<br>/\n/g" | sort`
JOBSTATUS=`echo "$PAGESOURCE" | sed -e "s/\(\w*\)(.*):\(\w*\).*/\1:\2/"`
DATAFILE="/nas/utl/NOC/"`basename $0`
[ -f $DATAFILE ] && [ -r $DATAFILE ] || DATAFILE=$0
STOREDDATA=`cat $DATAFILE`
WRONGSTATE=""

for STATUS in $JOBSTATUS; do
  JOBNAME=`echo $STATUS | cut -d: -f1`
  JOBSTATE=`echo $STATUS | cut -d: -f2`
  ! echo "$STOREDDATA" | grep -q "$JOBNAME" && echo $JOBNAME: $JOBSTATE>>$DATAFILE && continue # new job get added to the list.
  echo "$STOREDDATA" | grep "$JOBNAME" | grep -q "$JOBSTATE" && continue # check if current state matches expected state
#
  WRONGSTATE="${WRONGSTATE}***${JOBNAME} \t${JOBSTATE} (should be$(grep $JOBNAME $DATAFILE | cut -d: -f2))\t"
done
echo "Host.String=$SERVER"
[ -z "$WRONGSTATE" ] && echo -e "MsgNum=0\nMsg.String=\"no unexpected job state change\"\nEND_SAMPLE_PERIOD\nEND_TABLE" && exit 0
#
echo -e "MsgNum=1\nMsg.String=$WRONGSTATE\nEND_SAMPLE_PERIOD\nEND_TABLE"
exit 1


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
fedexJob: Stoped

jobs can be either states:
==========================
jobname: Running|Stoped

New jobs auto added below:
==========================
