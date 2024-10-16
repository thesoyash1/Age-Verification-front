FROM php:8.1-apache
WORKDIR /var/www/html
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql zip exif pcntl gd
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl
RUN docker-php-ext-install pdo && docker-php-ext-enable pdo
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash -
RUN apt-get install -y nodejs
RUN mkdir -p storage/framework/cache/data \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/framework/sessions \
    && chown -R www-data:www-data storage 
RUN npm update -g npm
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerName localhost
    ServerAlias localhost
    ServerAdmin webmaster@localhost

    DocumentRoot /var/www/html/public
    ErrorLog \${APACHE_LOG_DIR}/localhost-error.log
    CustomLog \${APACHE_LOG_DIR}/localhost-access.log combined

    <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>

</VirtualHost>
EOF

RUN a2enmod rewrite
RUN a2ensite 000-default.conf
RUN service apache2 restart
RUN apt-get update && apt-get upgrade -y
