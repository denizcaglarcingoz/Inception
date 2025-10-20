#!/bin/sh
set -eu

CERT_DIR=/etc/ssl
KEY="$CERT_DIR/private/inception.key"
CRT="$CERT_DIR/certs/inception.crt"

# I use this DOMAIN_NAME env if provided
: "${DOMAIN_NAME:=dcingoz.42.fr}"

# create dirs if they don't exist
mkdir -p "$(dirname "$KEY")" "$(dirname "$CRT")"

# generate cert only if not present (so restarts keep the same cert inside container filesystem)
if [ ! -f "$KEY" ] || [ ! -f "$CRT" ]; then
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CRT" \
    -subj "/C=AT/ST=Vienna/L=Vienna/O=42/OU=students/CN=${DOMAIN_NAME}"
fi

# exec the final command (keeps PID 1 handled by Docker)
exec "$@"

