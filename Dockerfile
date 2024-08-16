ARG BASE_IMAGE=hub.opensciencegrid.org/opensciencegrid/software-base:23-el9-release
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

LABEL org.opencontainers.image.title="HTCondor ATLAS AF Execute image derived from ${BASE_IMAGE}"

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
  telnet 

RUN yum install -y https://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm
RUN yum install -y https://linuxsoft.cern.ch/wlcg/el9/x86_64/wlcg-repo-1.0.0-1.el9.noarch.rpm 
RUN yum install -y HEP_OSlibs
RUN yum install -y condor
RUN yum install -y python3-pip

RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN yum install -y docker-ce-cli
RUN yum install -y http://mirror.grid.uchicago.edu/pub/mwt2/sw/el9/mwt2-sysview-worker-2.0.6-1.noarch.rpm

COPY condor/*.conf /etc/condor/config.d/
COPY supervisor/* /etc/supervisord.d/
COPY image-config/* /etc/osg/image-config.d/
COPY libexec/* /usr/local/libexec/
COPY scripts/condor_node_check.sh /usr/local/sbin/
COPY scripts/entrypoint.sh /bin/entrypoint.sh

COPY prometheus/exporter.py /app/

RUN pip install prometheus_client

RUN pip install python3-memcached
RUN chmod 755 /usr/local/sbin/condor_node_check.sh

# Igor's wrapper for singularity to make things work inside of K8S, requires OASIS CVMFS
ADD scripts/singularity_npid.sh /usr/bin/singularity

# Symlink python3 to python for certain jobs to work correctly
RUN ln -s /usr/bin/python3 /usr/bin/python

# Add the cron wrapper to hopefully prevent any weird issues with periodic sync
ADD scripts/sync_users_wrapper.sh /usr/local/sbin/sync_users_wrapper.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
# Adding ENTRYPOINT clears CMD
CMD ["/usr/local/sbin/supervisord_startup.sh"]
