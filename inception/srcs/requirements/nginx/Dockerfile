FROM debian:12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        openssl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*


# copy nginx config and entrypoint
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY tools/nginx_entrypoint.sh /usr/local/bin/nginx_entrypoint.sh
RUN chmod +x /usr/local/bin/nginx_entrypoint.sh

# Exposes the HTTPS port whicha islike the general port shit for Ngixnx
EXPOSE 443


ENTRYPOINT [ "/usr/local/bin/nginx_entrypoint.sh" ]
# The command to start NGINX in the foreground, yeah we need foreground to kee PID 1 so docker don't shut
CMD ["nginx", "-g", "daemon off;"]


# docs.docker.com/reference/dockerfile
# for docker sytanx


