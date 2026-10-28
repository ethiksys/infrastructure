# Terraform - Installation & Configuration Initiale
---
OS : Ubuntu/Debian.
---
## Préparation du serveur 
### Installation des dépendances système
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
```
### Installation clé GPG Hashicorps
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
### Ajouter le dépot officiel Hashicorp au système
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

## Mise à jour des dépots et installation de terraform
```bash
sudo apt update && sudo apt install terraform -y

```
## Sur l'hyperviseur : Limitations des permissions et privileges
```text
Dans l'interface d'administration de proxmox :
```
### Créer un role Terraform
```text
Datacenter -> Roles -> Create
Name : Terraform
Privilèges : Datastore.Allocate, Datastore.AllocateSpace, Datastore.Audit, Pool.Allocate, SDN.Use, Sys.Audit, Sys.Modify, VM.Allocate, VM.Audit, VM.Clone, VM.Config.CDROM, VM.Config.CPU, VM.Config.Cloudinit, VM.Config.Disk, VM.Config.HWType, VM.Config.Memory, VM.Config.Network, VM.Config.Options, VM.Console, VM.GuestAgent.Audit, VM.Migrate, VM.PowerMgmt

Ou en ligne de commande :
```
```bash
pveum role add Terraform --privs "Datastore.Allocate Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use Sys.Audit Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.GuestAgent.Audit VM.Migrate VM.PowerMgmt"
```
### Créer un utilisateur Terraform
```
Datacenter -> Users -> Add
Name : terraform
Realm : Proxmox VE authentication server

Ou en ligne de commande :
```
```bash
pveum user add terraform@pve
```
### Gérer les permissions
```text
Datacenter -> Permissions -> Add -> User
Path : /
User : terraform@pve
Role : terraform
Propagate : cocher
Ou en ligne de commande :
```
```bash
pveum aclmod / -user terraform@pve -role Terraform
```
### Générer un token API pour Terraform (Privilige Séparation le token hérite des permissions user)
```text
Datacenter -> API Tokens -> Add

User : terraform
Token ID : terraform_api
Privilige Séparation : Décocher

Ou en ligne de commande :
```
```bash
pveum user token add terraform@pve terraform_api -expire 0 -privsep 0 -comment "Terraform token"
```
####  Test token proxmox
```bash
curl -X GET 'https://ip-ou-dns.du.serveur.proxmox:8006/api2/json/nodes' -H 'Authorization:PVEAPIToken=terraform@pve!terraform_api=token-genere-sur-proxmox' --insecure
```

## Commande de base terraform
```bash
terraform init -> initialisation de la config
terraform fmt -> formate les fichiers .tf
terraform validate -> valide la syntaxe sans planifier
terraform plan -> planification des actions
terraform apply -> déploiement
terraform destroy -> suppression de la configuration
```


