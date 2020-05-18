#!/bin/bash 
export PATH=$PATH:/opt/java/bin
cd $1 &>/dev/null
shift
[ -f "$1" ] && ids=`sudo cat "$1"` && shift
ids="$ids $@"
ids=$(echo "$ids" | tr -s ', \n\t' ' ')
for id in $ids; do
echo -n "repush BuyerOrderId=$id, "
echo $id | egrep -q "[^0-9]" && echo "non-numeric id, skipped" && continue
#
outcome=$(java -jar /nas/utl/bin/mq.jar -u 'failover:(tcp://lvsp01mqm001.myweb.com:61616,tcp://lvsp01mqm001.myweb.com:61616)?randomize=false&maxReconnectAttempts=1&jms.redeliveryPolicy.maximumRedeliveries=99&jms.redeliveryPolicy.initialRedeliveryDelay=600000&jms.prefetchPolicy.all=1' -q domain.accountmanagement.orderLifeCycle.fraudEvaluation -o -c com.myweb.domain.tns.services.fraudpreventionservices.v1.intf.response.FraudEvaluationResponse -O '{"id":'$id',"totalscore":10000,"reviewholdtime":54000,"status":"Accepted","securityValidationFailed":false,"retryReason":"Unknown_Error_Retry"}')
[ `echo "$outcome" | grep -ci succ` -eq 3 ] && echo "$outcome" | grep -q _status=OK && echo "ok" || echo "error"
done
