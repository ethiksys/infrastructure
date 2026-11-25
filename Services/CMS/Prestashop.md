# Prestashop - Installation (Debian)

## Préparation du système
### Mise à jour et dépendances (MariaDB comme base de données et apache comme serveur web)
```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y mariadb-server apache2 php php-zip php-xml php-curl php-gd php-mysql php-intl 
```

#### Sécuriser l'installation -> [Gestion MariaDB](Services/Base_de_données/MariaDB.md)
#### Se connecter à la console de base de données en tant que root avec le mot de passe créer avec `mysql_secure_installation`
```bash
mysql -u root -p
```
#### Créer un utilisateur et un mot de passe de base de données pour Prestashop. Remplacer `presta` par le couple choisi. 
```bash
SET old_passwords=0;
CREATE USER 'presta'@'localhost' IDENTIFIED BY 'presta';
```
#### Créer la base de données `prestadb` (à remplacer) avec les caractères UTF-8 et une sensibilité à la casse.
```bash
CREATE DATABASE prestadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';
```
#### Accorder tous les privilèges sur la base de données à l'utilisateur `presta` à la base de données `prestadb`
```bash
GRANT ALL PRIVILEGES ON prestadb.* TO 'presta'@'localhost';
FLUSH PRIVILEGES;
```
#### Quitter la console
```bash
exit
```

## Téléchargez PrestaShop sur le site officiel et le déplacer sur le serveur
```bash
mv prestashop_edition_basic_version_9.2.1-6.1 /var/www/prestashop
```
### Configurer apache pour pointer vers prestashop (voir apache ou nginx)
```bash
sudo nano /etc/apache2/sites-available/prestashop.conf 
```

### activer le module rewrite apache
```bash
sudo a2enmod rewrite
```

### Redémarrer Apache
```bash
sudo systemctl restart apache2
```

### Changer proprietaire de prestashop
```bash
sudo chown -R www-data:www-data /var/www/prestashop
```

### Supprimer les fichiers d'installation après la premiere configuration
```bash
rm /var/www/prestashop/Install_PrestaShop.html INSTALL.txt 
```

### Connection au backend adminXXX das le dossier prestashop
http://votresite.com/adminXXX/index.php