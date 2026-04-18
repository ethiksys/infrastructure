#!/bin/bash

# ==============================================================================
# TITRE          : post-install-nc.sh
# DESCRIPTION    : Configuration automatique post-déploiement Nextcloud (OCC).
# AUTEUR         : ethiksys
# DATE           : 2026-01-25
# VERSION        : 1.1.0
# USAGE          : ./post-install-nc.sh
# ==============================================================================

# --- Configuration (Fail Fast) ---
set -o errexit  # Quitter si une commande échoue
set -o nounset  # Quitter si variable non définie

# --- Variables ---
CONTAINER_NAME="app" # Nom dans docker-compose
# À adapter et décommenter
# DOMAIN_URL="cloud.mon-domaine.fr" 

# --- Fonctions ---
log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

check_container() {
    if ! docker compose ps --services --filter "status=running" | grep -q "^${CONTAINER_NAME}$"; then
        log_error "Le conteneur '${CONTAINER_NAME}' n'est pas en cours d'exécution. Lancez 'docker compose up -d' d'abord."
    fi
}

wait_for_nextcloud() {
    log_info "Vérification de la disponibilité de Nextcloud..."
    # Boucle tant que 'occ status' ne renvoie pas un succès (installed: true)
    until docker compose exec -T "${CONTAINER_NAME}" php occ status &>/dev/null; do
        echo -n "."
        sleep 5
    done
    echo ""
    log_info "Nextcloud est prêt !"
}

# --- Main ---

log_info "Démarrage de la configuration post-install..."

check_container
wait_for_nextcloud

# 1. Maintenance BDD & App
log_info "Optimisation Base de données & Apps..."
docker compose exec -T "${CONTAINER_NAME}" php occ db:add-missing-indices
docker compose exec -T "${CONTAINER_NAME}" php occ maintenance:repair --include-expensive
docker compose exec -T "${CONTAINER_NAME}" php occ app:disable app_api

# 2. Configuration Réseau & Proxy
log_info "Configuration Trusted Proxies & HTTPS..."
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set trusted_proxies 0 --value="10.0.0.0/8"
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set trusted_proxies 1 --value="172.16.0.0/12"
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set trusted_proxies 2 --value="192.168.0.0/16"

docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set forwarded_for_headers 0 --value="HTTP_X_FORWARDED_FOR"
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set overwriteprotocol --value="https"

# 3. Paramètres Régionaux
log_info "Configuration Locale (FR) & Maintenance..."
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set default_phone_region --value="FR"
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set maintenance_window_start --type=integer --value=2
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set twofactor_enforced --value="true"
docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set serverid --value="server-1"

# 4. URL Publique (à décommenter si DOMAIN_URL est utilisé)
# log_info "Définition de l'URL publique : ${DOMAIN_URL}"
# docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set trusted_domains 1 --value="${DOMAIN_URL}"
# docker compose exec -T "${CONTAINER_NAME}" php occ config:system:set overwrite.cli.url --value="https://${DOMAIN_URL}"
# docker compose exec -T -T "${CONTAINER_NAME}" php occ config:system:set allow_local_remote_servers --value=true --type=boolean

log_info "Terminé avec succès !"