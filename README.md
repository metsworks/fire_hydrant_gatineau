🔥 Fire Hydrant Coverage Analysis — Gatineau, Québec

A geospatial data analysis project assessing fire hydrant accessibility across Gatineau’s residential areas to improve emergency response and urban safety planning.

📊 Overview of Findings

L’analyse géospatiale des bornes d’incendie à Gatineau révèle que 65.27 % des immeubles résidentiels bénéficient d’une bonne couverture, contre 30.87 % à couverture moyenne, 1.35 % à couverture faible, et 2.52 % sans borne à proximité.
Le secteur de Hull affiche la meilleure performance (71.74 % d’adresses bien couvertes) et seulement 0.20 % à faible couverture, tandis que Masson-Angers et Aylmer présentent respectivement 64.76 % et 62.74 %.
Les immeubles bien couverts se situent en moyenne à 32.26 m d’une borne, contre 62.14 m pour ceux à couverture moyenne — une performance solide, mais avec des zones ciblées d’amélioration identifiées pour renforcer la résilience urbaine.

## 🧭 1. Project Background

Cet été, un incendie particulièrement ravageur s’est déclaré à la limite de Masson-Angers, emportant plusieurs résidences.
Cet événement m'a fait réfléchir et a soulevé une question essentielle : la répartition des bornes d’incendie à Gatineau répond-elle efficacement aux besoins réels des pompiers et des citoyens ?

Ce projet vise à explorer la relation spatiale entre les bornes d’incendie, les immeubles résidentiels et les services d’urgence, afin de :

Mesurer la proximité réelle entre bâtiments et bornes,

Identifier les zones sous-desservies,

et fournir des recommandations opérationnelles fondées sur les données ouvertes de la Ville de Gatineau.

## 🌍 2. Overview

Le projet repose sur une analyse géospatiale croisant les adresses d’immeubles résidentiels et les bornes d’incendie pour évaluer la qualité de couverture à travers la ville.

Couverture - Distance à la borne - Statut

🟢 Bonne couverture	 < 50 m	 Conforme
🟡 Couverture moyenne	50–100 m	Acceptable
🔴 Faible couverture	> 100 m	À améliorer
⚫ Aucune borne: 	Aucune dans un rayon de 150 m	Prioritaire

Pour visualiser le rapport, veillez accéder au dossier dashboard 👉  [Voir le fichier](https://github.com/metsworks/fire_hydrant_gatineau/blob/main/dashboard/looker_report.txt)

## 🧩 3. Data Structure
Données principales

borne → bornes d’incendie (ID, type, coordonnées, secteur administratif)
Contient la géolocalisation et les métadonnées des bornes (type, propriétaire, étiquette).
Sert de base pour mesurer la proximité avec les immeubles résidentiels.

adresse_immeuble → adresses d’immeubles résidentiels géolocalisées
Regroupe les informations civiques et géographiques de chaque immeuble résidentiel de Gatineau.
Table centrale pour l’analyse de couverture.

coverage_zones → table dérivée du croisement spatial entre borne et adresse_immeuble
Classifie chaque adresse selon la distance à la borne la plus proche :
🟢 bonne couverture (< 50 m), 🟡 moyenne (50–100 m), 🔴 faible (> 100 m), ⚫ aucune borne à proximité.

lieu_publique → infrastructures publiques (écoles, hôpitaux, casernes, postes de police)
Sert à l’analyse de proximité secondaire, mesurant la cohérence urbaine entre habitations et services essentiels.

decoupage_administratif → structure géographique officielle de la Ville de Gatineau
Définit les secteurs et sous-secteurs (Hull, Aylmer, Masson-Angers, etc.) pour agréger les résultats par zone.

Relations clés

adresse_immeuble ⟷ borne → calcul de distance spatiale via PostGIS (ST_DWithin, ST_Distance) pour déterminer la borne la plus proche.

coverage_zones → table dérivée enrichie d’un indicateur de performance de couverture.

adresse_immeuble ⟷ lieu_publique → relation utilisée pour évaluer la proximité des services d’urgence.

decoupage_administratif → clé géographique commune assurant la cohérence spatiale entre toutes les tables.

📎 Le diagramme complet des relations (ERD) est disponible dans ![Carte des bornes fontaines](./data_structure/erd.png)


.
Ce schéma illustre la structure logique du modèle et le flux de données utilisé pour générer les indicateurs de couverture.

## 📈 4. Executive Summary — Key Insights

📊 Executive Summary


📎 Le diagramme complet des relations (ERD) est disponible dans ![Carte des bornes fontaines](./docs/summary.png)




## 🧠 6. Recommendations

Cibler les adresses à faible couverture pour une installation prioritaire de bornes.

Intégrer la cartographie de couverture aux processus de planification urbaine municipale.

Créer un tableau de bord dynamique (Looker Studio / Databricks) pour suivre les écarts de couverture.

Corréler la densité de bornes avec les nouveaux permis de construction pour une gestion prédictive.

Collaborer avec les services d’urgence afin de valider les distances critiques et les temps de réponse réels.

## ⚙️ 7. Tech Stack
Pandas – Data wrangling and ETL
PostgreSQL / pgAdmin – Data warehouse, spatial analysis (ST_DWithin, ST_Distance)
Looker Studio – Visualisation



