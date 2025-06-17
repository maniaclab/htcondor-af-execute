#!/bin/bash -x
set -eo pipefail

#echo "CONDOR_HOST=${CONDOR_HOST:-\$(FULL_HOSTNAME)}" >> /etc/condor/config.d/01-env.conf
pwd
ls -lha

mkdir -p /pilot/log
export LOCAL_DIR="/pilot/condor_local"
mkdir -p $LOCAL_DIR/lock
mkdir -p $LOCAL_DIR/condor/tokens.d
mkdir -p $LOCAL_DIR/condor/passwords.d

mkdir -p /pilot/{log,log/log,rsyslog,rsyslog/pid,rsyslog/workdir,rsyslog/conf}
mkdir -p `condor_config_val EXECUTE`
mkdir -p `condor_config_val LOG`
mkdir -p `condor_config_val LOCK`
mkdir -p `condor_config_val RUN`
mkdir -p `condor_config_val SPOOL`
#mkdir -p `condor_config_val SEC_CREDENTIAL_DIRECTORY`

cp -v /etc/condor/tokens-orig.d/* "$LOCAL_DIR"/condor/tokens.d/
chmod 600 "$LOCAL_DIR"/condor/tokens.d/*
cp -v /etc/condor/passwords-orig.d/* "$LOCAL_DIR"/condor/passwords.d/
chmod 600 "$LOCAL_DIR"/condor/passwords.d/*
