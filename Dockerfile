FROM debian:buster

ENV AUTOINDEX=on

COPY ./srcs/start.sh ./
COPY ./srcs/localhost.conf /tmp/
COPY ./srcs/config.inc.php /tmp/
COPY ./srcs/wp-config.php /tmp/

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get install -y nginx openssl vim wget unzip mariadb-server mariadb-client \
        php php-common php-fpm php-mysql php-curl php-mysql php-gd php-cli php-mbstring php-xml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/nginx/ssl \
    && openssl genrsa -out /etc/nginx/ssl/server.key 2048 \
    && openssl req -new -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr -subj "/CN=localhost" \
    && openssl x509 -days 3650 -req -signkey /etc/nginx/ssl/server.key -in /etc/nginx/ssl/server.csr -out /etc/nginx/ssl/server.crt \
    && mv /tmp/localhost.conf /etc/nginx/conf.d/

RUN service mysql start && mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';" \
    && mysql -u root -proot -e "CREATE DATABASE wpdb;" \
    && mysql -u root -proot -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';" \
    && mysql -u root -proot -e "GRANT ALL ON wpdb.* TO 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';"

RUN wget -P /tmp/ https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.zip \
    && unzip /tmp/phpMyAdmin-5.1.0-all-languages -d /var/www/html/ \
    && mv /var/www/html/phpMyAdmin-5.1.0-all-languages/ /var/www/html/phpmyadmin/ \
    && rm -rf /tmp/phpMyAdmin-5.1.0-all-languages.zip \
    && mv /tmp/config.inc.php /var/www/html/phpmyadmin/

RUN wget -P /tmp/ https://wordpress.org/latest.tar.gz \
    && tar -zxvf /tmp/latest.tar.gz -C /var/www/html/ \
    && rm -rf /tmp/latest.tar.gz \
    && mv /tmp/wp-config.php /var/www/html/wordpress/

RUN chown www-data:www-data -R /var/www/html/* \
    && find /var/www/html/ -type d -exec chmod 755 {} + \
    && find /var/www/html/ -type f -exec chmod 644 {} +

CMD bash ./start.sh
