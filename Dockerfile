FROM php:8.1-fpm-alpine

# Arguments defined in docker-compose.yml
#ARG user
#ARG uid

# Install system dependencies
#RUN apt-get update && apt-get install -y \
#    git \
#    curl \
#    libpng-dev \
#    libonig-dev \
#    libxml2-dev \
#    zip \
#    unzip
RUN apk update && apk add  --no-cache \
    git \
    mysql-client \
    curl \
    mc \
    libmcrypt \
    libmcrypt-dev \
    libxml2-dev \
    freetype \
    freetype-dev \
    linux-headers \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev g++ make autoconf curl-dev openssl-dev

# drupal requirement
#RUN docker-php-ext-install opcache
#RUN apk add --update --no-cache libmemcached-dev
#RUN pecl install memcached && docker-php-ext-enable memcached


# Use the default production configuration
#RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Use the default development configuration
#RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY docker/php/php.ini-development "$PHP_INI_DIR/php.ini"
#COPY docker/php/cacert.pem "$PHP_INI_DIR/cacert.pem"

RUN pecl config-set php_ini "$PHP_INI_DIR/php.ini"

# sockets
RUN docker-php-ext-install sockets

# gd
RUN apk add --no-cache \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        freetype-dev
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# zip
RUN apk add --no-cache \
      libzip-dev \
      zip \
    && docker-php-ext-install zip
#RUN docker-php-ext-configure zip \
#    && docker-php-ext-install -j$(nproc) zip

# Install xdebug
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# gd
#RUN docker-php-ext-configure gd \
#    --with-freetype=/usr/include/ \
#    # --with-png=/usr/include/ \ # No longer necessary as of 7.4; https://github.com/docker-library/php/pull/910#issuecomment-559383597
#    --with-jpeg=/usr/include/ \
#RUN docker-php-ext-install -j$(nproc) gd \

# mongodb
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

# mysql
RUN docker-php-ext-install pdo_mysql


# Install PHP extensions
#RUN docker-php-ext-install -j5 gd mysqli


# Get latest Composer
#COPY --from=composer:latest /usr/bin/composer /usr/bin/composer \
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create system user to run Composer and Artisan Commands
#RUN useradd -G www-data,root -u $uid -d /home/$user $user
#RUN mkdir -p /home/$user/.composer && \
#    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

# Remove Cache
#RUN rm -rf /var/cache/apk/*

# Match with UAT1
#RUN apk --no-cache add shadow && \
#    usermod -u 48 www-data && \
#    groupmod -g 48 www-data

# Copy existing application directory permissions
RUN chown -R www-data:www-data /var/www/

#USER $user

#ENTRYPOINT ["php-fpm", "-c", "/usr/local/etc/php/php.ini"]

# Setup nginx & supervisor as root user
USER root
RUN apk add --no-progress --quiet --no-cache nginx supervisor
COPY docker/nginx/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf

# Apply the required changes to run nginx as www-data user
RUN apk add  --no-cache nginx
RUN chown -R www-data:www-data /run/nginx /var/lib/nginx /var/log/nginx && \
    sed -i '/user nginx;/d' /etc/nginx/nginx.conf
# Switch to www-user
USER www-data
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
