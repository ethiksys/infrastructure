# Migration des clés CephX de `aes` vers `aes256k` sur Proxmox

Cette procédure permet de migrer les clés CephX du cluster ainsi que les clés des utilisateurs compatibles vers le cipher sécurisé `aes256k`.

## Environnement minimum nécessaire

- **Proxmox VE** : `pve-manager 9.2.17`
- **Ceph** : `19.2.6-pve3`

> Les commandes doivent être exécutées avec les privilèges `root`.

## 1. Prérequis

Avant de commencer :

1. Vérifier que le cluster Ceph est sain :

   ```bash
   ceph -s
   ceph health detail
   ```

2. Vérifier que les nœuds Proxmox et les démons Ceph sont à jour :

   ```bash
   ceph versions
   ```

3. S’assurer que les nœuds disposent d’une synchronisation horaire correcte :

   ```bash
   timedatectl
   ```

Il est recommandé d’effectuer une sauvegarde des fichiers de configuration et des keyrings avant la migration.

## 2. Migration des clés appartenant au cluster

Sur chaque nœud Proxmox, effectuer d’abord une simulation :

```bash
/usr/share/pve-manager/migrations/pve-cephx-rotate-service-keys \
  --rotate-cluster-keys
```

Cette première exécution ne modifie rien et permet de détecter les éventuels problèmes et d’indiquer les changements qui seront effectués.

Si la simulation ne retourne aucune erreur, appliquer la migration :

```bash
/usr/share/pve-manager/migrations/pve-cephx-rotate-service-keys \
  --rotate-cluster-keys \
  --apply
```

Cette étape migre notamment les clés utilisées par les services Ceph du cluster.

## 3. Migration des clés des utilisateurs Ceph compatibles

Effectuer une simulation :

```bash
/usr/share/pve-manager/migrations/pve-cephx-rotate-service-keys \
  --rotate-all-storage-keys \
  --rotate-admin-key
```

Si la simulation ne retourne aucune erreur, appliquer la migration :

```bash
/usr/share/pve-manager/migrations/pve-cephx-rotate-service-keys \
  --rotate-all-storage-keys \
  --rotate-admin-key \
  --apply
```

Cette étape concerne les clés des utilisateurs de stockage compatibles ainsi que la clé d’administration.

## 4. Vérification de la migration

Lancer la commande sans option d’application :

```bash
/usr/share/pve-manager/migrations/pve-cephx-rotate-service-keys
```

La commande s’exécute en mode simulation et ne modifie ni les clés, ni la configuration des ciphers, ni les démons Ceph.

Une migration réussie doit notamment afficher :

```text
PASS: Every service key uses 'aes256k', and so do the service tickets.
PASS: Cephx migration is complete. Authentication and new keys use only 'aes256k'.
```

## 5. Confirmation finale et restriction des ciphers

Une fois que tous les clients et services ont été actualisés, confirmer la migration et restreindre les ciphers autorisés :

```bash
/usr/share/pve-manager/migrations/pve-cephx-rotate-service-keys \
  --apply \
  --confirm-all-clients-refreshed \
  --restrict-ciphers
```

Cette étape confirme que les clients ont renouvelé leurs clés et configure Ceph pour utiliser uniquement `aes256k`.

## 6. Contrôles après migration

Vérifier l’état général du cluster :

```bash
ceph -s
ceph health detail
```

Contrôler les versions réellement utilisées par les démons :

```bash
ceph versions
```

Rechercher les éventuels warnings liés à l’ancien cipher :

```bash
ceph health detail | grep -Ei \
  'AUTH_INSECURE|rotating service|insecure key'
```

## 7. Warning temporaire attendu

Après une migration réussie, le warning suivant peut rester présent temporairement :

```text
AUTH_INSECURE_ROTATING_SERVICE_KEY_TYPE
```

Il indique que d’anciens tickets de service utilisant `aes` sont encore valides ou présents en mémoire. Le message peut également apparaître sous la forme :

```text
rotating service keys for mon using insecure key type: aes
rotating service keys for mds using insecure key type: aes
rotating service keys for osd using insecure key type: aes
rotating service keys for mgr using insecure key type: aes
```

Ce warning doit normalement disparaître automatiquement après l’expiration des anciens tickets, généralement en quelques heures.

La présence de ce warning ne remet pas en cause la migration si la commande de vérification affiche :

```text
PASS: Every service key uses 'aes256k', and so do the service tickets.
PASS: Cephx migration is complete. Authentication and new keys use only 'aes256k'.
```

Il ne faut pas relancer la migration uniquement à cause de ce warning. Si celui-ci persiste bien au-delà du délai annoncé, vérifier l’heure système, les versions des démons et l’état du quorum avant d’envisager une action supplémentaire.