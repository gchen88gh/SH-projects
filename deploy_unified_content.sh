#!/bin/bash
#### Usage: $0 [OPTION] ver_num
#### Deploys the specified unified content to the specified PODs(default all PODs with -f).
#### Example: $0 -p 01 1.8.1        deploy 1.8.1 to POD1
####          $0 -p 02,31 1.8.1     deploy 1.8.1 to POD2 & 31
####          $0 -f -p 31 1.8.0     rollback to 1.8.0 in POD31
####          $0 -f 1.8.0           rollback to 1.8.0 in all PODs
#### Option:
####   -h, --help      display this help
####   -p, --pod       specify pods(comma separated)
####   -f, --force     rollback to a lower version(force mode, skip version check)
#

#
. ~gchen1/scripts/basic_func.sh &>/dev/null || return

function fill0()
{
#
  printf "%04i." $(echo $1 | tr . ' ') 2>/dev/null
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
      -f|--force)
           FORCE="anything"
           ;;
      -p|--pod)
           [ $# -gt 0 -a "${1:0:1}" != "-" ] && PODS="$PODS $1" && shift
           ;;
      *)
           [ "${OPT:0:1}" = "-" ] && echo "${OPT}: unknown option." && usage && exit 1
           ARGV+=(${OPT})
           ;;
    esac
  done
}

#
getopt $*

TARPATH='/nas/release/myweb
TARNAME='app-content-content_'
CMD='content_prod_deploy.sh -t Full -v'

[ -n "$PODS" ] && PODS=$(echo "$PODS" | tr -cs '0-9 ,' ' ' | tr -s ', \t' '\n' | egrep '^(01|02|31)$' | sort -u) || eval '[ -n "$FORCE" ] && PODS="01 02 31"'
[ -z "$PODS" ] && echo "No valid POD is specified." && exit
VER="${ARGV[0]}"
[ -z "$VER" ] && echo "no version nuber is specified" && usage && exit
! echo "$VER" | egrep -q "^[0-9]+\.[0-9]+\.[0-9]+$" && echo "invalid version number: '$VER'" && usage && exit 1
echo $0 | grep -q 'app' && TARPATH=${TARPATH}app-content-common/ && TARNAME='app-content-common-' && CMD='deploy_app_content -t app-content-common -v'
MAXVER=$(ls -l $TARPATH$TARNAME*tar 2>/dev/null | tail -1 | sed -e 's/^.*[_-]\(.*\)\.tar/\1/')
[ -z "$FORCE" ] && [[ "$(fill0 $VER)" < "$(fill0 $MAXVER)" ]] && echo -e "The specified version '$VER' is lower than the max version '$MAXVER' in the system.\nTo force this version out(ex, rollback) please re-run the script by adding -f option." && exit
#
#
#
#
#
#

RED='\e[0;31m'
CYAN='\e[0;36m'
NOCOLOR='\e[0m'
echo -e "\nContent version: '$VER'"
echo -e "\n${CYAN}Sync content dir\n================\n$NOCOLOR"
ssh -o StrictHostKeyChecking=no lvsp01mgt001 sudo rsync -av root@slcd000dvo015.myweb.com:/nas/release/myweb
[ ! -e $TARPATH$TARNAME$VER.tar ] && echo -e "\n${RED}tar file $VER does not exist, quit!\n$NOCOLOR" && exit 1
for POD in $PODS; do
  echo -e "\n${CYAN}Deploy to POD$POD\n===============\n$NOCOLOR"
  ssh -o StrictHostKeyChecking=no lvsp${POD}reg001 sudo /nas/reg/bin/$CMD $VER
done
echo
