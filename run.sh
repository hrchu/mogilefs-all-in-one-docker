#!/bin/bash
set -x


###### already inited #######

MYSQL_FILE_COUNT=$(ls /var/lib/mysql|wc -l)
if [ $MYSQL_FILE_COUNT != 0 ]; then
  mkdir -p /var/run/mysqld 
  chown mysql:mysql /var/run/mysqld  
  rm /var/run/mysqld/*
  find /var/lib/mysql -type f -exec touch {} \;
  mysqld &
  sleep 3; timeout 60 bash -c "until mysql -uroot -psuper -e 'select null limit 1'; do sleep 1; done" 

  set -m
  sudo -u mogile mogstored -c /etc/mogilefs/mogstored.conf &
  sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf &
  sleep 5

  mogadm check
  fg
fi

###### fresh run only #######

if [ "`echo ${NODE_HOST}`" == "" ]
then
  NODE_HOST="127.0.0.1"

fi

if [ "`echo ${NODE_PORT}`" == "" ]
then
  NODE_PORT="7500"
fi

mkdir -p /var/run/mysqld 
chown mysql:mysql /var/run/mysqld  

# Use touch here to workaround https://github.com/docker/for-linux/issues/72#issuecomment-319904698
find /var/lib/mysql -type f -exec touch {} \;
mysqld --initialize-insecure
echo 'port = 3307' >> /etc/mysql/my.cnf
echo 'skip-name-resolve = 1' >> /etc/mysql/my.cnf
mysqld &
timeout 60 bash -c "until mysql -uroot -e 'select null limit 1'; do sleep 1; done" 

# Setup tracker DB
## FIXME: mogdbsetup will report access denied... seems have no effect in the following run?
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'super';" 
mogdbsetup --type=MySQL --yes --dbrootuser=root --dbrootpass=super --dbname=mogilefs --dbuser=mogile --dbpassword=mogilepw

# Config mogilefs host/device/domain/classes
sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf &
sleep 5

mogadm --trackers=127.0.0.1:7001 host add mogilestorage --ip=${NODE_HOST} --port=${NODE_PORT} --status=alive
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 1
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 2

mogadm host list

if [ "`echo ${DOMAIN_NAME}`" != "" ]
then
  mogadm --trackers=127.0.0.1:7001 domain add ${DOMAIN_NAME}
  mogadm class modify ${DOMAIN_NAME} default --replpolicy='MultipleDevices()'

  # Add all given classes
  if [ "`echo ${CLASS_NAMES}`" != "" ]
  then
    for class in ${CLASS_NAMES}
    do
      mogadm --trackers=127.0.0.1:7001 class add ${DOMAIN_NAME} $class --replpolicy="MultipleDevices()"
    done
  fi
fi

mogadm domain list
mogadm class list


mkdir -p /etc/mogilefs \
  && mkdir -p /var/mogdata/dev1 \
  && mkdir -p /var/mogdata/dev2
chown mogile -R /var/mogdata

set -m
sudo -u mogile mogstored -c /etc/mogilefs/mogstored.conf &
sleep 5

mogadm check
fg
