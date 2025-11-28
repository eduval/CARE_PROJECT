#!/bin/bash
set -e

# -------------------------------
# VARIABLES
# -------------------------------
DB_NAME="wordpress"
DB_ROOT_PASS="101395Jimin!"
REPO_OWNER="eduval"
REPO_NAME="CARE_PROJECT"
BACKUP_DIR="/tmp/wp_backup"

# -------------------------------
# INSTALL REQUIRED PACKAGES
# -------------------------------
apt update -y
apt install -y apache2 mysql-server php php-mysql php-xml php-mbstring php-curl php-zip php-gd unzip curl git

systemctl enable mysql
systemctl start mysql

# -------------------------------
# DOWNLOAD BACKUP FILES FROM GITHUB (PUBLIC REPO – NO TOKEN NEEDED)
# -------------------------------
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

curl -L -o wordpress_files.tar.gz \
  "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/wordpress_files.tar.gz"

curl -L -o wordpress_db.sql \
  "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/wordpress_db.sql"

# -------------------------------
# RESTORE DATABASE
# -------------------------------
mysql -u root -p"${DB_ROOT_PASS}" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
mysql -u root -p"${DB_ROOT_PASS}" -e "CREATE DATABASE ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p"${DB_ROOT_PASS}" "${DB_NAME}" < wordpress_db.sql

# -------------------------------
# RESTORE WORDPRESS FILES
# -------------------------------
rm -rf /var/www/html/*
tar -xzf wordpress_files.tar.gz -C /var/www/html

# Fix permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

systemctl restart apache2

# -------------------------------
# DONE
# -------------------------------
echo "WordPress fully restored."
echo "Open your restored website:"
echo "http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
