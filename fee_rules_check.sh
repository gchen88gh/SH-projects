#!/bin/bash
#### Usage: $0 id...
#### Returns total buy fee of given eventIDs and/or listingIDs.
#### Example: $0 9037781 1110825813 1116159825
#### Wiki: https://wiki.myweb.dev/display/NOC/How+To+Verify+Fees+After+ILG+%28ilog%29+Ruleset+Deployment

. ~gchen1/scripts/basic_func.sh &>/dev/null

function extractMessage()
{
  local MSGS=$1 KEYWORD=$2
  echo "$MSGS" | grep "$KEYWORD" | sed -e "s/^.*${KEYWORD}.:.//" -e 's/.,.*$//'
}

[ $# -eq 0 ] && usage && exit 1
[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1

listingBODY='
{
  "buyerCostRequest":
  {
    "listingId":1116159825,
    "quantity":2
  }
}
'

eventBODY='
{
  "priceRequestList": {
    "priceRequest": [
      {
        "requestKey": "12",
        "eventId": "9131045",
        "amountPerTicket": {
          "amount": "100",
          "currency": "USD"
        },
        "amountType": "LISTING_PRICE",
        "fulfillmentType": "BARCODE",
        "predeliveryType": "PREDELIVERY",
        "section": "Lower box 101",
        "row": "2",
        "listingSource": "INDY",
        "sellerPaymentType": "PAYPAL",
        "listingCreatedDate": "2013-12-06",
        "includePayout": "true",
        "adjustToMinListPrice": "true"
      }
    ]
  }
}
'

eventURL='https://api.myweb.com/pricing/aip/v1/price'
listingURL='https://api.myweb.com/pricing/aip/v1/buyercost'

#
TOKEN='9fffd5e35659dc814c48fa0d6f974d4'

for IDNUMBER in $*; do
  echo $IDNUMBER | egrep -q "^[0-9]+$" || continue
  [ ${#IDNUMBER} -ge 9 ] && TYPE=listing || TYPE=event
  eval BODY='$'${TYPE}BODY URL='$'${TYPE}URL
  BODY=$(echo "$BODY" | sed -e "s/Id\":.*/Id\": \"$IDNUMBER\",/")
  for CURRENCY in USD GBP; do
    BODY=$(echo "$BODY" | sed -e "s/\"currency\":.*/\"currency\": \"$CURRENCY\"/")
    for METHOD in PDF BARCODE; do
      BODY=$(echo "$BODY" | sed -e "s/\"fulfillmentType\":.*/\"fulfillmentType\": \"$METHOD\",/")
      RETMSG=$(/usr/bin/curl -v -k -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" -d "$BODY" "$URL" 2>&1)
      BUYFEE=$(echo "$RETMSG" | egrep -o "totalBuyFee[^,]*" | cut -d: -f3)
      [ -n "$BUYFEE" ] && break 2
    done
  done
  printf "%7sID: %-11d" "$TYPE" $IDNUMBER
  [ -n "$BUYFEE" ] && echo " totalBuyFee: $BUYFEE $CURRENCY" || echo ' '`extractMessage "$RETMSG" type` - `extractMessage "$RETMSG" message`
done
exit

ID=9037812 9037774 9037941 9037814 9037692 9037709 9037790 9037741 9037745 9037877 9037719 9037781 9106795 1110825813 1116159825

{"priceResponseList":{"priceResponse":[{"errors":[{"type":"INPUTERROR","code":"INVALID_FULFILLMENT_METHOD","message":"Requested fulfillment Type and predelivery type combination is not supported","parameter":"fulfillment type and predelivery type not supported"}],"requestKey":"12"}]}}

{"buyerCostResponse":{"errors":[{"type":"INPUTERROR","code":"GET_LISTING_ERROR","message":"Listing not active or expired","parameter":"listingId"}]}}

