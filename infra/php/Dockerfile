FROM docker.io/composer:latest AS composer

FROM docker.io/php:8.2-fpm
# System deps
RUN (command -v apk >/dev/null && apk add --no-cache curl) || (apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*)
RUN apt-get update && apt-get install -y \
    git unzip zip procps net-tools \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Set working dir
WORKDIR /var/www/html

# Fix permissions for Laravel
RUN usermod -u 1000 www-data

# CMD ["php-fpm", "-F"] # this command is already set by the base image, no need to redefine it