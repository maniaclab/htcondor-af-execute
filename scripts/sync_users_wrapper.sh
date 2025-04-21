#!/bin/bash
TIME=$((RANDOM%900))
echo "Sleeping for $TIME seconds"
sleep $TIME
cd /usr/local/ciconnect 
source /usr/local/ciconnect/config && ./sync_users.sh -u root.atlas-af -g root.atlas-af -e https://api.ci-connect.net:18080 >> /var/log/provisioner.log 2>&1
[[ -d /passwd ]] && yes | cp /etc/passwd /passwd
