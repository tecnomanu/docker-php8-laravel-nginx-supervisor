FROM php:8.3-fpm-alpine AS base

ARG INSTALL_MYSQL=false
ARG INSTALL_PGSQL=true
ARG INSTALL_MONGO=false
ARG INSTALL_ECHO=true

# Timezone, basics and system dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache bash git zip unzip curl supervisor nginx sqlite icu-dev oniguruma-dev gmp-dev libzip-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev libxml2-dev libtool openssl-dev linux-headers gettext-dev \
    libmcrypt-dev autoconf g++ make zlib-dev pkgconf re2c nodejs npm

RUN apk add ffmpeg

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install bcmath bz2 exif ftp gd gmp intl mbstring opcache pdo shmop sockets sysvmsg sysvsem sysvshm zip gettext

# Conditional: MySQL
RUN if [ "$INSTALL_MYSQL" = "true" ]; then \
    docker-php-ext-install pdo_mysql; \
    fi

# Conditional: MongoDB
RUN if [ "$INSTALL_MONGO" = "true" ]; then \
    pecl install mongodb && docker-php-ext-enable mongodb; \
    fi

# Conditional: Laravel Echo Server
RUN if [ "$INSTALL_ECHO" = "true" ]; then \
    npm install -g laravel-echo-server; \
    fi

# Conditional: PostgreSQL
RUN if [ "$INSTALL_PGSQL" = "true" ]; then \
    apk add --no-cache --virtual .pgsql-deps postgresql-dev libpq-dev && \
    docker-php-ext-install pdo_pgsql && \
    apk del .pgsql-deps; \
    fi

# Redis always included
RUN pecl install redis && docker-php-ext-enable redis

# Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Create dirs and config
RUN mkdir -p /etc/supervisor.d /run/nginx /var/www /var/log/supervisor /var/log/nginx && \
    touch /run/nginx/nginx.pid /run/supervisord.sock && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Copy configs (placeholder paths)
COPY ./docker-compose/supervisord/supervisord.ini /etc/supervisor.d/supervisord.ini
COPY ./docker-compose/crontab /etc/crontabs/root
COPY ./docker-compose/php/local.ini /usr/local/etc/php/php.ini
COPY ./docker-compose/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker-compose/nginx/conf.d/app.conf /etc/nginx/http.d/default.conf

WORKDIR /var/www
EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
