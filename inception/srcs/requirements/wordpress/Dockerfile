FROM debian:12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    	ca-certificates \
        php8.2-fpm \
        php8.2-mysql \
        curl \
        mariadb-client \
        libfcgi-bin \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html

COPY tools/wordpress_entrypoint.sh /usr/local/bin/wordpress_entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress_entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress_entrypoint.sh"]

# docs.docker.com/reference/dockerfile
# for docker sytanx


