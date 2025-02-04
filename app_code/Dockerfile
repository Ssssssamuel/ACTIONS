FROM wordpress:php7.1-apache

RUN sed -i '/Redirect/d' /etc/apache2/sites-available/000-default.conf

COPY . /var/www/html
EXPOSE 80