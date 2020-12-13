# Use an official Python runtime as a parent image
# CUSTOM: FROM circleci/php:7.3-node-browsers
FROM circleci/php:7.4-node-browsers

# Switch to root user
USER root

# Install gulp
RUN npm install -g gulp

# Install pa11y-ci
# https://github.com/puppeteer/puppeteer/issues/375#issuecomment-363466257
RUN npm install -g pa11y-ci --unsafe-perm=true

# Install lighthouse
RUN npm install -g lighthouse
RUN npm install -g circle-github-bot

# Install puppeteer for control of lighthouse
RUN npm install -g puppeteer --unsafe-perm=true
RUN npm install -g chrome-launcher

# Install necessary packages for PHP extensions
# Custom: Add vim & vnc4server metatcity
RUN apt-get update && \
     apt-get install -y \
        dnsutils \
        libmagickwand-dev \
        libzip-dev \
        libsodium-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        vim \
        vnc4server \
        metacity \
        x11vnc \
        iputils-ping

# Add necessary PHP Extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
# CUSTOM: Optional commands are not recognized with 7.4 image
RUN docker-php-ext-configure gd
RUN docker-php-ext-install gd

RUN docker-php-ext-configure sodium
RUN docker-php-ext-install sodium
RUN pecl install libsodium-2.0.21

RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN docker-php-ext-install bcmath



# Set the memory limit to unlimited for expensive Composer interactions
RUN echo "memory_limit=-1" > /usr/local/etc/php/conf.d/memory.ini

###########################
# Install build tools things
###########################

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Collect the components we need for this image
RUN apt-get update
RUN apt-get install -y ruby jq curl rsync
RUN gem install circle-cli

# Make sure we are on the latest version of Composer 1
# The world is not ready for Composer 2...
RUN composer selfupdate --1

# Parallel Composer downloads
RUN composer -n global require -n "hirak/prestissimo:^0.3"

# Create an unpriviliged test user
RUN groupadd -g 999 tester && \
    useradd -r -m -u 999 -g tester tester && \
    chown -R tester /usr/local && \
    chown -R tester /build-tools-ci
USER tester

# Install Terminus
RUN mkdir -p /usr/local/share/terminus
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/terminus require pantheon-systems/terminus:"^2"

# Install CLU
RUN mkdir -p /usr/local/share/clu
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/clu require danielbachhuber/composer-lock-updater:^0.8.0

# Install Drush
RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^10"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

# Add a collection of useful Terminus plugins
env TERMINUS_PLUGINS_DIR /usr/local/share/terminus-plugins
RUN mkdir -p /usr/local/share/terminus-plugins
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-build-tools-plugin:^2.0.0
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-clu-plugin:^1.0.3
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-secrets-plugin:^1.3
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-rsync-plugin:^1.1
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-quicksilver-plugin:^1.3
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-composer-plugin:^1.1
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-drupal-console-plugin:^1.1
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-mass-update:^1.1
RUN composer -n create-project --no-dev -d /usr/local/share/terminus-plugins pantheon-systems/terminus-site-clone-plugin:^2

# Add hub in case anyone wants to automate GitHub PR creation, etc.
RUN curl -LO https://github.com/github/hub/releases/download/v2.11.2/hub-linux-amd64-2.11.2.tgz && tar xzvf hub-linux-amd64-2.11.2.tgz && ln -s /build-tools-ci/hub-linux-amd64-2.11.2/bin/hub /usr/local/bin/hub

# Add lab in case anyone wants to automate GitLab MR creation, etc.
RUN curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | bash

# Add phpcs for use in checking code style
RUN mkdir ~/phpcs && cd ~/phpcs && COMPOSER_BIN_DIR=/usr/local/bin composer require squizlabs/php_codesniffer:^2.7

# Add phpunit for unit testing
RUN mkdir ~/phpunit && cd ~/phpunit && COMPOSER_BIN_DIR=/usr/local/bin composer require phpunit/phpunit:^8

# Add bats for functional testing
RUN git clone https://github.com/sstephenson/bats.git; bats/install.sh /usr/local

# Add Behat for more functional testing
# CUSTOM: Use Drupal Extension 4 + bex for screenshots.
RUN mkdir ~/behat && \
    cd ~/behat && \
    COMPOSER_BIN_DIR=/usr/local/bin \
    composer require \
        "drupal/drupal-extension:^4.1" \
        "drupal/drupal-driver:^2.1" \
        "genesis/behat-fail-aid:^3.5"
