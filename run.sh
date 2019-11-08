#!/bin/bash
set -x

if [ "`echo ${NODE_HOST}`" == "" ]
then
  NODE_HOST="127.0.0.1"

fi

if [ "`echo ${NODE_PORT}`" == "" ]
then
  NODE_PORT="7500"
fi

find /var/lib/mysql -type f -exec touch {} \; && mysqld &
sleep 3

sudo -u mogile mogilefsd --daemon -c /etc/mogilefs/mogilefsd.conf
sleep 3

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

sudo -u mogile mogstored -c /etc/mogilefs/mogstored.conf &
sleep 3

mogadm check
pkill mogilefsd

sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf 

