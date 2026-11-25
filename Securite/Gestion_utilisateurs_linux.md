# Gestion des Utilisateurs et Groupes

## Gestion des Utilisateurs

### Créer un utilisateur
```bash
sudo adduser nom_utilisateur       # Méthode interactive recommandée
sudo useradd -m nom_utilisateur    # Alternative basique (créer le dossier home)
```
### Modifier un utilisateur
```bash
sudo usermod -aG groupe_utilisateur nom_utilisateur  # Ajouter à un groupe 
sudo usermod -s /bin/zsh nom_utilisateur             # Changer le shell 
sudo usermod -g groupe_principal nom_utilisateur     # Modifier le groupe principal 
```
### Changer le nom d'utilisateur d'un compte
#### Il faut utiliser un compte admin et que la session utilisateur soit totalement inactive
```bash
pkill -u ancien_user
sudo usermod -l nouveau_user ancien_user            # Renommer de ancien_user vers nouveau_user    
sudo usermod -d /home/nouveau_user -m nouveau_user  # Renommer le dossier home
sudo groupmod -n nouveau_user ancien_user           # Renommer le groupe utilisateur
```
### Supprimer / Désactiver un utilisateur (Recommander pour gérer les anciens utilisateurs)
```bash
sudo usermod -L nom_utilisateur      # Désactiver l'utilisateur (éviter tout accès non autorisé)
sudo usermod -U nom_utilisateur      # Réactiver l'utilisateur
sudo deluser nom_utilisateur         # Supprime uniquement l'utilisateur (compte inutile après période de grâce)
sudo userdel -r nom_utilisateur      # Supprime avec le dossier home (après verification de non perte de données)
```
## Gestion des Groupes (faciliter la gestion des droits d'accès)

### Créer un groupe
```bash
sudo groupadd nom_groupe              # Création basique 
sudo groupadd -g 1010 nom_groupe      # Avec GID spécifique 
```
### Modifier un groupe
```bash
sudo groupmod -n nouveau_nom ancien_nom   # Renommer 
sudo groupmod -g 1020 nom_groupe          # Changer GID 
```
### Supprimer un groupe
```bash
sudo delgroup nom_groupe         # Supprime le groupe 
```
## Gestion des mots de passe 

### Configuration de base
```bash
sudo passwd nom_utilisateur      # Changer le mot de passe 
sudo chage -d 0 nom_utilisateur  # Changer le mot de passe à la prochaine connexion
```

### Exipiration des mots de passe
```bash
sudo chage -M 90 nom_utilisateur            # Définir le nombre de jours avant expiration (90 jours)
sudo chage -W 7 nom_utilisateur             # Définir le nombre de jours avant que le mot de passe ne soit considéré comme expiré
sudo chage -E 2025-12-31 nom_utilisateur    # Définir la date d'expiration du compte (YYYY-MM-DD)
sudo chage -m 1 nom_utilisateur             # Définir le nombre de jours minimum entre les changements
sudo chage -I 30 nom_utilisateur            # Définir le nombre de jours d'inactivité avant expiration
sudo chage -l nom_utilisateur               # Voir expiration du mot de passe 
sudo chage -M 99999 nom_utilisateur         # Désactiver expiration
```
### Options avancées
```bash
sudo passwd -l nom_utilisateur          # Verrouiller le compte 
sudo passwd -u nom_utilisateur          # Déverrouiller le compte 
sudo tail -f /var/log/auth.log          # Surveillance des logs d'accès
```
### Politique de mots de passe globale
```bash
# Éditer le fichier
nano /etc/login.defs

# Paramètres à modifier :
PASS_MAX_DAYS   90    # jours max avant expiration (défaut: 99999)
PASS_MIN_DAYS   1     # jours min entre changements (défaut: 0)
PASS_WARN_AGE   7     # jours de prévenance (défaut: 7)
PASS_MIN_LEN    8     # longueur min du mot de passe
```

## Permissions et Umask

### Configuration globale
Ajouter dans /etc/bash.bashrc ou ~/.bashrc :
```bash
umask 002   # Permissions de groupe collaboratif 
```
Vérification
```bash
umask -S    # Afficher les permissions actuelles 
```











