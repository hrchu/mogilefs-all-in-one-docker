FROM ubuntu:bionic
MAINTAINER petertc "petertc.chu@gmail.com"

RUN bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password password super'"
RUN bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password super'"

RUN apt update \
  && apt-get install -y cpanminus build-essential supervisor libdbd-mysql-perl sysstat mysql-server libmysqlclient-dev libperl-dev sudo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY IO-AIO-4.72-patched.tgz /root/IO-AIO-4.72.tgz
RUN cpanm /root/IO-AIO-4.72.tgz

RUN cpanm install --force MogileFS::Server \
  && cpanm install DBD::mysql \
  && cpanm install MogileFS::Utils \
  && cpanm install MogileFS::Network

RUN mkdir -p /etc/mysql/conf.d \
  && { \
    echo '[mysqld]'; \
    echo 'user = mysql'; \
    echo 'datadir = /var/lib/mysql'; \
    echo '!includedir /etc/mysql/conf.d/'; \
  } > /etc/mysql/my.cnf

# Use touch here to workaround https://github.com/docker/for-linux/issues/72#issuecomment-319904698
RUN mkdir /var/run/mysqld \
  && chown mysql:mysql /var/run/mysqld \ 
  && find /var/lib/mysql -type f -exec touch {} \; && mysqld & \
  timeout 60 bash -c "until mysql -h127.0.0.1 -uroot -psuper -e 'select null limit 1'; do sleep 1; done" \
  && mysql -uroot -psuper -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'super';" \
  && mogdbsetup --type=MySQL --yes --dbrootuser=root --dbrootpass=super --dbname=mogilefs --dbuser=mogile --dbpassword=mogilepw

RUN  mkdir -p /etc/mogilefs \
  && mkdir -p /var/mogdata/dev1 \
  && mkdir -p /var/mogdata/dev2

COPY mogilefsd.conf /etc/mogilefs/mogilefsd.conf
COPY mogstored.conf /etc/mogilefs/mogstored.conf
COPY mogilefs.conf /root/.mogilefs.conf
COPY run.sh /run.sh

RUN adduser mogile --system --disabled-password \
  && chown mogile -R /var/mogdata

EXPOSE 7001 7500

ENTRYPOINT ["/run.sh"]
