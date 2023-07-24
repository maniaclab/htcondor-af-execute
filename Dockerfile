ARG BASE_IMAGE=hub.opensciencegrid.org/opensciencegrid/software-base:3.6-el7-release
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
  cpio \
  ed \
  file \
  bzip2 \ 
  gnupg2 \
  libaio \
  rdate \ 
  rng-tools \ 
  rsync \ 
  tcsh \ 
  time \ 
  wget \
  which \ 
  words \ 
  xz \ 
  zip \
  yum-utils \ 
  dos2unix \
  man-db \
  telnet 

#RUN yum install https://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm -y
#RUN yum install HEP_OSlibs
RUN yum install http://mirror.grid.uchicago.edu/pub/mwt2/sw/el7/HEP_OSlibs-7.2.9-1.el7.cern.x86_64.rpm -y

RUN yum install --enablerepo=osg-upcoming -y condor

RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN yum install -y docker-ce-cli
RUN yum install -y http://mirror.grid.uchicago.edu/pub/mwt2/sw/el7/mwt2-sysview-worker-2.0.3-1.noarch.rpm
RUN yum install -y python36-tabulate

COPY condor/*.conf /etc/condor/config.d/
COPY cron/* /etc/cron.d/
COPY supervisor/* /etc/supervisord.d/
COPY image-config/* /etc/osg/image-config.d/
COPY libexec/* /usr/local/libexec/
COPY scripts/condor_node_check.sh /usr/local/sbin/
COPY scripts/entrypoint.sh /bin/entrypoint.sh

COPY prometheus/exporter.py /app/
RUN pip3 install prometheus_client

RUN chmod 755 /usr/local/sbin/condor_node_check.sh

# Igor's wrapper for singularity to make things work inside of K8S, requires OASIS CVMFS
ADD scripts/singularity_npid.sh /usr/bin/singularity

ENTRYPOINT ["/bin/entrypoint.sh"]
# Adding ENTRYPOINT clears CMD
CMD ["/usr/local/sbin/supervisord_startup.sh"]
