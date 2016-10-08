FROM php:7-fpm-alpine
MAINTAINER Dave Wikoff <dgsims@gmail.com>

ENV PHP_INI_PATH=/usr/local/etc/php/php.ini

# Build Dependencies
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
	# gd deps
	freetype-dev \
	libpng-dev \
	libwebp-dev \
	jpeg-dev \
	# mcrypt deps
	libmcrypt-dev \
    # xsl deps
    libxslt-dev

# PHP Extensions
RUN docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-freetype-dir=/usr/include/ && \
	docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) \
    mysqli \
    pdo_mysql \
    opcache \
    mcrypt  \
    sockets \
    xsl \
    zip \
    gd \
    soap xmlrpc

# PHP Third Party Extensions
RUN docker-php-source extract && \
	pecl install xdebug redis && \
	docker-php-ext-enable xdebug redis && \
    docker-php-source delete

# Run-time Extension Dependencies & Clean up Build Dependencies
RUN apk add --no-cache --virtual .run-deps \
    # gd deps
	libpng jpeg libwebp freetype \
    # mcrypt deps
    libmcrypt \
    # xsl deps
    libxslt && \
    apk del .build-deps

# Other Packages (Eventually move over to CLI Container)
RUN apk add --no-cache \
	bash \
    zip \
    vim \
    zsh \
    sudo \
    git

# Don't run pph.ini so we can make sure xdebug isn't enabled
RUN curl -sS https://getcomposer.org/installer | php -n -- --install-dir=/usr/bin/ --filename=composer.phar

COPY etc/php.ini $PHP_INI_PATH
COPY etc/composer.sh /usr/bin/composer
COPY etc/profile /etc/profile

ENV PATH=/root/.composer/vendor/bin:$PATH

# Composer
RUN composer global require \
      'hirak/prestissimo:^0.3' && \
    composer global require \
      drush/drush \
      drush/config-extra \
      drupal/console \
      wp-cli/wp-cli && \
    drupal init --override

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
