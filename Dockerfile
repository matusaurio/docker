# In FROM we specified the image that we want to use, in this case, I used an oficial image of PHP.
# available in https://hub.docker.com/_/php/ the instruction “FROM php” get the image on this link.
# “:5.4-apache”, get the specific version of PHP with Apache
# Look the link to other available versions.
FROM php:5.6-apache
# In MAINTAINER we can specify the creator and that keeps this dockerfile version.
MAINTAINER Santiago Benalcazar <santiagosdbc@gmail.com>
# Maybe you want to install intl then
RUN apt-get update && apt-get install -y zlib1g-dev libicu-dev g++ nano
# The RUN allows to execute commands within the container, the docker-php-ext-install installs PHP extensions within the container.
# You can also add after other extensions desired.
RUN docker-php-ext-install mysql mysqli pdo pdo_mysql
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl
# And mbstring you may need
RUN docker-php-ext-install mbstring
# Apache
COPY config/custom.conf /etc/apache2/sites-enabled
COPY config/apache2.conf /etc/apache2
COPY config/000-default.conf /etc/apache2/sites-enabled
RUN touch /var/log/apache2/php_err.log && chown www-data:www-data /var/log/apache2/php_err.log
COPY config/php_error.ini /usr/local/etc/php/conf.d/php_error.ini
RUN a2enmod rewrite
RUN service apache2 restart
# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"
