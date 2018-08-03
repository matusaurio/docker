# In FROM we specified the image that we want to use, in this case, I used an oficial image of PHP.
# available in https://hub.docker.com/_/php/ the instruction “FROM php” get the image on this link.
# “:5.4-apache”, get the specific version of PHP with Apache
# Look the link to other available versions.
FROM php:5.6-apache
# In MAINTAINER we can specify the creator and that keeps this dockerfile version.
MAINTAINER Santiago Benalcazar <santiagosdbc@gmail.com>
# The RUN allows to execute commands within the container, the docker-php-ext-install installs PHP extensions within the container.
# install the PHP extensions we need
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
    apt-utils \
    zlib1g-dev \
    libicu-dev g++ \
    nano \
    build-essential \
    zip \
    unzip \
    zlib1g-dev \
    curl \
    libmcrypt-dev \
    libreadline-dev \
    libmagickwand-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
  docker-php-ext-configure intl; \
	docker-php-ext-install gd mysqli pdo opcache zip mcrypt intl mbstring; \
	\

# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Apache
COPY config/custom.conf /etc/apache2/sites-enabled
COPY config/apache2.conf /etc/apache2
COPY config/000-default.conf /etc/apache2/sites-enabled
RUN touch /var/log/apache2/php_err.log && chown www-data:www-data /var/log/apache2/php_err.log
COPY config/php_error.ini /usr/local/etc/php/conf.d/php_error.ini
COPY config/php.ini /usr/local/etc/php/php.ini

#a2enmod
RUN a2enmod rewrite expires
RUN a2enmod headers

# Restart apache2
RUN service apache2 restart

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
RUN apt-get install -y nodejs

# Gulp
RUN npm install --global gulp-cli
