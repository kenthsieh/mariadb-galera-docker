#!/bin/bash

CLUSTER_FILE="/etc/mysql/conf.d/cluster.cnf"
DEBIAN_FILE="/etc/mysql/debian.cnf"

# Get debian-sys-maint password
if [ -z "$DEBIAN_PASSWORD" ]; then
  DEBIAN_PASSWORD="IvTYPh4yQzwu15VW"
fi

# Get mysql password
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  MYSQL_ROOT_PASSWORD="P@ssword"
fi

# check mysql is started
MYSQL=`ps ax | grep -c "/usr/sbin/mysqld"`
while [ $MYSQL -le 1 ]
  do
    sleep 5
    MYSQL=`ps ax | grep -c "/usr/sbin/mysqld"`
  done

# set mysql debian-sys-maint password
if [ -n "$DEBIAN_PASSWORD" ]; then
  mysql -uroot -e"UPDATE user SET Password=password('${DEBIAN_PASSWORD}') WHERE User='debian-sys-maint';" mysql
  mysqladmin -uroot reload
  sed -i -e "s|^password.*$|password = ${DEBIAN_PASSWORD}|" $DEBIAN_FILE
fi

# set mysql root password
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
  mysql -uroot -e"UPDATE user SET Host='%' WHERE Host='::1';" mysql
  mysql -uroot -e"UPDATE user SET Password=password('${MYSQL_ROOT_PASSWORD}') WHERE User='root';" mysql
  mysqladmin -uroot reload
fi

# set nodes ip address
WSREP_NODE_ADDRESS=`ip addr show | grep -E '^[ ]*inet' | grep -m1 global | awk '{ print $2 }' | sed -e 's/\/.*//'`
if [ -n "$WSREP_NODE_ADDRESS" ]; then
  sed -i -e "s|^wsrep_node_address=.*$|wsrep_node_address=${WSREP_NODE_ADDRESS}|" $CLUSTER_FILE
fi

# random server ID needed
# sed -i -e "s/^server\-id=.*$/server-id=${RANDOM}/" /etc/mysql/my.cnf
