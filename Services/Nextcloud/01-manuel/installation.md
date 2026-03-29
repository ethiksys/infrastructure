# INSTALLATION NEXTCLOUD 32 sur LXC ubuntu (Proxmox) - Installation Optimisée
```
Déploiement haute performance dans un conteneur système léger (LXC) sous Ubuntu, sans couche de virtualisation supplémentaire.

Recommandations doc officielle
Version : 32 (dernière stable)
System : Ubuntu 24.04 LTS
DataBase : MariaDB 11.8
WebServer : Apache 2.4 avec php-fpm
PHP : 8.4
```
## Préparation du système
### Mise à jour et dépendances
```bash
apt update && apt upgrade -y
apt install -y software-properties-common curl wget unzip imagemagick redis-server
```
### Ajout du dépôt PHP Ondřej (Pour avoir les dernières versions sur Ubuntu LTS)
```bash
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:ondrej/apache2 -y
apt update
```
## Installation de Apache/MariaDB/PHP
### Installation des paquets (PHP-FPM pour la perf)
```bash
apt install -y apache2 mariadb-server \
    php8.4-fpm php8.4-bcmath php8.4-gmp php8.4-imagick php8.4-common \
    php8.4-curl php8.4-gd php8.4-intl php8.4-mbstring php8.4-xmlrpc \
    php8.4-mysql php8.4-xml php8.4-cli php8.4-zip php8.4-redis php8.4-apcu
```
### Configuration Apache (Mode FPM)
```bash
a2enmod proxy_fcgi setenvif mpm_event rewrite headers env dir mime ssl
a2enconf php8.4-fpm
systemctl restart apache2
```
## Base de données
### Sécurisation initiale
```bash
mysql_secure_installation
```
### Création de la base
```bash
mysql -u root -p <<EOF
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'MDP_FORT_ICI';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
EOF
```
## Installation Nextcloud et permission
```bash
cd /tmp
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
mv nextcloud/ /var/www/
chown -R www-data:www-data /var/www/nextcloud
```
## Créer le dossier de données dans un emplacement personnalisé
```bash
mkdir /srv/nextcloud_data
chown -R www-data:www-data /srv/nextcloud_data
chmod 770 /srv/nextcloud_data
```
## Optimisations
### PHP (OPCache & Memory) (Fichier /etc/php/8.4/fpm/php.ini)
```ini
memory_limit = 512M
output_buffering = Off
opcache.interned_string = 16
opcache.interned_strings_buffer=16
max_execution_time = 300
date.timezone = Europe/Paris

[opcache]
opcache.enable=1
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
```
### Configuration apache (/etc/apache2/sites-available/nextcloud.conf)
**S'assurer d'avoir le certificat et la clé privée dans les bons dossiers** 
```apache
<VirtualHost *:80>
        ServerName cloud.domaine.fr
        Redirect permanent / https://cloud.domaine.fr/
</VirtualHost>

<VirtualHost *:443>
        ServerName cloud.domaine.fr
        ServerAdmin admin@domaine.fr
        DocumentRoot /var/www/nextcloud

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/domaine.crt
        SSLCertificateKeyFile /etc/ssl/private/domaine.key

        <Directory /var/www/nextcloud>
                Options +FollowSymlinks
                AllowOverride All
                Require all granted

                <IfModule mod_dav.c>
                        Dav off
                </IfModule>

                SetEnv HOME /var/www/nextcloud
                SetEnv HTTP_HOME /var/www/nextcloud
        </Directory>

        <Directory /srv/nextcloud_data>
                Require all denied
        </Directory>

        <IfModule mod_headers.c>
                Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
        </IfModule>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
#### Appliquer la configuration
```sh
a2ensite nextcloud.conf
systemctl restart apache2
```
#### Lancer la premiere configuration
**Penser à mettre le bon chemin du dossier de données /srv/nextcloud_data**

### APCu & Redis (Caching) après installation Web 
#### Modifier et ajouter à /var/www/nextcloud/config/config.php
```php
  'memcache.local' => '\OC\Memcache\APCu',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => [
    'host' => '/var/run/redis/redis-server.sock',
    'port' => 0,
  ],
```
#### Configurer Redis pour écouter sur le socket (/etc/redis/redis.conf)
```
unixsocket /var/run/redis/redis-server.sock
unixsocketperm 770
```
#### Ajouter www-data au groupe redis
```bash
usermod -aG redis www-data
systemctl restart redis-server apache2 php8.4-fpm
```
### Tâches Planifiées (Systemd Timer)
#### Creer le fichier /etc/systemd/system/nextcloud-cron.service
```
[Unit]
Description=Nextcloud Cron Job

[Service]
User=www-data
ExecStart=/usr/bin/php -f /var/www/nextcloud/cron.php
```
#### Creer le fichier /etc/systemd/system/nextcloud-cron.timer
```
[Unit]
Description=Run Nextcloud cron every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Unit=nextcloud-cron.service

[Install]
WantedBy=timers.target
```
#### Activer le service
```bash
systemctl enable --now nextcloud-cron.timer
```
### Ajout Heure de maintenance - Prefix Tel - 2FA
#### Modifier et ajouter à /var/www/nextcloud/config/config.php
```php
  'maintenance_window_start' => '01:00',
  'maintenance_window_duration' => 7200,
  'default_phone_region' => 'FR',
  'twofactor_enforced' => 'true',
  'serverid' => 'serveur-1',
```
## Commandes Utiles
### Commande de réparations et de vérifications
```bash
sudo -u www-data php /var/www/nextcloud/occ maintenance:repair --include-expensive
```
### Mise à jour de la base de données
```bash
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices
```
### Génèrer ou mettre à jour le fichier .htaccess
```bash
sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess
```