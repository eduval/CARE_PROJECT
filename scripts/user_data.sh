#!/bin/bash
set -e

DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="101395Jimin!"
REPO_OWNER="eduval"
REPO_NAME="CARE_PROJECT"
BACKUP_DIR="/tmp/wp_backup"

apt update -y
apt install -y apache2 mysql-server php php-mysql php-xml php-mbstring php-curl php-zip php-gd unzip curl git

systemctl enable mysql
systemctl start mysql

# Configure MySQL
sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';
FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS ${DB_NAME};
CREATE DATABASE ${DB_NAME};

DROP USER IF EXISTS '${DB_USER}'@'localhost';
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

curl -L -o wordpress_files.tar.gz "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/wordpress_files.tar.gz"
curl -L -o wordpress_db.sql "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/wordpress_db.sql"

mysql -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < wordpress_db.sql

rm -rf /var/www/html/*
tar -xzf wordpress_files.tar.gz -C /var/www/html

# Inject dynamic URL in wp-config.php
sudo bash -c 'cat <<EOF >> /var/www/html/wp-config.php

define("WP_HOME", "http://" . \$_SERVER["HTTP_HOST"]);
define("WP_SITEURL", "http://" . \$_SERVER["HTTP_HOST"]);
EOF'

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

systemctl restart apache2

echo "WordPress fully restored."
echo "Open: http://$(curl -s http://169.254.169.254/latest-meta-data/public-ipv4)"
