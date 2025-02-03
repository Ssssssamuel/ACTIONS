FROM wordpress:php7.1-apache

COPY . /var/www/html
RUN sed -i 's/8080/80/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
EXPOSE 80