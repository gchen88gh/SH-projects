cat error.txt | sed -e 's/cp: cannot stat .\(.*pdf\)..*$/cp -a \1 \/nas\/ticket_upload\/edelivery\/\1/' > error.sh
