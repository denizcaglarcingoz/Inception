FROM debian:12-slim

RUN apt-get update && \
	apt-get install -y --no-install-recommends mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*
	
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


# docs.docker.com/reference/dockerfile
# for docker sytanx


