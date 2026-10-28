# Terraform - Projet : Structure et exemple

## Structure du Projet Terraform
```text
projet_terraform/
├── main.tf             # Fichier principal de Terraform
├── variables.tf        # Fichier de variables
├── .gitignore          # Important pour ne pas versionner les informations sensibles (exemple terraform.tfstate)
└── cloud-init          # Dossier contenant la configuration des machines au 1er démarrage
    └── user_data.yaml  # Fichier de configuration
```
---
## Creer une paire de [clés SSH dédiée](../../SSH/Gestionclessh.md) et copier la clé publique sur l'hyperviseur. Le provider nécessite un acces SSH root pour charger les snippets cloud-init

## main.tf - Fichier de configuration principal de Terraform

Ce fichier configure le provider Proxmox et déploie le template cloud-init.

```bash
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox" # traducteur entre Terraform et Proxmox
      version = "0.118.1"     # adapter la version si nécessaire
    }
  }
}


provider "proxmox" {
  endpoint  = var.endpoint
  api_token = var.api_token
  insecure  = true

  ssh {
    private_key = file("~/.ssh/id_ed25519")
    agent       = true
    username    = "root"
  }
}

data "proxmox_virtual_environment_vms" "template" {
  tags = ["template"]
}

resource "proxmox_virtual_environment_file" "cloud_user_config" {
  content_type = "snippets"
  datastore_id = "DATA"
  node_name    = var.target_node

  source_raw {
    data      = file("${path.module}/cloud-init/user_data.yaml")
    file_name = "${var.vm_hostname}-ci-user.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_hostname
  node_name = var.target_node
  on_boot   = false
  tags      = ["terraform", "debian"]

  agent {
    enabled = true
  }

  cpu {
    type    = "x86-64-v2-AES"
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    interface    = "scsi0"
    iothread     = true
    datastore_id = "local"
    size         = 10
    discard      = "on"
  }

  clone {
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
  }

  initialization {
    datastore_id = "local"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_user_config.id
  }
}

output "vm_ipv4" {
  value = proxmox_virtual_environment_vm.vm.ipv4_addresses
}
```
---

## variables.tf - Fichier contenant les variables Terraform

```bash
variable "endpoint" {
  type = string
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type    = string
  default = "ikki"
}

variable "vm_hostname" {
  type    = string
  default = "terra-test"
}
```
## Passer le token par variable d'environnement. Ne jamais inscrire en clair dans le code.
```bash
export TF_VAR_api_token='terraform@pve!terraform_api=token-genere-sur-proxmox'
export TF_VAR_endpoint='https://ip-ou-dns.du.serveur.proxmox:8006/'
```
## Fichier de configuration de la vm à déployer (cloud-init/user_data.yaml)
```yaml
hostname: terra-test
package_update: true
packages:
  - qemu-guest-agent
users:
  - default
  - name: terra
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-ed25519 AAAA.... cle-publique
runcmd:
  - systemctl enable --now qemu-guest-agent
```
## Exemple de .gitignore pour ne pas versionner d'informations sensibles ou de fichiers inutiles

```gitignore
# Exclure les fichiers de variables locaux sensibles
./terraform
*.hcl
*.tfvars
*.tfstate
*.tfstate.backup
# Exclure les fichiers systèmes
.DS_Store
```

## Lancer le projet et gérer le déploiment
```bash
terraform init -> initialisation de la config
terraform fmt -> formate les fichiers .tf
terraform validate -> valide la syntaxe sans planifier
terraform plan -> planification des actions
terraform apply -> déploiement
terraform destroy -> suppression de la configuration
```