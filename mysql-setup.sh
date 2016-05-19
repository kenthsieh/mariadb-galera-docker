#!/bin/bash

# Set mysql password
MYSQLPW="P@ssword"
CLUSTER_FILE="/etc/mysql/conf.d/cluster.cnf"
DEBIAN_FILE="/etc/mysql/debian.cnf"
DEBIAN_NEW_PASSWORD="IvTYPh4yQzwu15VW"
DEBIAN_PASSWORD=`awk '/password/{print $3}' $DEBIAN_FILE | tail -n 1`

# check mysql is started
MYSQL=`ps ax | grep -c "/usr/sbin/mysqld"`
while [ $MYSQL -le 1 ]
  do
    sleep 5
    MYSQL=`ps ax | grep -c "/usr/sbin/mysqld"`
  done

# set mysql debian-sys-maint password
if [ -n "$DEBIAN_NEW_PASSWORD" ]; then
  mysqladmin -udebian-sys-maint -p$DEBIAN_PASSWORD password $DEBIAN_NEW_PASSWORD
  sed -i -e "s|^password.*$|password = ${DEBIAN_NEW_PASSWORD}|" $DEBIAN_FILE
fi

# set mysql root password
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
  mysqladmin -uroot password $MYSQL_ROOT_PASSWORD
  mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD reload
  mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD refresh
else
  mysqladmin -uroot password $MYSQLPW
  mysqladmin -uroot -p$MYSQLPW reload
  mysqladmin -uroot -p$MYSQLPW refresh
fi

# set nodes ip address
WSREP_NODE_ADDRESS=`ip addr show | grep -E '^[ ]*inet' | grep -m1 global | awk '{ print $2 }' | sed -e 's/\/.*//'`
if [ -n "$WSREP_NODE_ADDRESS" ]; then
  sed -i -e "s|^wsrep_node_address=.*$|wsrep_node_address=${WSREP_NODE_ADDRESS}|" $CLUSTER_FILE
fi

# random server ID needed
# sed -i -e "s/^server\-id=.*$/server-id=${RANDOM}/" /etc/mysql/my.cnf
