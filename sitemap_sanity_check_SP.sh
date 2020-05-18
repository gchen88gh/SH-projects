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
    LFILES=''
    for LOCFILE in $LOCFILES; do
      echo "$DISKFILES" | grep -q $LOCFILE && continue
      LFILES=$(echo $LFILES'|'$LOCFILE)
    done
#
#
#
    DFILES=''
    for DISKFILE in $DISKFILES; do
      echo "$LOCFILES" | grep -q $DISKFILE && continue
      DFILES=$(echo $DFILES'|'$DISKFILE)
    done
    STATUS="Failure"
#
    [ -z "$LFILES" ] && [ -z "$DFILES" ] && STATUS="All Good"
    logger "nocscript=sitemap_sanity_check_SP.sh Locale=$CLCODE Message=\"$STATUS\" lfile=\"$LFILES\" dfile=\"$DFILES\""

#
#
#
#
#
  done
  cd - &>/dev/null
done
STATUS=$(echo $STATUS | sed -e "s/|/\n/g")
TITLE="Unified Sitemap Job Sanity Check Results - "
[ -z "$STATUS" ] && STATUS='All good' && TITLE="${TITLE}Success" || TITLE="${TITLE}Failure"
#
#
