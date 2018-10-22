# Add Apache/PHP
FROM tutum/apache-php

# Enable rewriting, enable overwride standards via htaccess
RUN sed -ni '1h;1!H;${g;s/<Directory \/var\/www\/>.*<\/Directory>/<Directory \/var\/www\/html\/>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n<\/Directory>/;p;}' /etc/apache2/apache2.conf

# Update the container
RUN apt-get update && apt-get install -yq git mysql-client && rm -rf /var/lib/apt/lists/*

# Add mcrypt to PHP
RUN php5enmod mcrypt

# Enable modrewrite
RUN a2enmod rewrite

# Delete the default /app folder
RUN rm -fr /app

# Add the repo to the /app folder
ADD . /app

# Remove the default document root folder
RUN rm -rf /var/www/html

# Symlink the repo to the document root
RUN ln -s /app /var/www/html

# Remove SFTP config file
RUN rm -rf /app/sftp-config*.json

# CHMOD cache folder
RUN chmod 0777 /app/app/cache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN composer self-update

# Add the crontab to the crontabs folder
RUN apt-get -y install rsyslog
ADD crontab /etc/crontab
RUN touch /var/log/cron.log

WORKDIR /app

RUN composer install --prefer-source --no-interaction

EXPOSE 80