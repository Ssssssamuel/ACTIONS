FROM wordpress:php7.1-apache

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i '/Redirect/d' /etc/apache2/sites-available/000-default.conf

COPY . /var/www/html
EXPOSE 80