#!/bin/bash
#
#

cap start:httpd HOSTS=$1

cap inpool_in HOSTS=$1

cap checkup:health HOSTS=$1
