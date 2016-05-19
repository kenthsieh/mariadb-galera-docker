#!/bin/bash

CLUSTER_FILE="/etc/mysql/conf.d/cluster.cnf"
SUPERVISOR_FILE="/etc/supervisor/conf.d/mysql.conf"

if [ -n "$1" ]; then
  sed -i -e "s|^wsrep_cluster_address=gcomm://.*|wsrep_cluster_address=gcomm://${1}|" $CLUSTER_FILE
  supervisorctl stop mysql
fi

if [ "$2" == "yes" ]; then
  sed -i -e "s|^command=/usr/bin/mysqld_safe.*|command=/usr/bin/mysqld_safe --wsrep-new-cluster|" $SUPERVISOR_FILE
  supervisorctl reload
else
  supervisorctl start mysql
fi
