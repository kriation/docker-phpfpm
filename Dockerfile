FROM centos:centos7

MAINTAINER Armen Kaleshian <armen@kriation.com>

# Install PHP-FPM and PHP MySQL support
yum -y install php-fpm php-mysqlnd
