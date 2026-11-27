# Connexion SSH par clés privées/publiques

## 1. Génération des clés Ed25519 recommandé (Windows/Linux/Mac)
```
ssh-keygen -t ed25519 -C "commentaire_ou_email"
```
### Optionnel : RSA 4096 (Pour vieux systèmes incompatibles Ed25519)
```
ssh-keygen -t rsa -b 4096
```
## 2. Déploiement de la clé publique
### Depuis Linux / macOS (Standard)
```bash
ssh-copy-id user@ip.du.srv.distant
```
### Depuis Windows (PowerShell)
```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh user@ip.du.srv.distant "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```
## 3. Dépannage & Maintenance
### Nettoyer une entrée obsolète 
```
ssh-keygen -R IP.du.serveur
ssh-keygen -R nom.dns.serveur
```
### Tester la connexion (Verbose)
```
ssh -v user@ip.du.srv.distant
```
### Gestion des droits (Côté Serveur)
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R user:user ~/.ssh
```