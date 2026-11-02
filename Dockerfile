FROM ghcr.io/nforceroh/nginx-php:latest

ARG \
  BUILD_DATE=now \
  VERSION=unknown

LABEL \
  maintainer="Sylvain Martin (sylvain@nforcer.com)" 

ENV LANG=en_US.utf8 \
    INSTALL_PATH=/data/web/vimbadmin \
    VIMBADMIN_DB_NAME=vimbadmin \
    VIMBADMIN_DB_USER=vimbadmin2 \
    VIMBADMIN_DB_PASSWORD=vimbadmin2 \
    VIMBADMIN_DB_HOST=db \
    ADMIN_EMAIL=postmaster@example.com \
    ADMIN_PASSWORD=CHANGEME \
    SMTP_HOST=mail \
    OPCACHE_MEM_SIZE=64 \
    COMPOSER_HOME=/tmp \
    COMPOSER_ALLOW_SUPERUSER=1

RUN apk -U  add php83 php83-phar php83-json php83-pdo php83-pdo_mysql php83-gettext php83-opcache \
      php83-ctype php83-dom php83-gd php83-iconv php83-xml php83-mbstring php83-posix php83-zip php83-zlib php83-openssl php83-simplexml \
      php83-pear php83-dev php83-tokenizer git subversion nginx bzip2 sudo mysql-client patch curl zip unzip bash dovecot \
 && mkdir -p ${INSTALL_PATH}  \
 && curl -sS https://getcomposer.org/installer | php83 -- --filename=composer --install-dir=/usr/bin \
 && git clone https://github.com/opensolutions/ViMbAdmin.git ${INSTALL_PATH} \
 && cd ${INSTALL_PATH} \
 && /usr/bin/composer config -g secure-http false  \
 && /usr/bin/composer install --prefer-dist --no-dev  \
 && /usr/bin/composer clear-cache \
 && chown -R www-data:www-data ${INSTALL_PATH} \
 && rm -rf /var/cache/apk/* /tmp/*

ADD /content /
ADD --chmod=755 /content/etc/s6-overlay /etc/s6-overlay

WORKDIR /data/web/vimbadmin

EXPOSE 8080

ENTRYPOINT [ "/init" ]
