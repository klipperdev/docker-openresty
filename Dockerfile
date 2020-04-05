FROM openresty/openresty:1.15.8.1rc2-1-alpine-fat

LABEL maintainer="François Pluchino <françois.pluchino@klipper.dev>"

RUN mkdir -p /var/www/html \
    && mkdir -p /var/log/nginx \
    && mkdir -p /etc/resty-auto-ssl/storage/file

# Custom Auto SSL and PostgreSQL
RUN apk add --update --no-cache \
        openssl \
    && apk add --update --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
        git \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python \
    && /usr/local/openresty/luajit/bin/luarocks install pgmoon 1.10.0 \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-auto-ssl 0.12.0 \
    && apk del --purge *-dev build-base autoconf libtool .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man

RUN openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj '/CN=sni-support-required-for-valid-ssl' -keyout /etc/ssl/resty-auto-ssl-fallback.key -out /etc/ssl/resty-auto-ssl-fallback.crt

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
