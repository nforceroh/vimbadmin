FROM ghcr.io/nforceroh/nginx-php:3.24

ARG \
  BUILD_DATE=now \
  VERSION=unknown \
  VIMBADMIN_VERSION=3.4.1

LABEL \
  org.label-schema.maintainer="Sylvain Martin (sylvain@nforcer.com)" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.vcs-url="https://github.com/nforceroh/vimbadmin" \
  org.label-schema.vcs-ref="${VERSION}" \
  org.label-schema.schema-version="1.0"

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

### Install ViMbAdmin from a pinned release
# php85-simplexml/ctype/iconv/zip/gettext: required by ViMbAdmin (doctrine XML
# mapping needs simplexml) but not in the nginx-php base.
RUN apk add --no-cache git mysql-client \
      php85-simplexml php85-ctype php85-iconv php85-zip php85-gettext \
  && mkdir -p ${INSTALL_PATH} \
  && curl -fsSL "https://github.com/opensolutions/ViMbAdmin/archive/refs/tags/${VIMBADMIN_VERSION}.tar.gz" \
      | tar xz --strip-components=1 -C ${INSTALL_PATH} \
  && cd ${INSTALL_PATH} \
  && composer install --prefer-dist --no-dev --no-interaction \
  && composer clear-cache \
  && chown -R www-data:www-data ${INSTALL_PATH} \
  && rm -rf /var/cache/apk/*

### Add Files
ADD /content /
ADD --chmod=755 /content/etc/s6-overlay /etc/s6-overlay

WORKDIR /data/web/vimbadmin

EXPOSE 8080

ENTRYPOINT [ "/init" ]
