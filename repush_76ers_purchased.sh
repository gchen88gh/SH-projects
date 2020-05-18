#!/bin/bash 
#### Usage: $0 [filename] [BuyerOrderId...]
#### Reoush 76er order stuck in Purchased
#### Example: $0 503252860
####          $0 datafile 503252860 503252898    <-- datafile contains lines of IDs, free format (comma or white space delimited)

. ~gchen1/scripts/basic_func.sh &>/dev/null || return

[ $# -eq 0 ] && usage && exit 1

ssh -o StrictHostKeyChecking=no -o LogLevel=quiet lvsp01stj001 ~gchen1/scripts/76ers_in_purchased.sh `pwd` $@
