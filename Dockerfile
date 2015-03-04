FROM kriation/centos7

MAINTAINER Armen Kaleshian <armen@kriation.com>

# Install PHP-FPM and PHP MySQL support (with docs)
RUN yum -y install --setopt=tsflags='' php-fpm php-mysqlnd && \
    yum -y clean all

# Add php user/group and create home to share content between containers
RUN useradd -r -d /con/data -U php -s /sbin/nologin && \
    chown php:php /con/data && \
    userdel apache && \
    # Copy production PHP config
    cp /usr/share/doc/php-common-5.4.16/php.ini-production /etc/php.ini && \
    # Change permissions on config files/directories
    chown -R php:php \ 
    /etc/php.ini /etc/php.d/ /etc/php-fpm.conf /etc/php-fpm.d/ \
    /var/log/php-fpm/ /run/php-fpm/ /var/lib/php/ && \
    # Fix owner/group of php-fpm from apache to php
    # php-fpm should listen on all interfaces instead of localhost
    # php-fpm should start in new home
    # php-fpm should listen for traffic from anywhere
    # date.timezone set to UTC
    sed -i 's/user = apache/user = php/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/group = apache/group = php/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' \
	/etc/php-fpm.d/www.conf && \
    sed -i 's/\;chdir = \/var\/www/chdir = \/con\/data/g' \
	/etc/php-fpm.d/www.conf && \
    sed -i \
	's/listen.allowed_clients = 127.0.0.1/#listen.allowed_clients =/g' \
	/etc/php-fpm.d/www.conf && \
    sed -i 's/;date.timezone =/date.timezone = UTC/g' /etc/php.ini && \
    sed -i 's/;pm.status_path/pm.status_path/g' /etc/php-fpm.d/www.conf

EXPOSE 9000

ENTRYPOINT ["/usr/sbin/php-fpm"]
