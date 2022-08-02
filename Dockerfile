FROM php:8.1.7-apache

# Instalar as extensões do PHP necessárias para o funcionamento do Laravel Lumen
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Instalar o Composer (PHP Composer)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalar o Git
RUN apt-get install -y zip git

# Configurações do Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/api/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite

RUN ps aux | egrep '(apache|httpd)'