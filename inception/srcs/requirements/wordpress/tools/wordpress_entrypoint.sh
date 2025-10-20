#!/bin/sh
set -eu

# The directory where the WordPress volume is mounted
WP_DIR="/var/www/html"

# --- 1. Wait for MariaDB to be ready ---
# This loop replaces the unreliable 'sleep 10'
echo ">> Waiting for MariaDB to be ready..."
while ! mariadb --host=mariadb --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --execute="SELECT 1;" >/dev/null 2>&1; do
    sleep 1 
done
echo ">> MariaDB is ready."

# --- 2. Check if WordPress is already set up ---
if [ ! -f "$WP_DIR/wp-config.php" ]; then
    echo ">> WordPress not found. Starting fresh installation..."

    # --- 3. Download and Configure WordPress ---
    # Download core files using WP-CLI
    wp core download --allow-root --path="$WP_DIR"

    # Create wp-config.php with database credentials from .env
    # This method is more secure because it fetches fresh security keys from the WordPress API.
    wp config create --allow-root --path="$WP_DIR" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --force

    # --- 4. Install WordPress and Create Users ---
    # This uses the WP_* variables from your .env file
    wp core install --allow-root --path="$WP_DIR" \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # Create the second user as required by the subject
    wp user create --allow-root --path="$WP_DIR" \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}"

    echo ">> WordPress installation complete."
else
    echo ">> WordPress is already configured."
fi

# --- 5. Ensure PHP-FPM is configured correctly ---
# This command makes sure PHP-FPM listens on a network port, not a socket.
# It's a robust way to ensure container-to-container communication works.
sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

# --- 6. Set correct file permissions ---
# Give the web server user ownership of all WordPress files.
chown -R www-data:www-data "$WP_DIR"

# --- 7. Start the main service ---
echo ">> Starting PHP-FPM..."
exec php-fpm8.2 -F


