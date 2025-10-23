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

Pour visualiser le rapport, veillez accéder au dossier dashboard 👉 [Voir le fichier Looker report](./dashboard/looker_report.txt)

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

📎 Le diagramme complet des relations (ERD) est disponible dans /assets/fire_hydrant_erd.png
.
Ce schéma illustre la structure logique du modèle et le flux de données utilisé pour générer les indicateurs de couverture.

## 📈 4. Executive Summary — Key Insights

📊 Executive Summary

Thème	Insight / Valeur clé	Business Metric / Impact	Storytelling / Interprétation
🏠 Couverture globale	65.27 % des immeubles bien couverts, 30.87 % moyenne, 1.35 % faible, 2.52 % sans borne	Montre une couverture satisfaisante, mais des poches à risque persistent	La majorité des bâtiments de Gatineau ont accès à une borne, mais certaines zones restent vulnérables aux délais d’intervention.
🧭 Performance par secteur	Hull : 71.74 %, Aylmer : 62.74 %, Masson-Angers : 64.76 %	Hull présente la meilleure répartition spatiale	Les infrastructures urbaines de Hull offrent la meilleure accessibilité incendie de la ville.
📏 Proximité moyenne	Bonne couverture : 32.26 m — Moyenne : 62.14 m	Corrélation forte entre distance et niveau de risque	Plus la borne est proche, plus la capacité d’intervention est rapide et efficace.
🚒 Services d’urgence	Immeubles de Masson-Angers à 5.35 km d’une caserne, 5.31 km d’un poste de police, 7.04 km d’un hôpital	Permet d’évaluer la rapidité potentielle de réponse en cas d’incident	Les distances moyennes aux services critiques restent stables mais optimisables dans certains sous-secteurs.
⚙️ Recommandation clé	Cibler les 40 adresses à faible couverture identifiées à Hull	Amélioration de la couverture globale → quasi 100 %	Une planification ciblée des nouvelles bornes permettrait de renforcer l




## 🧠 6. Recommendations

Cibler les adresses à faible couverture pour une installation prioritaire de bornes.

Intégrer la cartographie de couverture aux processus de planification urbaine municipale.

Créer un tableau de bord dynamique (Looker Studio / Databricks) pour suivre les écarts de couverture.

Corréler la densité de bornes avec les nouveaux permis de construction pour une gestion prédictive.

Collaborer avec les services d’urgence afin de valider les distances critiques et les temps de réponse réels.

## ⚙️ 7. Tech Stack
Layer	Tools / Libraries	Purpose
ETL	Python, Pandas	Extraction et transformation des données
Spatial Database	PostgreSQL + PostGIS	Calculs spatiaux (ST_DWithin, ST_Distance), index GIST
Analytics	GeoPandas, Shapely	Classification et analyse géographique
Visualization	Looker Studio	Tableaux de bord et cartes interactives
Versioning & Hosting	GitHub	Documentation, reproductibilité, et collaboration

## ⚠️ 8. Caveats & Assumptions

Les distances sont géodésiques (en ligne droite), sans pondération par le réseau routier.

Les coordonnées sont issues de données publiques, sujettes à mise à jour.

Les seuils de couverture (50 m / 100 m) reposent sur des références standard de sécurité incendie.

Le projet n’est pas affilié à la Ville de Gatineau, mais se base sur ses données ouvertes.

## 📚 9. Summary

Ce projet démontre comment les données géospatiales peuvent aider à renforcer la planification urbaine et la sécurité publique.
En combinant les bornes d’incendie, les adresses résidentielles et les infrastructures publiques, il met en évidence les zones bien desservies et celles nécessitant des interventions ciblées.
Les résultats peuvent guider les décideurs municipaux dans l’allocation de ressources, la planification des nouvelles installations et l’amélioration des temps de réponse d’urgence.

💡 Le diagramme ERD et les visualisations interactives sont disponibles dans /assets
.
📍 Sources : Données ouvertes — Ville de Gatineau.
