FROM rockylinux:8
LABEL maintainer="Bart Smeding"
ENV container=docker

ENV pip_packages "ansible yamllint pynautobot pynetbox jmespath netaddr"

# Install systemd -- See https://hub.docker.com/_/centos/
RUN rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements
RUN yum -y install rpm dnf-plugins-core \
 && yum -y update \
 && yum -y config-manager --set-enabled powertools \
 && yum -y install \
      epel-release \
      initscripts \
      sudo \
      which \
      hostname \
      libyaml-devel \
      python3 \
      python3-pip \
      python3-pyyaml \
      git \
      iproute \
      sshpass \
 && yum clean all

# Disable requiretty
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Upgrade pip to latest version
RUN pip3 install --upgrade pip

# Install Ansible and other applications via pip
RUN pip3 install $pip_packages

# Set localhost Ansible inventory file
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
