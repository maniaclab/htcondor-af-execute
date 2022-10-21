ARG BASE_IMAGE=opensciencegrid/software-base:3.6-el7-release
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

RUN yum install http://mirror.grid.uchicago.edu/pub/mwt2/sw/el7/HEP_OSlibs-7.2.9-1.el7.cern.x86_64.rpm -y

# Install GPU libraries
RUN yum install -y https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.2.89-1.x86_64.rpm
RUN rpm --import http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub
RUN rpm --import http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/D42D0685.pub
# These match the NVIDIA settings on the AF as of September 2022
RUN yum install -y nvidia-driver-branch-470-470.57.02
RUN yum install -y cuda-11-0

RUN yum install --enablerepo=osg-upcoming -y condor

RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN yum install -y docker-ce-cli
RUN yum install -y http://mirror.grid.uchicago.edu/pub/mwt2/sw/el7/mwt2-sysview-worker-2.0.3-1.noarch.rpm
RUN yum install -y python36-tabulate

# Add CVMFSEXEC 
#RUN git clone https://github.com/cvmfs/cvmfsexec /cvmfsexec \
# && cd /cvmfsexec \
# && ./makedist osg \
# # /cvmfs-cache and /cvmfs-logs is where the cache and logs will go; possibly bind-mounted. \
# # Needs to be 1777 so the unpriv user can use it. \
# # (Can't just chown, don't know the UID of the unpriv user.) \
# && mkdir -p /cvmfs-cache /cvmfs-logs \
# && chmod 1777 /cvmfs-cache /cvmfs-logs \
# && rm -rf dist/var/lib/cvmfs log \
# && ln -s /cvmfs-cache dist/var/lib/cvmfs \
# && ln -s /cvmfs-logs log \
# # tar up and delete the contents of /cvmfsexec so the unpriv user can extract it and own the files. \
# && tar -czf /cvmfsexec.tar.gz ./* \
# && rm -rf ./* \
# # Again, needs to be 1777 so the unpriv user can extract into it. \
# && chmod 1777 /cvmfsexec

COPY condor/*.conf /etc/condor/config.d/
COPY cron/* /etc/cron.d/
COPY supervisor/* /etc/supervisord.d/
COPY image-config/* /etc/osg/image-config.d/
COPY libexec/* /usr/local/libexec/
COPY sysview-client/sysclient /bin/
COPY sysview-client/client /usr/lib/python3.6/site-packages/sysview/client
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
