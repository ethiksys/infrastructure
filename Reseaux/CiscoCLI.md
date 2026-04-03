# Configuration Switch Cisco IOS/CLI

## 1. Accès et Configuration de Base (NVRAM) pour sécuriser l'accès physique (console) et définir les paramètres généraux.

```
# Passer en mode root (privilégié)
Switch> enable

# Entrer en mode configuration globale
Switch# configure terminal

# Définir le nom d'hôte
Switch(config)# hostname S1

# Sécuriser l'accès physique (Console et activation du login)
S1(config)# line console 0
S1(config-line)# password <mot_de_passe_console>
S1(config-line)# login
S1(config-line)# exit

# Sécuriser le mode root ('secret' chiffre le mot de passe)
# S1(config)# enable password <mot_de_passe_clair>  # /!\ Obsolète, à éviter
S1(config)# enable secret <mot_de_passe_chiffre>

# Activer le chiffrement de tous les mots de passe stockés en clair dans la conf
S1(config)# service password-encryption

# Définir une bannière MOTD à la connexion (Message d'acceuil)
S1(config)# banner motd "ACCES RESTREINT - AUTHENTIFICATION REQUISE"

# Sauvegarder la configuration courante en configuration de démarrage
S1# copy running-config startup-config
```
---
## 2. Configuration de l'Interface de Management pour rendre le switch joignable sur le réseau.


```text
S1> enable
S1# configure terminal

# Cibler l'interface de management (par défaut VLAN 1)
S1(config)# interface vlan 1

# Assigner l'adresse IP et le masque de sous-réseau
S1(config-if)# ip address 192.168.1.253 255.255.255.0

# Activer l'interface
S1(config-if)# no shutdown
S1(config-if)# exit

# Sauvegarder
S1# copy running-config startup-config
```

---

## 3. Sécurisation des Accès Distants (Désactivation de Telnet pour SSH)


```text
S1> enable
S1# configure terminal

# Créer un utilisateur local administrateur
S1(config)# username admin privilege 15 secret <mot_de_passe_ssh>

# Définir un nom de domaine (Requis pour générer les clés RSA)
S1(config)# ip domain-name entreprise.local

# Générer les clés cryptographiques (choisir 2048 bits minimum en prod)
S1(config)# crypto key generate rsa

# Forcer l'utilisation de SSH v2 (plus sécurisé)
S1(config)# ip ssh version 2

# Configurer les lignes de terminaux virtuels (0 à 15 accès simultanés)
S1(config)# line vty 0 15

# N'autoriser QUE le protocole SSH (bloque Telnet)
S1(config-line)# transport input ssh

# Utiliser la base de données locale d'utilisateurs pour l'authentification
S1(config-line)# login local
S1(config-line)# exit

# Sauvegarder
S1# copy running-config startup-config
```

---

## 4. Utilisation et Astuces Pratiques

### Se connecter en SSH (depuis Linux/Windows)
```text
ssh admin@192.168.1.253
# ou
ssh -l admin 192.168.1.253
```

### Raccourcis utiles sous Cisco IOS
*   `show running-config` (ou `sh run`) : Affiche la configuration active en mémoire vive.
*   `end` (ou `Ctrl+Z`) : Retourne directement au mode privilégié (`S1#`) depuis n'importe quel sous-menu.
*   `do <commande>` : Permet d'exécuter une commande d'affichage (ex: `do show ip int brief`) depuis le mode configuration, sans avoir à faire `exit`.
*   `?` : Affiche l'aide contextuelle et la liste des commandes disponibles à l'endroit actuel.