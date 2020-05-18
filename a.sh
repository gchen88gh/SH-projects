
function curl()
{
#
  echo "inside func - $0"
  /usr/bin/curl $@
}


#
SERVER=srwp01abi001
  /usr/bin/curl -s http://$SERVER.myweb.com/jmx-console/ | grep "$SERVER"
echo 'called by func curl'
  curl -s http://$SERVER.myweb.com/jmx-console/ | grep "$SERVER"
