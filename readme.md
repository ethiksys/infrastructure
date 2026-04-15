# Base de connaissance Infrastructure & Automatisation
> Bienvenue sur ma base de connaissance technique. Ce dépôt centralise mes procédures d'infrastructure, mes scripts d'automatisation et mes notes de déploiement issues de situations réelles.

## 🛠️ Environnement Technique

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
---

## 🏗️ Virtualisation & Gestion du cycle de vie (MCO)

- [**Proxmox**](Proxmox/readme.md) : Gestion de clusters Proxmox VE et plans de reprise d'activité avec Proxmox Backup Server. 

- [**Docker**](Docker/readme.md) : Gestion de solutions de containerisation

## ⚡ Automatisation
Standardisation des déploiements.
- **Ansible** :
  - [Installation Ansible](Automatisation/Ansible/01-Installation_Ubuntu.md)
  - [Gestion de l'inventaire](Automatisation/Ansible/02-Gestion_inventaire.md)
  - [Projet : Structure et exemple de playbook](Automatisation/Ansible/03-Structure_Projet_Playbook.md)
  - [Gestion des rôles](Automatisation/Ansible/04-Gestion_des_roles.md)
- **Template** :
  - [Script Bash](Automatisation/Template/script-bash-template.md)
  - [Playbook Ansible](Automatisation/Template/playbook-template.yml)

## 🔐 Sécurité & Réseau
Hardening système et gestion des flux.

- **Cryptographie & Accès** :
  - [Gestion des clés SSH](SSH/Gestionclessh.md)
  - [Gestion de certificats SSL auto-signés/publics](Reseaux/GestionSSL.md)
  - [Gestion d'OpenVPN](Reseaux/OpenVPN.md)
- **Réseau, Pare-feu & Filtrage** :
  - Gestion Reverse Proxy : [Nginx](Reseaux/ReverseProxy-LoadBalancing/Nginx.md), [Traefik](Reseaux/ReverseProxy-LoadBalancing/Traefik_v3.md)
  - Gestion Pare-feu : [iptables](Reseaux/Parefeu/Iptables.md), [ufw](Reseaux/Parefeu/ufw.md)
  - [Optimisation réseau : Gestion IPv6](Reseaux/DisableIPv6_linux.md)
  - [Switch Cisco IOS/CLI](Reseaux/CiscoCLI.md)
- **Cybersécurité**: 
  - [Sécurisation de base](Securite/Securisation_De_Base_Linux.md)
  - [Wazuh SIEM/XDR](Securite/Wazuh.md)
- **Gestion et Supervision**: 
  - [Zabbix LTS](Supervision/ZabbixLTS.md)
  - [GLPI](Supervision/GLPI.md) : Gestionnaire de Parc
  - [Supervision Multi-services](Supervision/Monitoring&Alertes.md)

## 📦 Services Auto-hébergés
Déploiement et gestion de solutions autohébergés.

- Solution Cloud et stockage de fichiers : [Nextcloud](Services/Nextcloud/readme.md), [S3 - SeaweedFS](Services/S3-SeaweedFS.md)
- Gestion de base de données : [PostgreSQL](Services/Base_de_données/PostgreSQL.md), [MariaDB](Services/Base_de_données/MariaDB.md), [Redis](Services/Base_de_données/Redis.md)
- Serveur de mots de passe : [Passbolt](Services/Passbolt.md)

- **IA locale & Hardware Passthrough**
  - [Virtualisation GPU pour OpenWebUI (PCI Passthrough)](IA/OpenWebUI-serverGPU.md)
  - [Installation d'Ollama (Linux/Windows)](IA/Ollama.md)
 
---
![Dernière mise à jour](https://img.shields.io/github/last-commit/ethiksys/infrastructure)
![Nombre de docs](https://img.shields.io/github/directory-file-count/ethiksys/infrastructure)

*Ce dépôt est maintenu activement. Pour discuter de technologie ou d'opportunités professionnelles, retrouvez-moi sur [LinkedIn](https://www.linkedin.com/in/ethiksys).*