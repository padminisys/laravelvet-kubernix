# Use an official PHP image with Apache and PHP 8.1
FROM php:8.1-apache

# Install system dependencies required for PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions required by Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd pdo pdo_mysql mbstring exif pcntl bcmath xml

# Enable Apache mod_rewrite for Laravel's .htaccess file
RUN a2enmod rewrite

# Copy your Laravel application into the container
COPY . /var/www/html

# Update the Apache document root to point to the public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set the working directory to the Laravel app
WORKDIR /var/www/html

# Install Composer - ensure you use the official way to install Composer to get the latest version
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Ensure files are owned by the www-data user
RUN chown -R www-data:www-data /var/www/html

# Open port 80 for the Apache server
EXPOSE 80
