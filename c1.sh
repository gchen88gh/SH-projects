#!/bin/bash
#
#

cap inpool_out HOSTS=$1
sleep 60

cap stop:httpd HOSTS=$1

