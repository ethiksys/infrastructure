# Partage Proftpd vers Windows/Linux/MacOS

## Mise à jour des paquets de base
```bash
sudo apt update && sudo apt full-upgrade -y
```

## Installation Paquet Proftpd
```bash
sudo apt install proftpd proftpd-mod-crypto -y
```

## Créer utilisateur FTP sans shell avec un mot de passe aléatoire et le dossier pour les logs
```bash
FTP_PASS=$(openssl rand -base64 12 | tr -d '/+')
sudo useradd -m -d /home/ftpuser -s /usr/sbin/nologin ftpuser
echo "ftpuser:${FTP_PASS}" | sudo chpasswd
echo "Mot de passe FTP : ${FTP_PASS}"
```

## Configuration Server ProFTPD dans `/etc/proftpd/proftpd.conf`
```ini
ServerName "Secure FTP Server"
ServerType standalone
DefaultServer on
Port 21
UseIPv6 off
Umask 022
MaxInstances 30
User proftpd
Group nogroup
DefaultRoot ~
RequireValidShell off
ShowSymlinks on   
MaxLoginAttempts 3      
PassivePorts 40000 50000

<Limit LOGIN>
    AllowUser ftpuser
    DenyAll
</Limit>

TLSEngine                  on
TLSLog                     /var/log/proftpd/tls.log
TLSProtocol                TLSv1.2 TLSv1.3
TLSRSACertificateFile      /etc/proftpd/ssl/proftpd.crt
TLSRSACertificateKeyFile   /etc/proftpd/ssl/proftpd.key
TLSVerifyClient            off
TLSRequired                on
```

## Activer le module TLS
```bash
sudo sed -i '26s/^#LoadModule mod_tls.c/LoadModule mod_tls.c/' /etc/proftpd/modules.conf
```

## Génération d'un certificat SSL auto-signé pour un usage privé sinon utiliser Let's Encrypt ou AC interne
```bash
sudo mkdir -p /etc/proftpd/ssl
sudo chown root:nogroup /etc/proftpd/ssl
sudo chmod 750 /etc/proftpd/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/proftpd/ssl/proftpd.key \
    -out /etc/proftpd/ssl/proftpd.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=MyOrg/CN=$(hostname -f)"

# Ajuster les permissions de la clé
sudo chown root:nogroup /etc/proftpd/ssl/proftpd.key
sudo chmod 640 /etc/proftpd/ssl/proftpd.key

# Le certificat public peut rester lisible par tous
sudo chown root:nogroup /etc/proftpd/ssl/proftpd.crt
sudo chmod 644 /etc/proftpd/ssl/proftpd.crt
```

## Vérification et démarrage de Proftpd
```bash
sudo proftpd -t
sudo systemctl restart proftpd
sudo systemctl enable proftpd
sudo systemctl status proftpd
```
## Autoriser Proftpd dans le pare-feu 
```bash
sudo ufw allow 21/tcp
sudo ufw allow 40000:50000/tcp
```
## Connexion depuis Windows/Linux/MacOS

### Accéder au partage et s'authentifier avec l'utilisateur et le mot de passe paramétrés précedemment

```text
FileZilla ou équivalent (Windows/Linux/macOS) : FTP over explicit TLS/SSL, hôte IP_DU_SERVEUR, port 21, chiffrement « Require explicit FTP over TLS », utilisateur ftpuser, mot de passe généré.
```

#### Linux / MacOS
```bash
lftp -e "set ssl:verify-certificate no; set ftp:ssl-force true" -u ftpuser ftp://IP_DU_SERVEUR
# test
curl --ssl-reqd -k -u ftpuser ftp://IP_DU_SERVEUR/
```
