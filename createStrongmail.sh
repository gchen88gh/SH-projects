[ -f "$1" ] && OIDS=`cat "$1"` && shift
OIDS="$OIDS $@"
echo "Creating StrongMail..."
for OID in $OIDS; do
  echo $OID | egrep -q "^[0-9]+$" && curl -s -d "emailName=TEB_ORDER_PLACED&orderId=$OID" http://gen3.jobs.myweb.com/strongmail/sendmail && echo
done
echo Done
