FROM php:8.2-apache

# Asenna tarvittavat riippuvuudet
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev libicu-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip intl xml gd

# Ota käyttöön Apache:n rewrite moduuli
RUN a2enmod rewrite

# Kopioi lähdekoodi containeriin
COPY . /var/www/html

# Aseta oikeudet
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Siirry sovelluskansioon
WORKDIR /var/www/html

# Asenna Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Luo .env-tiedosto, jos ei ole
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Suorita BookStackin alustustoimet
RUN php artisan key:generate

# Avaa portti 80 (Apache)
EXPOSE 80
