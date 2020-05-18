#!/bin/bash
#
#
CAPCONFIG=/nas/utl/presidio/capconfig

[ -n "$1" ] && filter="$1" || filter='.'

if [ ! -d $CAPCONFIG ]; then
  printf "No capconfig directory found.  You need to have a link to /nas/utl/capconfig named capconfig in your home directory for this script to work\n"
  exit 1
fi

grep "server" ${CAPCONFIG}/*.rb | grep -v "^#" | grep -v localhost | sed 's/,/ /g' | sed 's/\"//g' | tr -s ' ' '\n' | grep -v "^:" |grep "^...." | grep -v role | grep "$filter" |sort -u
