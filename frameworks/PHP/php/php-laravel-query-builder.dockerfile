FROM ubuntu:19.10

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -yqq > /dev/null && \
    apt-get install -yqq nginx git unzip php7.4 php7.4-common php7.4-cli php7.4-fpm php7.4-mysql  php7.4-mbstring > /dev/null

RUN apt-get install -yqq composer > /dev/null

COPY deploy/conf/* /etc/php/7.4/fpm/

ADD ./ /php
WORKDIR /php

RUN if [ $(nproc) = 2 ]; then sed -i "s|pm.max_children = 2048|pm.max_children = 512|g" /etc/php/7.4/fpm/php-fpm.conf ; fi;

COPY deploy/eloquent/composer* ./
RUN composer install --optimize-autoloader --classmap-authoritative --no-dev --quiet

RUN chmod -R 777 /php

CMD service php7.4-fpm start && \
    nginx -c /php/deploy/nginx7.conf -g "daemon off;"
