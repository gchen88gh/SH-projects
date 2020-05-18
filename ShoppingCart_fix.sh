#!/bin/bash
#
#
TARGET_HOST=myweb
options_found=0
Bearer=gWwh4zP4l90Cj4wQCslKHpB67_8a
#

function purchased ()
{
for i in $order;do 
echo  "OrderId:" $i;
curl -i -k -X POST -H "Authorization: Bearer $Bearer" -H "Content-Type: application/json" -H "X-SH-Service-Context:{role=R1, operatorId=, proxiedId=C779915579FB5E14E04400212861B256}" -d '{"orderStatus":"Purchased"}' https://api-int.$TARGET_HOST.com/accountmanagement/orderdetails/v3/$i 2>&1 | grep -E 'OrderId|HTTP/1.1'; echo -e "" ; done
   EXIT=$?
}

function Approved ()
{
for i in $order;do
echo  "OrderId:" $i;
curl -i -k -X POST  -H "Authorization: Bearer $Bearer" -H "Content-Type: application/json" -H "X-SH-Service-Context:{role=R1, operatorId=, proxiedId=C779915579FB5E14E04400212861B256}" -d '{"orderStatus":"Approved"}'  https://api-int.$TARGET_HOST.com/accountmanagement/orderdetails/v3/$i 2>&1 | grep -E 'OrderId|HTTP/1.1' ; echo -e "" ; done
     EXIT=$?
}

function Confirmed ()
{
for i in $order;do
echo  "OrderId:" $i;
curl -i -k -X POST  -H "Authorization: Bearer $Bearer" -H "Content-Type: application/json" -H "X-SH-Service-Context:{role=R1, operatorId=, proxiedId=C779915579FB5E14E04400212861B256}" -d '{"saleSubStatus":"4"}'  https://api-int.$TARGET_HOST.com/accountmanagement/saledetails/v3/$i 2>&1 | grep -E 'OrderId|HTTP/1.1'  ; echo -e "" ; done
     EXIT=$?
}

function Skip ()
{
for i in $order;do
echo  "OrderId:" $i;
curl -i -k -X POST -H 'Authorization: Bearer 6c75a42b5e4818982e59d975b3a5eb3' -H 'Accept: application/json' -H "Content-type: application/json" -d '{
"transaction-results": {
"transaction-id": '"$i"',
"rules-tripped": "5237260000000756657:shT_BuyerName_Fraud-Reject:5500",
"total-score": 5500,
"recommendation-code": "Reject",
"remarks": "AT:  9/14/16 12:07:34 PM PDT\nBUSINESS PROCESS:  1\nSCORE:  5,500\nUSER:  byron lanuza\nRESOLUTION:  Test Accept\nNOTES:  \n\n\n####################\n\nAT:  8/31/16 8:35:01 AM PDT\nBUSINESS PROCESS:  1\nSCORE:  5,500\nUSER:  miboyer\nRESOLUTION:  Cancelled - non fraud\nNOTES:  Test order.\n\n\n####################",
"responseData": {
"transaction": {
"transaction-details": [{}, {}, {}]
}
}
}
}' https://orderreview.myweb.com/tns/fraudOrderReview/v2/orderReview 2>&1 | grep -E 'OrderId|HTTP/1.1' ;echo -e ""; done
    EXIT=$?
}

function disply_help ()
{
echo "
Usage: ShoppingCart_fix.sh [options] Order list file ...

-p, purchased	 for orders stuck in "Purchased" status
-a, Approved	 for orders stuck in "Approved" status
-c, Confirmed	 for sales stuck in "Confirmed" status
-s, Skip Fraud   to SKIP Fraud process and send a message back to Account Management Fraud Prevention listener
-h, Help 	 for help

eg. 
sh ShoppingCart_fix.sh -a orders

format for Order list file 

390874
390873
350994
350990
380943
370994
370993
370989
350918
370917
370914
350986
350891
390759
350941
350940
350985
350955
350945
350944
350943
"
EXIT=$?

}
while getopts ":a:p:c:s:h:" opt; do
  options_found=1
  case $opt in
    p)
     order=$(cat $2)
     purchased
      ;;
    a)
     order=$(cat $2)
     Approved
     ;;
    c)
     order=$(cat $2)
     Confirmed
     ;;
    s)
     order=$(cat $2)
     Skip
     ;;
    h)
     disply_help
     ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
     disply_help
#
#
      ;;
  esac
done

if ((!options_found)); then
  echo "no options found, please use -h for help"
fi
