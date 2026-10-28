# GLPI 11 - Installation Sécurisée & Mise à jour
## Installation
### Socle LAMP (Mode FPM) et Dépendances requises par GLPI
```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y apache2 mariadb-server php-fpm \
    php-xml php-common php-mysql php-mbstring \
    php-curl php-gd php-intl php-zip php-bz2 php-imap \
    php-apcu php-ldap php-bcmath

# Activation du mode FPM sur Apache
sudo a2enmod proxy_fcgi setenvif rewrite headers
sudo a2enconf php8.3-fpm
sudo systemctl restart apache2
```
### Création BDD et Utilisateur
```bash
sudo mysql_secure_installation

sudo mysql -u root -p <<EOF
CREATE DATABASE glpi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'MOT_DE_PASSE_FORT';
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';
FLUSH PRIVILEGES;
EOF
```
### Téléchargement & Structure Sécurisée
```bash
cd /tmp
# Télécharger la dernière version stable
wget https://github.com/glpi-project/glpi/releases/download/11.0.10/glpi-11.0.10.tgz
sudo tar -xzvf glpi-11.0.10.tgz -C /var/www/

# 1. Config -> /etc/glpi
sudo mkdir -p /etc/glpi
sudo mv /var/www/glpi/config/* /etc/glpi/

# 2. Files -> /var/lib/glpi
sudo mkdir -p /var/lib/glpi/files
sudo mv /var/www/glpi/files/* /var/lib/glpi/files/

# 3. Logs -> /var/log/glpi
sudo mkdir -p /var/log/glpi

# Permissions
sudo chown -R www-data:www-data /var/www/glpi /etc/glpi /var/lib/glpi /var/log/glpi
```
## Liaison PHP (Downstream) pour indiquer à GLPI où trouver ses fichiers.
### Créer /var/www/glpi/inc/downstream.php
```php
<?php
define('GLPI_CONFIG_DIR', '/etc/glpi/');
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
   require_once GLPI_CONFIG_DIR . '/local_define.php';
}
```
### Créer /etc/glpi/local_define.php
```php
<?php
define('GLPI_VAR_DIR', '/var/lib/glpi/files');
define('GLPI_LOG_DIR', '/var/log/glpi');
```
## Configuration Apache (/etc/apache2/sites-available/glpi.conf) :
```apache
<VirtualHost *:80>
    ServerName glpi.domaine.fr
    DocumentRoot /var/www/glpi/public

    <Directory /var/www/glpi/public>
        Require all granted
        RewriteEngine On
        # Redirection vers le routeur GLPI
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.3-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    ErrorLog ${APACHE_LOG_DIR}/glpi_error.log
    CustomLog ${APACHE_LOG_DIR}/glpi_access.log combined
</VirtualHost>
```
## Configuration de php (/etc/php/8.3/fpm/php.ini)
```ini
session.cookie_httponly = on
```
## Appliquer les configurations
```bash
sudo a2dissite 000-default.conf
sudo a2ensite glpi.conf
sudo systemctl reload apache2
systemctl restart php8.3-fpm.service
```
## Sécurisation Finale une fois l'installation Web terminée
```bash
sudo rm /var/www/glpi/install/install.php
```

## Installation Plugin Inventory
```bash
cd /tmp
sudo apt install bzip2
wget https://github.com/glpi-project/glpi-inventory-plugin/releases/download/1.7.0/glpi-glpiinventory-1.7.0.tar.bz2
sudo tar -jxvf glpi-glpiinventory-1.7.0.tar.bz2 -C /var/www/glpi/plugins/
sudo chown -R www-data:www-data /var/www/glpi/plugins
```
## Procédure de Mise à Jour
### Sauvegarde 
#### Base de données GLPI
```bash
sudo mysqldump -u root -p glpi > /home/glpi_adm/glpi_backup_$(date +%F).sql
```
#### Sauvegarde du code
```bash
sudo cp -r /var/www/glpi /var/www/glpi_old_$(date +%F)
```
#### Nettoyer l'ancien code (SAUF downstream.php qui contient nos chemins custom)
```bash
sudo cp /var/www/glpi/inc/downstream.php /tmp/downstream.php.save
sudo rm -rf /var/www/glpi/*
```
#### Télécharger la nouvelle version et déploiment du nouveau code
```bash
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/11.0.11/glpi-11.0.11.tgz
sudo tar -xzvf glpi-11.0.11.tgz -C /var/www/
```
#### Restaurer le lien et les plugins
```bash
sudo cp /tmp/downstream.php.save /var/www/glpi/inc/downstream.php
sudo cp -r /var/www/glpi_old_*/plugins/* /var/www/glpi/plugins/
sudo cp -r /var/www/glpi_old_*/marketplace/* /var/www/glpi/marketplace/
```
#### Permissions
```bash
sudo chown -R www-data:www-data /var/www/glpi
```
### Migration BDD
```bash
sudo -u www-data php /var/www/glpi/bin/console db:update
```