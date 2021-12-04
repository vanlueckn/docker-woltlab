#!/bin/sh
cd /var/www/html
mkdir -p /var/log/nginx
touch /var/log/nginx/access.log
chmod -R 777 /var/log/nginx
service cron start
/usr/local/nginx/sbin/nginx

{ php-fpm & tail -f /var/log/nginx/access.log; }
