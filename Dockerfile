FROM php:7.2-apache

# enable apache2 modules
RUN a2enmod rewrite
RUN a2enmod ssl

# update package list && install
RUN apt-get update && apt-get install -yq \
        unzip \
        curl \
        git \
        unzip \
        libicu-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        default-mysql-client \
        libmcrypt-dev \
        wget \
        zlib1g-dev \
        libpcre3-dev \
        locales

# remove apt lists
RUN rm -rf /var/lib/apt/lists/*

# generate some locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen
# make german default
RUN echo "LC_ALL=de_DE.UTF8\nLANG=de_DE.UTF8\nLANGUAGE=de_DE.UTF8" > /etc/default/locale
RUN cat /etc/default/locale
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8

# install php extentions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install gd mysqli zip mbstring pdo pdo_mysql soap ftp opcache xml bcmath
RUN pecl install mcrypt-1.0.1 && docker-php-ext-enable mcrypt
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl
RUN pecl install apcu
RUN docker-php-ext-enable apcu
RUN pecl install xdebug

# set up php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# change memory limit to 512M
RUN sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI_DIR/php.ini"
