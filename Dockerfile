FROM kriation/centos7

MAINTAINER Armen Kaleshian <armen@kriation.com>

# Install PHP-FPM and PHP MySQL support
RUN yum -y install php-fpm php-mysqlnd && yum -y clean all

# Add php user/group and create home to share content between containers
RUN useradd -r -d /opt/php -U php -s /sbin/nologin && \
    mkdir -p /opt/php && \
    chown php:php /opt/php && \
    userdel apache

# Change permissions on config files/directories
RUN chown -R php:php \ 
    /etc/php.ini /etc/php.d/ /etc/php-fpm.conf /etc/php-fpm.d/ \
    /var/log/php-fpm/ /run/php-fpm/ /var/lib/php/

# Change running user to php
USER php

# Fix owner/group of php-fpm from apache to php
# php-fpm should listen on all interfaces instead of localhost
# php-fpm should start in new home
# php-fpm should listen for traffic from anyone
RUN sed -i 's/user = apache/\;user = php/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/group = apache/\;group = php/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' \
	/etc/php-fpm.d/www.conf && \
    sed -i 's/\;chdir = \/var\/www/chdir = \/opt\/php/g' \
	/etc/php-fpm.d/www.conf && \
    sed -i \
	's/listen.allowed_clients = 127.0.0.1/listen.allowed_clients =/g' \
	/etc/php-fpm.d/www.conf 

EXPOSE 9000

# Volumes necessary for configuration of PHP functionality
VOLUME ["/etc/php.d/","/etc/php-fpm.d/"]

CMD ["/usr/sbin/php-fpm"]

