# **Gestion des solutions Proxmox**

## **Proxmox Virtual Environment (PVE)** : 
Plateforme de virtualisation open-source qui permet de gérer des machines virtuelles (VM) et des conteneurs.

#### Caractéristiques :
1. **Virtualisation de machines virtuelles (KVM)** : Permet de créer et de gérer des environnements isolés.
2. **Conteneurs LXC** : Alternative légère aux machines virtuelles.
3. **Interface web** : Gestion des VM, conteneurs, ressources facilitée.
4. **Haute disponibilité (HA)** : Assure la continuité des services en cas de défaillance matérielle.
5. **Support du Stockage distribué** : Gestion flexible et évolutive des données.
6. **Sauvegarde et restauration** : Assure la sécurité des données et des configurations.
7. **Clustering** : Gestion centralisée et meilleure utilisation des ressources.

#### Avantages :
- **Open-source** : Gratuite et code source disponible pour la communauté.
- **Flexibilité** : Gestion centralisée des VM et des conteneurs pour différents types de charges de travail.
- **Évolutivité** : Gestion des infrastructures de petite à grande taille.
- **Communauté active** : Simplifie la résolution des problèmes et l'accès à des ressources supplémentaires.

### **Maintenance**
- Stratégies de mise à niveau sans interruption de service :
  - [Mise à jour majeure : PVE 8 vers 9 (POC)](Virtual_Environment/MAJ-PVE-8to9.md)
  - [Mise à jour majeure : PVE 7 vers 8](Virtual_Environment/MAJ-PVE-7to8.md)
- Maintenance ou procédures diverses :
  - [Migration du VM virtualbox vers Proxmox](Virtual_Environment/MigrationOVA.md)
  - [Gestion avancée LXC](Virtual_Environment/Gestion_LXC.md)
  - [Migration des clés CephX de `aes` vers `aes256k`](Virtual_Environment/MigrationCephxKeys.md)

## **Proxmox Backup Server (PBS)** : 

Proxmox Backup Server (PBS) est une solution de sauvegarde open-source conçue pour offrir une gestion efficace et sécurisée des sauvegardes de machines virtuelles, de conteneurs et d'autres types de données.

#### Caractéristiques principales :
1. **Sauvegarde incrémentielle** : Minimise l'utilisation de l'espace de stockage et le temps nécessaire pour les tâches de sauvegardes.
2. **Déduplication** : Réduit encore davantage l'espace de stockage en éliminant les données redondantes.
3. **Compression** : Optimise l'utilisation de l'espace de stockage.
4. **Chiffrement** : Sécurise les sauvegardes et protéger les données sensibles.
5. **Interface web** : Gestion simplifiée des sauvegardes, des restaurations et des configurations.
6. **Intégration avec Proxmox VE** : Gestion simplifiée des sauvegardes pour les machines virtuelles et les conteneurs.
7. **Planification des sauvegardes** : Exécution automatique des tâches à des intervalles définis.
8. **Restauration rapide** : Permet de minimiser les temps d'arrêt.

#### Avantages :
- **Open-source** : Gratuite et code source disponible pour la communauté.
- **Efficacité** : Sauvegarde incrémentielle, déduplication et compression optimisent l'usage de l'espace de stockage.
- **Sécurité** : Sécurisation contre les accès non autorisés.
- **Facilité d'utilisation** : Gestion des sauvegardes et des restaurations simplifiée.

---
### **Maintenance**
- Stratégies de mise à niveau sans interruption de service :
  - [Mise à jour majeure : PBS 3 vers 4 (POC)](Backup_Server/MAJ-PBS-3to4.md)