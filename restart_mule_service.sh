#! /bin/bash
cd /var/www/maintenance
cat in-pool.html
echo false > in-pool.html
sleep 5
sudo /sbin/service mule stop
sleep 10
cat in-pool.html
#! /bin/bash
#
cd /var/www/maintenance
cat in-pool.html
sleep 5
sleep 5
sudo /sbin/service mule start
sleep 10
echo true > in-pool.html
sleep 5
cat in-pool.html
