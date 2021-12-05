#!/bin/sh
cd /var/www/html
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
composer install --no-dev --optimize-autoloader

mkdir -p /var/log/nginx
touch /var/log/nginx/access.log
chmod -R 777 /var/log/nginx
/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf

{ php-fpm & tail -f /var/log/nginx/access.log; }
