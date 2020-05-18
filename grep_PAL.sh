##tempstr=$(curl -s -k --user gchen1:71Z902jy6 "https://wiki.myweb.dev/display/PAL/PAL+-+Production+Activities+Log" | egrep '[0-9][0-9]?\/[0-9][0-9]?\/201[0-9]')
##echo $tempstr | sed -e "s/\([0-9][0-9]\/[0-9][0-9]\/201[0-9]\)/\n\1/g" | sed -e "s/<span .*\b\(\w\w*\)-\([0-9][0-9]*\)[^>]*>/\1-\2/" | sed -e "s/<[^>]*>//g" | egrep '[0-9][0-9]?\/[0-9][0-9]?\/201[0-9]' > $0.log

#


tempstr=$(cat wafblocklist.html)
echo $tempstr | sed -e 's/<\/td><\/tr><tr><td>/\n/g' -e 's/<\/td><td>/##GCHEN##/g;s/&nbsp;//g;s/ *##GCHEN##/##GCHEN##/g;s/##GCHEN## */|/g' > tt
