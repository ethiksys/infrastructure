# Installation Docker et Docker compose sur Fedora 43
## Préparation du Serveur
### Mise à jour Système
```bash
sudo dnf update && sudo dnf upgrade -y
```
### Supprimer les paquets conflictuels
```bash
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
```
## Installation Docker officiel 
### Ajout du dépot officiel Docker
```bash
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
```
### Installation des paquets Docker
```bash
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```
### Mettre l'utilisateur courant dans le groupe docker
```bash
sudo usermod -aG docker $USER
newgrp docker
```
## Vérification
### Vérifier la version
```bash
docker compose version
```
### Lancer un conteneur de test
```bash
docker run --rm hello-world
```