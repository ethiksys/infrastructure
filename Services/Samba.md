# Partage Samba vers Windows/Linux/MacOS

## Mettre à jour le système
```bash
sudo apt update && sudo apt upgrade -y
```
## Installer le paquet Samba et vérifier la version installée
```bash
sudo apt install samba -y
samba -V
```
## Créer un utilisateur Samba dédié sans shell
```bash
sudo useradd -M -s /usr/sbin/nologin partage
```
## Ajouter cet utilisateur à Samba avec un mot de passe
```bash
sudo smbpasswd -a partage
```
## Créer le dossier à partager
```bash
sudo mkdir -p /srv/data_smb
sudo chown partage:partage /srv/data_smb
sudo chmod 770 /srv/data_smb
```
## Configurer le partage dans `/etc/samba/smb.conf` :
```bash
sudo nano /etc/samba/smb.conf
```
### Modifier/ajouter :

* **workgroup** : nom du groupe de travail
* **server string** : description du serveur
* **[partage]** : section définissant un dossier partagé

```ini
[global]
   workgroup = WORKGROUP
   server string = Serveur Samba
   security = user
   server min protocol = SMB2_10  # Désactive SMB1
   hosts allow = 127.0.0.1 192.168.1.0/24  # Restriction réseau (à adapter)


# Ajouter à la fin du fichier :
[PartageSMB]
   comment = Partage Samba
   path = /srv/data_smb
   browseable = yes
   writable = yes
   guest ok = no
   valid users = partage
   force user = partage # évite les conflits de permissions
```
## Tester la configuration, vérifier la syntaxe
```bash
sudo testparm
```
## Redémarrer Samba et activer le service
```bash
sudo systemctl restart smbd
sudo systemctl enable smbd
```
## Vérifier le partage (`PartageSMB` doit apparaitre dans la liste
```bash
smbclient -L localhost -U partage
```
## Autoriser SMB dans le pare-feu 
```bash
sudo ufw allow samba
```

## Connexion depuis Windows/Linux/MacOS

### Accéder au partage et s'authentifier avec l'utilisateur et le mot de passe paramétrés précedemment
```text
smb:\\IP_DU_SERVEUR\PartageSMB
 ```

### Montage en ligne de commande
#### Linux
```bash
# 1. Installer cifs-utils
sudo apt install cifs-utils -y

# 2. Créer le fichier d'identifiants
sudo mkdir -p /etc/samba
sudo nano /etc/samba/credentials
# Contenu :
# username=partage
# password=VOTRE_MOT_DE_PASSE
sudo chmod 600 /etc/samba/credentials

# 3. Monter le partage
sudo mkdir -p /mnt/partage_smb
sudo mount -t cifs //IP_DU_SERVEUR/PartageSMB /mnt/partage_smb -o credentials=/etc/samba/credentials,uid=$(id -u),gid=$(id -g)
```

#### Windows cmd ou Powershell
```cmd
net use Z: \\IP_DU_SERVEUR\PartageSMB /user:partage * /persistent:yes
```
```powershell
$cred = Get-Credential -UserName "partage"
New-SmbMapping -LocalPath "Z:" -RemotePath "\\IP_DU_SERVEUR\PartageSMB" -Credential $cred -Persistent $true
```

#### MacOS
```bash
mkdir -p ~/partage_smb
mount_smbfs //partage@IP_DU_SERVEUR/PartageSMB ~/partage_smb
```
---

## Dépannage

### Le partage n'apparaît pas

- **Utiliser l'IP** du serveur plutôt que son nom.
- Vérifier que Samba tourne :
  ```bash
  sudo systemctl status smbd
  ```
- Vérifier que le disque est bien monté en `rw` :
  ```bash
  mount | grep /srv/data_smb
  ```
- Tester localement le partage :
  ```bash
  smbclient -L localhost -U partage
  ```

### Erreur "Accès refusé" en écriture

- Vérifier que le disque est monté en `rw`.
- Vérifier la directive `force user = partage` dans `smb.conf`.
- Vérifier que l'utilisateur Unix `partage` a les droits sur `/srv/data_smb` :
  ```bash
  ls -ld /mnt/data_smb
  sudo -u partage touch /srv/data_smb/test_ecriture
  sudo rm /srv/data_smb/test_ecriture
  ```