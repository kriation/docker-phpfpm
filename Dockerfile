FROM kriation/centos7 as php-builder
ARG PHP_VERSION=74
RUN yum -y install \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install \
      https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum -y install yum-utils && \
    yum-config-manager --disable 'remi-php*' && \
    yum-config-manager --enable "remi-php$PHP_VERSION" && \
    yum -y install php php-bcmath php-fpm php-gd php-intl \
      php-json php-mysqlnd php-pgsql php-pspell

# Add php user/group and create home to share content between containers
RUN useradd -r -d /var/www -U php -s /sbin/nologin && \
     userdel apache && \
     mkdir /run/php-fpm && \
     chown -R php:php \
      /etc/php.ini /etc/php.d/ /etc/php-fpm.conf /etc/php-fpm.d/ \
      /var/log/php-fpm/ /run/php-fpm/ /var/lib/php/ /var/www/ && \
     sed -i 's/;date.timezone =/date.timezone = UTC/g' /etc/php.ini && \
     sed -i 's/user = apache/user = php/g' /etc/php-fpm.d/www.conf && \
     sed -i 's/group = apache/group = php/g' /etc/php-fpm.d/www.conf && \
     sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php-fpm.d/www.conf && \
     sed -i 's/listen.allowed_clients = 127.0.0.1/;listen.allowed_clients =/g' /etc/php-fpm.d/www.conf && \
     sed -i 's/;pm.status_path/pm.status_path/g' /etc/php-fpm.d/www.conf

EXPOSE 9000

ENTRYPOINT ["/usr/sbin/php-fpm", "--nodaemonize", "-O"]

FROM php-builder
ARG BUILD_DATE
ARG PHP_VERSION=74
LABEL maintainer="armen@kriation.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.license="GPLv2" \
      org.label-schema.name="PHP on CentOS v7" \
      org.label-schema.version="$PHP_VERSION" \
      org.label-schema.vendor="armen@kriation.com" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.licenses="GPL-2.0-only" \
      org.opencontainers.image.title="PHP on CentOS v7" \
      org.opencontainers.image.version="$PHP_VERSION" \
      org.opencontainers.image.vendor="armen@kriation.com"
