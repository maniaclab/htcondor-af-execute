#!/bin/bash -x
set -eo pipefail

echo "# This file was created by $prog" > /etc/condor/config.d/01-env.conf
echo "CONDOR_HOST=${CONDOR_HOST:-\$(FULL_HOSTNAME)}" >> /etc/condor/config.d/01-env.conf

# Change Condor's GID/UID 
groupmod -g 64 condor
usermod -u 64 condor

# Fix various perms
chown condor:condor /var/lib/condor
chown condor:condor /var/lib/condor/execute
chown condor:condor /var/lib/condor/spool
chown :condor /var/lib/condor/oauth_credentials
chown condor:condor /var/log/condor

# Add condor to the docker grp
usermod -aG docker condor

# Chown the scratch dir
mkdir -p /scratch
chown -R condor: /scratch

chmod +x /usr/local/libexec/condor-docker

# Symlink the Docker control socket to the canonical location
ln -s /shared/docker.sock /var/run/docker.sock
