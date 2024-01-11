cd /home/data-integration
./kitchen.sh -file=/home/data-integration/job/everyday.kjb >> /home/data-integration/log/everyDay$(date +%Y%m%d).log
