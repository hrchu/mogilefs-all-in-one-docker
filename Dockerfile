FROM ubuntu:bionic
MAINTAINER petertc "petertc.chu@gmail.com"

RUN bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password password super'"
RUN bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password super'"

RUN apt update 
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y build-essential cpanminus mysql-server libmysqlclient-dev libdbd-mysql-perl libperl-dev sysstat netcat sudo tzdata \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY IO-AIO-4.72-patched.tgz /root/IO-AIO-4.72.tgz
RUN cpanm /root/IO-AIO-4.72.tgz

# https://groups.google.com/d/msg/mogile/r4eaPoOlRoE/aqRhOLQSClYJ
RUN cpanm BRADFITZ/Sys-Syscall-0.23.tar.gz

RUN cpanm install --force MogileFS::Server \
  && cpanm install MogileFS::Utils \
  && cpanm install MogileFS::Network

RUN mkdir -p /etc/mysql/conf.d \
  && { \
    echo '[mysqld]'; \
    echo 'user = mysql'; \
    echo 'datadir = /var/lib/mysql'; \
    echo '!includedir /etc/mysql/conf.d/'; \
  } > /etc/mysql/my.cnf
RUN rm -rf /var/lib/mysql/*

COPY mogilefsd.conf /etc/mogilefs/mogilefsd.conf
COPY mogstored.conf /etc/mogilefs/mogstored.conf
COPY mogilefs.conf /root/.mogilefs.conf
COPY run.sh /run.sh

RUN adduser mogile --system --disabled-password 

EXPOSE 7001 7500 7501

ENTRYPOINT ["/run.sh"]
