#!/bin/bash
#### Usage: $0 [OPTION] pattern...
#### lists all hosts defined in capconfig/roles*.rb files that match the specified list of patterns 
#### ex. of pattern: three-letter role name, pool name, individual hostname and etc
#### Example: $0 abi,00mqm,myx01b
####          $0 srwp03 srwp01mci004
#### Option:
####   -h, --help        display this help
####   -l, --singleline  print a single line of comma separated hostnames
####   -s, --strict      match whole word only
####   -c, --datacenter  match only host in specified data center(s)
####   -f, --filter      filter in only wanted hostnames (by simple matching the filter pattern)

function usage()
{
  SEDSTR="s/\$0/`basename $0`/g"
  head $0 | grep "^#### " | sed -e "s/^#### //" -e "$SEDSTR"
}

function getopt()
{
  ARGV=()
  while [ $# -gt 0 ]; do
    OPT=$1
    shift
    case ${OPT} in
      -h|--help)
           usage && exit 1
           ;;
      -f|--filter)
           [ $# -eq 0 -o "${1:0:1}" = "-" ] && echo "The ${OPT} option requires an argument." && exit 1
           OPTFILTER=`echo "$1" | tr A-Z a-z | tr -s ', ' '|' | sed -e "s/^|//;s/|$//"`
           shift
           ;;
      -c|--datacenter)
           [ $# -eq 0 -o "${1:0:1}" = "-" ] && echo "The ${OPT} option requires an argument." && exit 1
           OPTDC=`echo "$1" | tr A-Z a-z | tr -s ', ' '|' | sed -e "s/^|//;s/|$//"`
           shift
           ;;
      -l|--singleline)
           OPTLINEFMT='csv'
           ;;
      -s|--strict)
           OPTSTRICT='w'
           ;;
      *)
           [ "${OPT:0:1}" = "-" ] && echo "${OPT}: unknown option." && exit 1
           ARGV+=(${OPT})
           ;;
    esac
  done
}

[ $# -eq 0 ] && usage && exit 1
getopt $*
[ -z "$OPTDC" ] && OPTDC=`hostname | sed -e 's/^\(...\).*/\1/'`

#
#

CAPCONFIG=/nas/utl/presidio/capconfig

FILTER=`echo "${ARGV[@]}" | tr A-Z a-z | tr -s ', ' '|' | sed -e "s/^|//;s/|$//"`
[ -z "$FILTER" ] && FILTER='WonT-MatcH'
#
#
#
SERVERS=`grep -h ^server $CAPCONFIG/roles*.rb /nas/utl/NOC/roles_noc.rb | grep "-${OPTSTRICT}E" "${FILTER}" | sed -e 's/^[^"]*"\([a-z]*\)\([0-9]*\)\([a-z]*\)\([^"]*\).*$/\1_\3_\2_\4/' | sort -u | sed -e "s/^\([^_]*\)_\([^_]*\)_\([^_]*\)_/\1\3\2/" | grep -E "$OPTFILTER" | grep -E "^($OPTDC)"`
#
! echo $0 | grep -q "get_hosts.sh" && return
[ -n "$OPTLINEFMT" ] && echo $SERVERS | sed "s/ /,/g" || echo "$SERVERS"
