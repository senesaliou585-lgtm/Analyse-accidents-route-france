# Analyse des accidents de la route en France (2024)

## Présentation du projet

Ce projet porte sur l'analyse statistique et exploratoire des accidents corporels de la circulation routière survenus en France au cours de l'année 2024.

Réalisé avec R, il vise à exploiter les données ouvertes de la sécurité routière afin de mieux comprendre les circonstances des accidents, leur répartition géographique et temporelle, ainsi que les caractéristiques des usagers et des véhicules impliqués.

Le projet repose sur deux volets complémentaires :

- Une analyse exploratoire et statistique des données avec R.
- Un tableau de bord interactif développé avec Shiny pour faciliter l'exploration et la visualisation des résultats.

## Objectifs du projet

L'objectif principal est d'identifier les principales caractéristiques des accidents corporels de la route en France en 2024 à travers une approche statistique et descriptive.

Plus précisément, cette analyse vise à :

- Étudier l'évolution des accidents selon les mois, les heures et les périodes de la journée.
- Analyser leur répartition géographique selon les départements et les communes.
- Examiner les conditions environnementales et les caractéristiques des lieux où surviennent les accidents.
- Étudier les profils des usagers impliqués, notamment selon leur âge et la gravité des blessures.
- Mettre en évidence les principaux facteurs descriptifs associés à la gravité des accidents.
  
L'ensemble de ces analyses est complété par un tableau de bord interactif permettant d'explorer les données selon différents critères.

## Sources et description des données

Les données utilisées dans ce projet proviennent de la base annuelle des accidents corporels de la circulation routière (BAAC), diffusée en open data par les autorités françaises.

L'étude porte sur les données de l'année 2024 et s'appuie sur quatre fichiers principaux :

| Fichier | Description |
|---|---|
| `carac.csv` | Caractéristiques générales des accidents |
| `lieux.csv` | Caractéristiques des lieux et des infrastructures |
| `usagers.csv` | Informations relatives aux personnes impliquées |
| `vehicules.csv` | Informations relatives aux véhicules impliqués |

Ces différentes tables ont été nettoyées, préparées et rapprochées à partir de l'identifiant de l'accident (`Num_Acc`) afin de constituer une base exploitable pour les analyses statistiques.

Source des données : [Données ouvertes de la sécurité routière](https://www.data.gouv.fr/).


## Technologies et outils utilisés

Le projet a été réalisé principalement avec les outils suivants :

- **R** : traitement et analyse statistique des données.
- **RStudio** : environnement de développement.
- **Shiny** : création du tableau de bord interactif.
- **dplyr** : manipulation et transformation des données.
- **ggplot2** : création de graphiques statistiques.
- **Plotly** : visualisations interactives.
- **Leaflet** : cartographie interactive.
- **lubridate** : manipulation des dates et des heures.
- **DT** : présentation interactive des tableaux.


## Méthodologie d'analyse

Le projet suit plusieurs étapes :

1. **Importation des données** : chargement des différentes tables BAAC de l'année 2024.
2. **Nettoyage des données** : vérification des variables, traitement des valeurs manquantes et harmonisation des formats.
3. **Préparation des données** : transformation des variables, création de nouvelles variables et rapprochement des différentes tables.
4. **Analyse exploratoire** : étude descriptive des accidents selon plusieurs dimensions.
5. **Visualisation** : réalisation de graphiques et de représentations cartographiques.
6. **Développement d'une application interactive** : mise à disposition des résultats à travers un tableau de bord Shiny.


## Axes d'analyse

L'analyse exploratoire est organisée autour de quatre axes principaux :

### Axe 1 — Analyse temporelle
- Répartition mensuelle des accidents.
- Répartition horaire des accidents.
- Analyse selon les périodes de la journée.

### Axe 2 — Analyse géographique et environnementale
- Répartition des accidents par département.
- Répartition par commune.
- Analyse selon la localisation des accidents.
- Étude des conditions atmosphériques.
- Analyse de l'état de la chaussée.
- Étude des types d'intersections.

### Axe 3 — Analyse du profil des usagers
- Répartition des usagers selon leur sexe.
- Analyse des classes d'âge.
- Étude de la gravité des accidents et des blessures.
- Analyse des catégories d'usagers.

## Tableau de bord interactif

Une application interactive a été développée avec **Shiny** afin de faciliter l'exploration des données et la consultation des résultats.

Elle comprend cinq modules :

- **Vue générale** : présentation des principaux indicateurs statistiques.
- **Analyse temporelle** : évolution des accidents selon les mois et les heures.
- **Analyse géographique** : répartition des accidents par département et selon leur localisation.
- **Cartographie** : visualisation géographique des accidents.
- **Profil des usagers** : analyse des caractéristiques des personnes impliquées.

### Fonctionnalités interactives

L'application propose plusieurs filtres :
- Sélection du département.
- Sélection du mois.
- Choix d'une période d'analyse.
- Réinitialisation des filtres.

Les indicateurs, graphiques et la carte s'adaptent automatiquement aux sélections effectuées.


## Organisation du projet
projet S/
│
├── app/
│   └── app.R
│
├── data/
│   ├── accidents_clesn.rds
│   └── carac-2024.csv
│   ├── lieux-2024.csv
    ├── synthese_globale.csv
    ├── usagers_2024.rds
    ├── usagers-2024.csv
    ├── vehicules_2024.rds
    ├── vehicules_2024.csv
├── R/
│
├── accidents-routiers.Rmd
├── accidents-routiers.html
├── README.md
└── projet S.Rproj

<text color="secondary" size="xs">Remarque : cette arborescence décrit l'organisation prévue du projet. </text>

### Étape 9 — Installation et exécution

```markdown
## Installation et exécution du projet

### 1. Cloner le dépôt GitHub

```bash
git clone URL_DU_DEPOT


### 5. Générer le rapport d'analyse

Pour générer le rapport HTML à partir du fichier R Markdown :

```r
rmarkdown::render("accidents-routiers.Rmd")


## Démonstration en ligne

L'application interactive est accessible ici :

👉 [Accéder au tableau de bord – Analyse des accidents de la route](https://senesaliou585.shinyapps.io/analyse-accidents-route-france/)


## Auteur

**Saliou Sène**

Master 2 Actuariat et Data Science

Université Paris Nanterre

Compétences mobilisées : R, Data Analysis, Statistiques, Data Visualization et Shiny.
