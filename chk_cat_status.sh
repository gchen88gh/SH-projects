#!/bin/bash
#
[ -e ~/tmp/status_output ] && rm ~/tmp/status_output
curl http://srwq09cat001.srwq09.com:8080/catalog/shdatapush/v1/system/status > ~/tmp/status_output

system_switch=`sed -e "s/.*Switch\"\:\"\(..\).*/\1/" ~/tmp/status_output`
response_status=`sed -e "s/.*Response\"\:{\"status\"\:\"\(...\).*/\1/" ~/tmp/status_output`

[ $response_status = "RED" ] && [ $system_switch = "ON" ] && echo "WARNING!!! system is switched on and is RED, please check!" || echo "status is either not RED or system is not switched ON, nothing to worry"
