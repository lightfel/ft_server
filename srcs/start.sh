#!/bin/bash

if [ "$AUTOINDEX" = "off" ]; then
	sed -i -e 's/autoindex on/autoindex off/g' /etc/nginx/conf.d/localhost.conf
fi

/etc/init.d/php7.3-fpm start
service mysql start
service nginx start

tail -f /dev/null
