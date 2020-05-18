#!/bin/bash
ALLAGENTS=`ps -ef | grep fog | grep -v grep | sed "s/^.* \(.*\)_on_.*/\1/"`
echo "`hostname`: $((`echo "$ALLAGENTS" | wc -l` - `echo "$ALLAGENTS" | sort -u | wc -l`))"
