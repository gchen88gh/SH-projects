#!/bin/bash
#### Usage: $0 host_patterns connection_name...
#### Flush specified db connections on matched hosts.(thru jmx-console, hosts running wso2am are not supported)
#### Supported abbr.: db=jdbc/myweb
#### Supplying jdbc* as connection_name will flush all connections with name starting with jdbc/
#### Example: $0 01lcx001           Display connection info of srwp01lcx001
####          $0 brx db,rwdb,rodb   Perform typical db connection flush on brx role in all env
####          $0 slx jdbc*          Flush all jdbc connections on specified host(s)
####          $0 sli01a jdbc/audit  Flush audit connection on blades of sli01a pool
###. Wiki: https://wiki.myweb.com/display/NOC/...

. ~gchen1/scripts/basic_func.sh &>/dev/null

function getAttribute()
{
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/$NAME" | sed -ne "/>$1</,/tr>/p" | grep "[0-9]" | sed -e "s/^[^0-9]*//;s/[^0-9]*$//"
}

function flushConnection()
{
  /usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/`echo $NAME | sed -e 's/inspectMBean/invokeOpByName/'`&methodName=$CMD" | grep -q "Operation completed successfully without a return value"
#
}

[ "$1" = '-h' -o "$1" = '--help' ] && usage && exit 1

. ~gchen1/scripts/get_hosts.sh $1
SERVERS=`echo "$SERVERS" | egrep -v "agg|agi|agp|ags"`
[ -z "$SERVERS" ] && echo "no blade found to work on, quitting." && exit 1

authenticationTest

ABBRS=`grep "^#### Supported abbr" $0 | sed -e "s/^.*: //"`
#

shift
##TODO=`echo "$*" | tr -s ', ' ' '`
TODO=`echo "$*" | tr -s ', ' '\n' | sort -u`
for ABBR in $ABBRS; do
  FULL=`echo $ABBR | cut -d= -f2`
  ABBR=`echo $ABBR | cut -d= -f1`
  SEDSTR="s/^${ABBR}$/$(echo $FULL | sed -e 's/\//@\//g' | tr '@' '\\')/"
  TODO=`echo "$TODO" | sed -e "$SEDSTR"`
##  TODO=`echo "$TODO $FULL"`
done

for SERVER in $SERVERS; do
  echo -e "db connection info on ${SERVER}...\c"
  ! isJmxUp $SERVER && echo -e "jmx unavailable\n" && continue
  echo
  NAMES=`/usr/bin/curl -s --user "$USER":"$PASSCODE" "http://${SERVER}.myweb.com/jmx-console/HtmlAdaptor?action=displayMBeans" | egrep 'ManagedConnectionPool|identityToken' | sed -e 's/^[^\"]*\"\([^\"]*\).*/\1/' | sed -e "s/&amp;/\&/g"`
#
#
  for NAME in $NAMES; do
#
    CONN=`echo $NAME | sed -e "s/^.*name%3D//;s/%2F/\//"`
    CMD=flush;ATTR=ConnectionCount
    echo $NAME | grep -q c3p0 && CMD=hardReset && ATTR=numConnections
##  echo -n $CONN: [`getAttribute ConnectionCount`]
    printf '%24s: %3s' "$CONN" "[`getAttribute $ATTR`]"
#
    ! echo "$TODO" | grep -qx "jdbc\*" && ! echo "$TODO" | grep -qx "$CONN" && echo && continue
    echo "$TODO" | grep -qx "jdbc\*" && ! echo "$CONN" | grep -q "jdbc\/" && echo && continue
    flushConnection
    echo ' -->' "[`getAttribute $ATTR`]"
  done
  echo
done
