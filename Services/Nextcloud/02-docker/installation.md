# Nextcloud (Docker) - Déploiement Complet (FPM + Nginx + Redis + Traefik)

## Structure du Projet
```text
nextcloud-stack/
├── docker-compose.yml       # Orchestrateur
├── .env.example             # Copier en .env et personnaliser
├── nc.env                   # Secrets à personnaliser (MySQL)
└── web/
    └── nginx.conf           # Config Nginx
```
### Fichiers utilisés | [docker-compose.yml](./docker-compose.yml) | [nginx.conf](./web/nginx.conf) | [nc.env](./nc.env) |

## Amélioration post-install ([scriptable](./post-install-nc.sh))

### Maintenance & Base de données
```bash
# Corriger les index manquants
docker compose exec app php occ db:add-missing-indices

# Réparer les types MIME
docker compose exec app php occ maintenance:repair --include-expensive

# Désactiver l'app API (si non utilisé)
docker compose exec app php occ app:disable app_api
```

### Sécurité & Reverse Proxy (Via OCC)
```bash
# 1. Configurer les Trusted Proxies (Pour que Nextcloud accepte Traefik)
docker compose exec app php occ config:system:set trusted_proxies 0 --value="10.0.0.0/8"
docker compose exec app php occ config:system:set trusted_proxies 1 --value="172.16.0.0/12"
docker compose exec app php occ config:system:set trusted_proxies 2 --value="192.168.0.0/16"

# 2. Gérer les headers HTTPS
docker compose exec app php occ config:system:set forwarded_for_headers 0 --value="HTTP_X_FORWARDED_FOR"
docker compose exec app php occ config:system:set overwriteprotocol --value="https"

# 3. Paramètres Régionaux, Maintenance, Authentification deux facteurs
docker compose exec app php occ config:system:set default_phone_region --value="FR"
docker compose exec app php occ config:system:set maintenance_window_start --type=integer --value=2
docker compose exec app php occ config:system:set twofactor_enforced --value="true"
docker compose exec app php occ config:system:set serverid --value="server-1"
```

### Domaine (Optionnel)
```bash
docker compose exec app php occ config:system:set trusted_domains 1 --value="cloud.mon-domaine.fr"
docker compose exec app php occ config:system:set overwrite.cli.url --value="https://cloud.mon-domaine.fr"
```