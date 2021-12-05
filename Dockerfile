FROM php:8.0-fpm

ARG MODULE_CHECKSUM=03b03cb127a9d1281924cb8cf605d450ba74cb54
ARG MODULE_VERSION=0.33
ARG MODULE_NAME=headers-more-nginx-module-src

RUN set -x && \
    apt-get update && apt-get install -y --no-install-recommends autoconf dpkg-dev file g++ gcc make pkgconf re2c libcurl4-nss-dev libjpeg-dev libpng-dev libpq-dev libjpeg62-turbo-dev libxml2-dev libxslt1-dev libfreetype6-dev libmagickwand-dev libpcre++-dev zlib1g-dev git libwebp-dev && \
    apt-get install -y wget unzip imagemagick

#Compile and install nginx with more headers
RUN cd /usr/src && \
    curl -L 'http://nginx.org/download/nginx-1.21.4.tar.gz' -o "nginx.tar.gz" && \
    tar -xzvf nginx.tar.gz && \
    curl -L "https://github.com/nginx-with-docker/headers-more-nginx-module-src/archive/refs/tags/v0.33.tar.gz" -o "${MODULE_VERSION}.tar.gz" && \
    echo "${MODULE_CHECKSUM}  ${MODULE_VERSION}.tar.gz" | shasum -c && \
    tar -zxC /usr/src -f ${MODULE_VERSION}.tar.gz && \
    mv ${MODULE_NAME}-${MODULE_VERSION}/ ${MODULE_NAME} && \
    cd /usr/src/nginx-1.21.4 && \
    ./configure --add-module=../${MODULE_NAME}/ --prefix=/opt/nginx --user=www-data --group=www-data --with-threads --with-file-aio --error-log-path=/var/log/nginx/error.log && \
    make && make modules && make install

# Install ImageMagick
RUN git clone https://github.com/Imagick/imagick; \
    cd imagick; \
    phpize && ./configure; \
    make; \
    make install; \
    docker-php-ext-enable imagick; 

# Install PHP Extensions
RUN docker-php-ext-install pdo_mysql mysqli bcmath && \
    docker-php-ext-configure gd --with-webp --with-jpeg=/usr --with-freetype=/usr/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install exif && \
    pecl install -o -f redis xdebug  && \
    rm -rf /tmp/pear  && \
    docker-php-ext-enable redis xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Clean
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false autoconf dpkg-dev file g++ gcc make pkgconf re2c libcurl4-nss-dev libjpeg-dev libpng-dev libpq-dev libjpeg62-turbo-dev libxml2-dev libxslt1-dev libfreetype6-dev libmagickwand-dev libpcre++-dev zlib1g-dev git libwebp-dev; \
    rm -rf /var/lib/apt/lists/*; \
    chmod 777 /tmp

COPY php.ini /usr/local/etc/php/php.ini
COPY nginx-site.conf /opt/nginx/conf/nginx.conf
COPY entrypoint.sh /etc/entrypoint.sh

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["sh", "/etc/entrypoint.sh"]