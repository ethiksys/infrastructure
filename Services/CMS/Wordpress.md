# Wordpress - Installation (Debian)

## Préparation du système
### Mise à jour et dépendances (MariaDB comme base de données et apache comme serveur web)
```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y mariadb-server apache2 php php-pdo php-mbstring php-pear php-bcmath php-zip php-xml php-curl php-gd php-mysql php-intl zip
```

#### Sécuriser l'installation -> [Gestion MariaDB](Services/Base_de_données/MariaDB.md)
#### Se connecter à la console de base de données en tant que root avec le mot de passe créer avec `mysql_secure_installation`
```bash
mysql -u root -p
```
#### Créer un utilisateur et un mot de passe de base de données pour Wordpress. Remplacer `Wordpress` par le couple choisi. 
```bash
SET old_passwords=0;
CREATE USER 'Wordpress'@'localhost' IDENTIFIED BY 'Wordpress';
```
#### Créer la base de données `Wordpressdb` (à remplacer) avec les caractères UTF-8 et une sensibilité à la casse.
```bash
CREATE DATABASE Wordpressdb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';
```
#### Accorder tous les privilèges sur la base de données à l'utilisateur `Wordpress` à la base de données `Wordpressdb`
```bash
GRANT ALL PRIVILEGES ON Wordpressdb.* TO 'Wordpress'@'localhost';
FLUSH PRIVILEGES;
```
#### Quitter la console
```bash
exit
```

## Télécharger WordPress sur le site officiel 
```bash
cd /tmp
wget https://wordpress.org/latest.zip
cd /tmp
sudo unzip latest.zip -d /var/www/
```
### Configurer apache pour pointer vers wordpress (voir apache ou nginx)
```bash
sudo nano /etc/apache2/sites-available/wordpress.conf 
```

### activer les modules apache
```bash
sudo a2enmod rewrite
sudo a2enmod deflate
sudo a2enmod headers
sudo a2enmod ssl
```

### Redémarrer Apache
```bash
sudo systemctl restart apache2
```

### Changer proprietaire de wordpress
```bash
sudo chown -R www-data:www-data /var/www/wordpress
```

### Supprimer les fichiers d'installation après la premiere configuration








