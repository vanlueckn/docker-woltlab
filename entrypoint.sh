#!/bin/sh
HTML_ROOT=/var/www/woltlab
chown -R www-data:www-data $HTML_ROOT

service cron start
service nginx start

{ php-fpm & tail -f /var/log/nginx/access.log; }
