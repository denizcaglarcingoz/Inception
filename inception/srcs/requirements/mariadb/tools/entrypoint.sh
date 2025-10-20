#!/bin/sh
set -eu

DBDIR="/var/lib/mysql"
SOCK="/run/mysqld/mysqld.sock"

# Ensure required directories exist and belong to mysql user
mkdir -p /run/mysqld "$DBDIR"
chown -R mysql:mysql /run/mysqld "$DBDIR"

# Initialize database system tables on first run
if [ ! -d "$DBDIR/mysql" ]; then
  echo ">> Initializing MariaDB data directory..."
  mariadb-install-db --user=mysql --datadir="$DBDIR" --skip-test-db >/dev/null

  echo ">> Starting temporary server for bootstrap (socket only)..."
  mysqld_safe --skip-networking --socket="$SOCK" --datadir="$DBDIR" --user=mysql &

  # Wait up to ~30s for the socket to be ready
  i=0
  while [ $i -lt 30 ]; do
    if mysqladmin --protocol=socket --socket="$SOCK" ping --silent 2>/dev/null; then
      break
    fi
    i=$((i+1))
    sleep 1
  done

  echo ">> Creating root password, app database, and user..."
  mariadb --protocol=socket --socket="$SOCK" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

  echo ">> Shutting down temporary MariaDB..."
  mysqladmin --protocol=socket --socket="$SOCK" -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

echo ">> Starting MariaDB in foreground..."
exec mariadbd --user=mysql --datadir="$DBDIR" --bind-address=0.0.0.0 --console

