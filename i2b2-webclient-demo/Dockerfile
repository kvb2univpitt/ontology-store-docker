FROM php:8.4-apache

LABEL maintainer="Kevin Bui"

# Utilities
RUN apt update && apt clean && apt autoclean && rm -r /var/lib/apt/lists/*

# COPY i2b2-webclient-1.8.3.tar.gz /tmp
RUN curl -s -L -o /tmp/i2b2-webclient-1.8.3.tar.gz https://github.com/i2b2/i2b2-webclient/archive/refs/tags/v1.8.3.tar.gz
RUN tar xzf /tmp/i2b2-webclient-1.8.3.tar.gz -C /var/www/html/
RUN mv /var/www/html/i2b2-webclient-1.8.3 /var/www/html/webclient
RUN rm -f /tmp/i2b2-webclient-1.8.3.tar.gz

COPY resources/www/ /var/www/html/

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY resources/apache2/ports.conf /etc/apache2/ports.conf
COPY resources/apache2/sites-available/ /etc/apache2/sites-available/

# Disable Sites
RUN a2dissite 000-default.conf

# Enable Sites
RUN a2ensite wildfly.conf

# Enable Modules
RUN a2enmod proxy && a2enmod proxy_http

EXPOSE 80

CMD ["apache2-foreground"]
