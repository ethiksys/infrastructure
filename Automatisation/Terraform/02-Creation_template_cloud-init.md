# Creation Template Cloud-init sur proxmox

## Télécharger une image cloud-init officielle et verifier son hash
```bash
cd /tmp
# Pour exemple Debian 13
wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2
# Verification du hash
wget https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS
sha512sum -c SHA512SUMS --ignore-missing
```
## Installer virt-customize
```bash
sudo apt update && sudo apt install libguestfs-tools -y
```
## Personnalisation de l'image debian mise à jour et injection de qemu-guest-agent
```bash
virt-customize -a debian-13-generic-amd64.qcow2 \
--install qemu-guest-agent  \
--update \
--truncate /etc/machine-id
```
#### Si un probleme de réseau survient lors de la mise a jour installer dhcpcd sans l'activer (risque de conflit)

## Création de la VM pour le template
```bash
# Creation de la vm avec son nom
sudo qm create 6666 --name debian13-cloud-init 
# Paramètrage du CPU, de la ram et de la carte réseau
sudo qm set 6666 --cores 2 --memory 2048 --net0 virtio,bridge=vmbr0
# Paramétrage du controleur de disque et l'image à importer
sudo qm set 6666 --scsihw virtio-scsi-single --scsi0 local:0,import-from=/tmp/debian-13-generic-amd64.qcow2,iothread=1
# Configuration de la console série
sudo qm set 6666 --serial0 socket --vga serial0
# Redemimensionnement du disque
sudo qm resize 6666 scsi0 10G
# Destination de l'image 
sudo qm set 6666 --ide2 DATA:cloudinit
# Parametrage de l'ordre de boot, activation de qemu-guest-agent et définition du type de machine
sudo qm set 6666 --boot order=scsi0 --agent enabled=1 --ostype l26
# Définition du tag de l'image
sudo qm set 6666 --tags template
# Conversion en template
sudo qm template 6666
```
