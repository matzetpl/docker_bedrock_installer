# Use the official PHP image as the base image
FROM php:8.0-fpm

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    wget \
    vim \
    && rm -rf /var/lib/apt/lists/*

# RUN chown -R www-data:www-data /var/www/html \
#     && find /var/www/html -type d -exec chmod 755 {} \; \
#     && find /var/www/html -type f -exec chmod 644 {} \;

# Install PHP extensions
# Install required packages and dependencies
RUN apt-get update && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg

RUN apt-get install -y default-mysql-client


RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp


RUN docker-php-ext-install gd mysqli zip

RUN apt-get install curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="/var/www/html/vendor/bin:${PATH}"

WORKDIR /var/www/html
COPY ./app_files /var/www/html

RUN composer require roots/acorn
RUN composer install --no-interaction


# Set up Composer

# Set the working directory
WORKDIR /var/www/html


# Start PHP-FPM
CMD ["php-fpm"]
