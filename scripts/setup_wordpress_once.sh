#!/bin/bash
# Script para instalar Apache, MySQL, PHP y WordPress
# Susana / Proyecto QA

set +H  # por la contraseña con '!'

DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="101395Jimin!"
DB_ROOT_PASS="101395Jimin!"

echo "=== 1) Actualizando sistema ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== 2) Instalando Apache, MySQL y PHP ==="
sudo apt install -y apache2 mysql-server php php-mysql php-xml php-mbstring php-curl php-zip php-gd unzip curl

echo "=== 3) Habilitando y arrancando MySQL ==="
sudo systemctl enable mysql
sudo systemctl start mysql

echo "=== 4) Configurando usuario root de MySQL ==="
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASS}'; FLUSH PRIVILEGES;"

echo "=== 5) Creando base de datos y usuario para WordPress ==="
mysql -u root -p"${DB_ROOT_PASS}" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
mysql -u root -p"${DB_ROOT_PASS}" -e "CREATE DATABASE ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p"${DB_ROOT_PASS}" -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';"
mysql -u root -p"${DB_ROOT_PASS}" -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -p"${DB_ROOT_PASS}" -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

echo "=== 6) Descargando WordPress ==="
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

echo "=== 7) Copiando WordPress a /var/www/html ==="
sudo rm -rf /var/www/html/*
sudo cp -r /tmp/wordpress/* /var/www/html/

echo "=== 8) Creando wp-config.php ==="
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php

sudo sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sudo sed -i "s/username_here/${DB_USER}/" wp-config.php
sudo sed -i "s/password_here/${DB_PASS}/" wp-config.php

echo "=== 9) Ajustando permisos ==="
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

echo "=== 10) Reiniciando Apache ==="
sudo systemctl restart apache2

echo "====================================="
echo "✅ WordPress instalado."
echo "Abre en tu navegador:  http://TU_IP_PUBLICA"
echo "====================================="
