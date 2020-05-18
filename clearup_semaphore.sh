#!/bin/bash
#
#

cap inpool_out HOSTS=$1
sleep 60

cap stop:httpd HOSTS=$1

#

cap start:httpd HOSTS=$1

cap inpool_in HOSTS=$1

cap checkup:health HOSTS=$1
