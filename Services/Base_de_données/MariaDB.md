# MariaDB / MySQL - Administration & Gestion Quotidienne

## 1. Installation & Sécurisation Initiale

```bash
# Installation
sudo apt update && sudo apt install -y mariadb-server

# Sécurisation 
sudo mysql_secure_installation

# Vérifier le service
sudo systemctl status mariadb
```

## 2. Connexion
```bash
# En tant que root système
sudo mysql

# En tant qu'utilisateur spécifique
mysql -u mon_utilisateur -p -h localhost
```

## 3. Gestion des Bases & Utilisateurs (SQL)

À exécuter dans le prompt MariaDB (`sudo mysql`).

### Création Standard (Le snippet à connaître par cœur)
```sql
-- 1. Créer la base (Encodage utf8mb4 pour le support emojis/international)
CREATE DATABASE ma_base_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- 2. Créer l'utilisateur
-- 'localhost' = connexion locale uniquement (Sécurité)
-- '%' = connexion distante autorisée (ex: depuis un autre serveur)
CREATE USER 'mon_utilisateur'@'localhost' IDENTIFIED BY 'MonMDP123!';

-- 3. Donner les droits
GRANT ALL PRIVILEGES ON ma_base_db.* TO 'mon_utilisateur'@'localhost';

-- 4. Appliquer les changements
FLUSH PRIVILEGES;
```

### Gestion Courante
```sql
-- Changer un mot de passe
ALTER USER 'mon_utilisateur'@'localhost' IDENTIFIED BY 'NouveauMdp!';

-- Supprimer un utilisateur
DROP USER 'mon_utilisateur'@'localhost';

-- Supprimer une base
DROP DATABASE ma_base_db;

-- Lister les bases
SHOW DATABASES;

-- Voir les utilisateurs existants
SELECT User, Host FROM mysql.user;
```

## 4. Sauvegarde & Restauration (mysqldum ou mariadb-dump)

### Sauvegarde
```bash
# Sauvegarder UNE base
mysqldump -u root -p ma_base_db > backup_mabase.sql

# Sauvegarder TOUTES les bases (Full Backup)
mysqldump -u root -p --all-databases > backup_full_server.sql
```

### Restauration
```bash
# 1. Créer la base vide (si elle n'existe pas)
mysql -u root -p -e "CREATE DATABASE ma_base_db;"

# 2. Importer le fichier SQL
mysql -u root -p ma_base_db < backup_mabase.sql
```

## 5. Dépannage & Reset Root

### Problème : Mot de passe root perdu

1.  **Arrêter le service** : `sudo systemctl stop mariadb`
2.  **Démarrer en mode sans échec** : `sudo mysqld_safe --skip-grant-tables &`
3.  **Se connecter (sans mdp)** : `mysql -u root`
4.  **Reset SQL** :
    ```sql
    FLUSH PRIVILEGES;
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'NouveauMdp!';
    FLUSH PRIVILEGES;
    EXIT;
    ```
5.  **Redémarrer proprement** :
    `sudo killall mysqld_safe`
    `sudo systemctl start mariadb`

### Problème : "Access denied for user 'root'@'localhost'"
*   **Cause** : Souvent, MariaDB utilise le plugin `unix_socket` pour root (il faut être `sudo` système) et refuse le mot de passe.
*   **Solution** : Utiliser toujours `sudo mysql` au lieu de `mysql -u root -p`.