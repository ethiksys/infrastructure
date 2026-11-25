# Éditeurs Vi/Vim

---

## 1. Affichage des numéros de ligne

| Commande | Description |
|----------|-------------|
| `:set nu` | Afficher les numéros |
| `:set nu!` | Masquer les numéros |

---

## 2. Recherche

| Commande | Description |
|----------|-------------|
| `/` + *mot* | Rechercher |
| `n` | Occurrence suivante |
| `N` | Occurrence précédente |
| `:!cmd` (ex: `:!date`) | Exécuter une commande shell sans quitter vim |

---

## 3. Annuler / Refaire

| Commande | Description |
|----------|-------------|
| `u` | Annuler l'action précédente |
| `CTRL+R` | Répéter l'action annulée |

---

## 4. Couper

| Commande | Description |
|----------|-------------|
| `x` | Couper le caractère courant |
| `dd` | Couper la ligne actuelle |
| `[n]dd` | Couper *n* lignes |

---

## 5. Copier

| Commande | Description |
|----------|-------------|
| `yy` | Copier la ligne courante |
| `[n]yy` | Copier *n* lignes à partir de la ligne courante |

---

## 6. Coller

| Commande | Description |
|----------|-------------|
| `p` | Coller après la ligne courante |
| `P` | Coller avant la ligne courante |
| `[n]p` | Coller *n* fois |

---

## 7. Insertion de texte

| Commande | Description |
|----------|-------------|
| `i` | Insertion avant le caractère courant |
| `a` | Insertion après le caractère courant |
| `A` | Insertion à la fin de la ligne courante |
| `I` | Insertion au premier caractère significatif de la ligne |
| `s` | Substituer le caractère en surbrillance + insertion |
| `o` | Ajouter une ligne vide **après** + insertion |
| `O` | Ajouter une ligne vide **avant** + insertion |

---

## 8. Navigation

| Commande | Description |
|----------|-------------|
| `gg` | Déplacer au début du fichier |
| `G` | Déplacer à la fin du fichier |

---

## 9. Substitution

| Commande | Description |
|----------|-------------|
| `cw` | Substituer le mot courant (changer le mot) |
| `g/[MOT1]/s//[MOT2]` | Substituer toutes les occurrences de MOT1 par MOT2 |

---

## 10. Édition du profil (`.vimrc`)

| Commande | Description |
|----------|-------------|
| `cd ~` | Se placer dans le home |
| `vi .vimrc` | Éditer le profil |

### Configuration recommandée (`.vimrc`)

```vim
set number        " Affiche les numéros de lignes
set autoindent    " Indentation automatique
set ignorecase    " Ignore la casse lors des recherches
set showmode      " Affiche le mode de travail sur la ligne de statut
```

---

## Résumé des commandes essentielles

```
Mode Normal (par défaut)          Mode Insertion (appuyez sur i/a)
─────────────────────────────────────────────────────────────────────
u          Annuler                i          Insérer avant le curseur
CTRL+R     Refaire               a          Insérer après le curseur
dd         Couper ligne          A          Insérer à la fin de la ligne
yy         Copier ligne          I          Insérer au début de la ligne
p          Coller                o          Insérer ligne après
gg         Début du fichier      O          Insérer ligne avant
G          Fin du fichier        :set nu    Afficher les numéros
:q         Quitter               :w         Sauvegarder
:q!        Quitter sans sauvegarder
```

