#!/bin/bash
#
DEFAULTTOKEN='khid4rHY6kF8k3YCHPQGMkdBfL8a'
for LINK in `grep ^https $0 | sort -u | sed -e "s/ /+/g"`; do
  URL=`echo "$LINK" | cut -d'|' -f1`
  TOKEN=`echo "$LINK" | cut -d'|' -f2`
  NAME=`echo "$LINK" | cut -d'|' -f3 | sed -e "s/+/ /g"`
  MSG=`curl -v -k -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" "$URL" 2>&1 | egrep '[<{]'`
##  STATUS=`curl -v -k -H "Authorization :Bearer $TOKEN" -H "Accept: application/json" "$URL" 2>&1 | grep 'HTTP' | grep "<" | head -1 | sed -e "s/^.*<//"`
  STATUS=`echo "$MSG" | grep -m 1 'HTTP' | sed -e "s/^.*<//" -e "s/.$//"`
  MSG=`echo "$MSG" | grep 'message' | sed -e 's/^.*message":/ - /' -e 's/,.*$//'`
  printf "%31s:%s%s\n" "$NAME" "$STATUS" "$MSG"
done
exit

https://api.myweb.com/recommendations/eventrecommendations/v1/?genreId=197&algorithm=BOUGHT_ALSO_BOUGHT|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-EventRecommendations
https://api.myweb.com/inventory/listings/v1/1164638718|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-InventoryListing
#
https://api.myweb.com/inventory/listings/v1/1094356059|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-InventoryListing-gchen
#
https://api.myweb.com/user/customers/v1/6C21FFA3FFE83BC0E04400144FB7AAA6/paymentInstruments|9fffd5e35659dc814c48fa0d6f974d4|Customer PaymentInstruments
https://api.myweb.com/user/customers/v1/6C21FFA3FFE83BC0E04400144FB7AAA6/discounts/338276710|9fffd5e35659dc814c48fa0d6f974d4|Customer Discount
https://api.myweb.com/user/customers/v1/6C21FFA3FFE83BC0E04400144FB7AAA6/contacts|9fffd5e35659dc814c48fa0d6f974d4|Customers Contacts
https://api.myweb.com/catalog/events/v1/4270604/metadata/inventoryMetaData|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-Catalog InventoryMetaData
https://api.myweb.com/search/inventory/v1/?eventId=9160059&_type=json&pricingSummary=true&zonestats=true&sectionstats=true|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-Search SectionStats
https://api.myweb.com/search/inventory/v1/sectionsummary/?eventId=9075847|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-Search SectionSummary
https://api.myweb.com/catalog/venues/v1/83/venueConfig/470672/2d/metadata?venueConfigVersion=1|khid4rHY6kF8k3YCHPQGMkdBfL8a|API-Catalog VenueConfigVersion
https://api.braintreegateway.com/merchants/StubHubBTAcct/ping||API-braintreegateway
https://api-int.myweb.com/tns/userRiskVerification/v1/phonevalidationinfo/16173143746|gWwh4zP4l90Cj4wQCslKHpB67_8a|API-Risk PhoneValidationInfo
https://api.myweb.com/accountmanagement/listings/v1/seller/6C21FFEE4DFA3BC0E04400144FB7AAA6?rows=200&start=400|fcc218ab0bceb498256d5e678ceac59|API-AccountManagement TT-Seller
