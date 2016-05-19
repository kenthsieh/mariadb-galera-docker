FROM ubuntu:trusty
MAINTAINER Kent Hsieh <kent_hsieh@tutk.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install software-properties-common supervisor && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    add-apt-repository 'deb [arch=amd64,i386] http://download.nus.edu.sg/mirror/mariadb/repo/5.5/ubuntu trusty main' && \
    apt-get update && \
    apt-get -y install rsync galera mariadb-galera-server

# Add volumes for MariaDB 
VOLUME  ["/var/lib/mysql","/etc/mysql"]

COPY my.cnf /etc/mysql/my.cnf
COPY cluster.cnf /etc/mysql/conf.d/cluster.cnf
COPY mysql.conf /etc/supervisor/conf.d/mysql.conf
COPY mysql-setup.sh /mysql-setup.sh
COPY gcomm.sh /usr/local/bin/gcomm.sh
COPY start.sh /start.sh


EXPOSE 3306 4444 4567 4568

CMD ["/usr/bin/supervisord"] 

#ENTRYPOINT bash -C '/entrypoint.sh';'bash'
#CMD bash -C '/entrypoint.sh';'bash'
