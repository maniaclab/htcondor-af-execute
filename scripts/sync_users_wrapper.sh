#!/bin/bash
sleep $((RANDOM%300))
cd /usr/local/ciconnect 
source /usr/local/ciconnect/config && ./sync_users.sh -u root.atlas-af -g root.atlas-af -e https://api.ci-connect.net:18080 >> /var/log/provisioner.log 2>&1
