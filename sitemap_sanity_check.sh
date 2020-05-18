#!/bin/bash
#
cd /nas/html/myweb
for COUNTRY in `ls -d ??`; do
#
  cd "$COUNTRY"
#
#
  for INDEXFILE in `ls -1 sitemap-*-index.xml 2>/dev/null`; do
    CLCODE=$(echo $INDEXFILE | cut -d- -f2,3)
#
    LOCFILES=$(cat $INDEXFILE | sed -e "s/loc/\n/g" | grep "$CLCODE" | sed -e "s/^.*\/\(${CLCODE}-.*\.xml\).*/\1/" | sort -u)
#
#
    DISKFILES=$(ls -1 ${CLCODE}-*.xml)
#
#
    FILES='';STATUS1=''
    for LOCFILE in $LOCFILES; do
      echo "$DISKFILES" | grep -q $LOCFILE && continue
      FILES=$(echo $FILES'| '$LOCFILE)
    done
    [ -n "$FILES" ] && STATUS1="Mentioned in <loc> but no corresponding disk file: $FILES"
    FILES='';STATUS2=''
    for DISKFILE in $DISKFILES; do
      echo "$LOCFILES" | grep -q $DISKFILE && continue
      FILES=$(echo $FILES'| ' $DISKFILE)
    done
    [ -n "$FILES" ] && STATUS2="Disk file exists but not mentioned in <loc>: $FILES"

    [ -z "$STATUS1" ] && [ -z "$STATUS2" ] && continue
    STATUS=$(echo $STATUS'|'Folder: $COUNTRY'|'Index file: $INDEXFILE'|-----------------------------------')
    [ -n "$STATUS1" ] && STATUS=$(echo $STATUS'|'$STATUS1'|')
    [ -n "$STATUS2" ] && STATUS=$(echo $STATUS'|'$STATUS2'|')
    STATUS=$(echo $STATUS'|')
  done
  cd - &>/dev/null
done
STATUS=$(echo $STATUS | sed -e "s/|/\n/g")
TITLE="Unified Sitemap Job Sanity Check Results - "
[ -z "$STATUS" ] && STATUS='All good' && TITLE="${TITLE}Success" || TITLE="${TITLE}Failure"
echo "$STATUS" | mail -s "$TITLE" gchen1@myweb.com bilchen@myweb.com jekong@myweb.com rkumaradhev@myweb.com ngadkari@ebay.com kabburi@ebay.com
#
