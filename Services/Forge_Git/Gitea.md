# Gitea - Installation (Ubuntu)

## Préparation du système
### Mise à jour et dépendances (MariaDB choisi pour la gestion de la base de données)
```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install git mariadb-server cosign -y 
```
### Préparation de la base de données 

#### Sécuriser l'installation -> [Gestion MariaDB](Services/Base_de_données/MariaDB.md)
#### Se connecter à la console de base de données en tant que root avec le mot de passe créer avec `mysql_secure_installation`
```bash
mysql -u root -p
```
#### Créer un utilisateur et un mot de passe de base de données pour Gitea. Remplacer `gitea` par le couple choisi. 
```bash
SET old_passwords=0;
CREATE USER 'gitea'@'localhost' IDENTIFIED BY 'gitea';
```
#### Créer la base de données `giteadb` (à remplacer) avec les caractères UTF-8 et une sensibilité à la casse.
```bash
CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';
```
#### Accorder tous les privilèges sur la base de données à l'utilisateur `gitea` à la base de données `giteadb`
```bash
GRANT ALL PRIVILEGES ON giteadb.* TO 'gitea'@'localhost';
FLUSH PRIVILEGES;
```
#### Quitter la console
```bash
exit
```
---
### Optionnel - Base de données distante
#### Pour une base de données distante configurer bind-address dans `/etc/mysql/my.cnf`
```ini
[mysqld]
bind-address = IPouDNS.du.serveur.delabasededonnées
```
#### Créer un utilisateur et un mot de passe de base de données distante pour Gitea. Remplacer `gitea` par le couple choisi. 
```bash
SET old_passwords=0;
CREATE USER 'gitea'@'ip.du.serveur.gitea' IDENTIFIED BY 'gitea';
```
#### Créer la base de données `giteadb` (à remplacer) avec les caractères UTF-8 et une sensibilité à la casse.
```bash
CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';
```
#### Accorder tous les privilèges sur la base de données à l'utilisateur `gitea` à la base de données `giteadb`
```bash
GRANT ALL PRIVILEGES ON giteadb.* TO 'gitea'@'ip.du.serveur.gitea';
FLUSH PRIVILEGES;
```
---

## Installation 

### Créer l'utilisateur qui exécutera Gitea (exemple `git`)
```bash
sudo adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --group \
   --disabled-password \
   --home /home/git \
   git
```
### Créer une clé SSH pour l'utilisateur git
```bash
sudo -u git ssh-keygen -t ed25519 -f /home/git/.ssh/id_ed25519 -N "" -C "clef interne gitea"
```
### Créer la structure des dossiers
```bash
mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea
```

### Telecharger les binaires de Gitea et verifier la signature avec cosign
```bash
wget https://dl.gitea.com/gitea/28.3.0/gitea-28.3.0-linux-amd64
wget https://dl.gitea.com/gitea/28.3.0/gitea-28.3.0-linux-amd64.sigstore.json
cosign verify-blob gitea-28.3.0-linux-amd64 \
  --bundle gitea-28.3.0-linux-amd64.sigstore.json \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  --certificate-identity-regexp="https://github.com/go-gitea/gitea/.github/workflows/release-.*"
chmod +x gitea-28.3.0-linux-amd64

```
### Configurer le répertoire de travail de Gitea
```bash
export GITEA_WORK_DIR=/var/lib/gitea/
```
### Copier les binaires vers un emplacement global
```bash
cp gitea-28.3.0-linux-amd64 /usr/local/bin/gitea
```
### Ajoute l'autocomplétion dans le shell
```bash
gitea completion <shell>
gitea completion bash | sudo tee /etc/bash_completion.d/gitea > /dev/null
```

## Lancement de Gitea

### Recommandé

#### Créer un service systemd dans `/etc/systemd/system/gitea.service `
```ini
[Unit]
Description=Gitea (Git with a cup of tea)
After=network.target
Wants=mariadb.service
After=mariadb.service

[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
```
#### Recharger systemd et activer et démarrer Gitea au boot
```bash
sudo systemctl daemon-reload
sudo systemctl enable gitea --now
```

### Lancement en ligne de commande
```bash
GITEA_WORK_DIR=/var/lib/gitea/ /usr/local/bin/gitea web -c /etc/gitea/app.ini
```
## Première connexion et configuration finale

### Pour effectuer la première configuration se connecter sur le port 3000 du serveur
```text
http://ip.du.serveur:3000
```
### Si mise en place deerrière un reverse proxy modifier dans le fichier `/etc/gitea/app.ini`
```ini
[server]
ROOT_URL = https://gitea.mondomaine.lan/
```
### Pour éviter les conflits de port SSH système et Gitea modifier dans le fichier `/etc/gitea/app.ini`
```ini
[server]
SSH_PORT = 2222
SSH_LISTEN_PORT = 22
```
### Redémarrer le service
```bash
sudo systemctl restart gitea
```
### Changer les permissions sur les fichiers de configuration (seulement utiles pour la configuration Web)
```bash
chmod 750 /etc/gitea
chmod 640 /etc/gitea/app.ini
```
### Configurer le parefeu
```bash
sudo ufw allow 3000/tcp   # ou 80/443 si reverse proxy
sudo ufw allow 2222/tcp   # SSH Gitea
```

### Mise à jour
#### Arrêter Gitea
```bash
sudo systemctl stop gitea
```
#### Telecharger les nouveaux binaires de Gitea, verifier la signature et les remplacer dans `/usr/local/bin/gitea`
```bash
wget https://dl.gitea.com/gitea/28.3.0/gitea-28.3.0-linux-amd64
wget https://dl.gitea.com/gitea/28.3.0/gitea-28.3.0-linux-amd64.sigstore.json
cosign verify-blob gitea-28.3.0-linux-amd64 \
  --bundle gitea-28.3.0-linux-amd64.sigstore.json \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  --certificate-identity-regexp="https://github.com/go-gitea/gitea/.github/workflows/release-.*"
chmod +x gitea-28.3.0-linux-amd64
cp gitea-28.3.0-linux-amd64 /usr/local/bin/gitea
```