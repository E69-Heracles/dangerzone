FROM ubuntu:trusty
MAINTAINER E69_Heracles <22sas.heracles@gmail.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

# Enable CGI module for Apache 2
RUN a2enmod cgi

# Configure Apache 2
ADD envvars /etc/apache2/envvars
ADD serve-cgi-bin.conf /etc/apache2/conf-available/serve-cgi-bin.conf
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

# Dangerzone database creation
ADD mysql-setup.sh /mysql-setup.sh
ADD new_tables.sql /sql/new_tables.sql
ADD votes_tbl.sql /sql/votes_tbl.sql
ADD badc_6_HL_slots.sql /sql/badc_6_HL_slots.sql
ADD dev_data.sql /sql/dev_data.sql

EXPOSE 80 3306

CMD ["/run.sh"]