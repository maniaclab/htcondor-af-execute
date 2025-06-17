ARG BASE_IMAGE=hub.opensciencegrid.org/opensciencegrid/software-base:24-el9-release
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

LABEL org.opencontainers.image.title="HTCondor ATLAS AF Execute image derived from ${BASE_IMAGE}"

# Install base repos
COPY repos/* /etc/yum.repos.d
RUN yum install -y https://linuxsoft.cern.ch/wlcg/el9/x86_64/wlcg-repo-1.0.0-1.el9.noarch.rpm

RUN yum install -y \
  @development \
  jq \
  zsh \
  tcsh \
  git \
  bc \
  bind-utils \
  libaio \
  rng-tools \
  rsync \
  tcsh \
  time \
  wget \
  words \
  yum-utils \
  dos2unix \
  man-db \
  telnet \
  netbird \
  HEP_OSlibs \
  condor \
  python3-pip
  

# Skip the node check
COPY condor/01-*.conf /etc/condor/config.d/
# Copy single-user stuff into place
COPY condor/03-*.conf /etc/condor/config.d/
# Copy more glidein stuff
#COPY condor/50-*.conf /etc/condor/config.d/


# Supervisor configuration
COPY single-user/supervisord.conf /etc/supervisord.conf
COPY supervisor/* /etc/supervisord.d/

# Any additional start-time configuration
COPY image-config/10-condor-cfg.sh /etc/osg/image-config.d/

#COPY scripts/entrypoint.sh /bin/entrypoint.sh

# Add the cron wrapper to hopefully prevent any weird issues with periodic sync
#ADD scripts/sync_users_wrapper.sh /usr/local/sbin/sync_users_wrapper.sh

#ENTRYPOINT ["/bin/entrypoint.sh"]
# Adding ENTRYPOINT clears CMD
WORKDIR /pilot
CMD ["/usr/local/sbin/supervisord_startup.sh"]
