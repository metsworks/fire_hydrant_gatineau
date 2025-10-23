## Project Background
Un soir d’été, un incendie dévastateur a frappé le secteur de Masson-Angers, à Gatineau.
Trois maisons ont été réduites en cendres. Une communauté choquée. Et une question essentielle :

Sommes-nous vraiment prêts à répondre efficacement quand chaque seconde compte ?

Cet événement m’a poussé à réfléchir au rôle crucial de nos bornes d’incendie dans la chaîne de réponse d’urgence.
Au-delà de la simple présence d’une borne, la proximité réelle des infrastructures de sécurité — casernes de pompiers, postes de police, hôpitaux — influence directement la rapidité d’intervention et donc, la capacité à sauver des vies.

Je me suis alors posé plusieurs questions :

Les bornes d’incendie sont-elles idéalement réparties autour des immeubles résidentiels et des lieux publics sensibles (écoles, centres communautaires, résidences pour aînés) ?

Certaines zones urbaines en pleine croissance immobilière ne sont-elles pas sous-desservies ?

Les services d’urgence les plus proches — pompiers, police, hôpitaux — peuvent-ils accéder rapidement aux zones à risque ?

Pour y répondre, j’ai conçu un projet d’analyse géospatiale basé sur les données ouvertes de la Ville de Gatineau.
Ce travail vise à cartographier et mesurer la couverture des bornes d’incendie en relation avec :

les immeubles résidentiels 
la distance réelle aux services d’urgence,


L’objectif est double :

- Identifier les immeubles vulnérables, où le maillage de bornes ou la proximité des secours pourrait être optimisé 

- Montrer comment les données ouvertes et l’intelligence géospatiale peuvent servir la sécurité urbaine, soutenir les décisions publiques et renforcer la prévention citoyenne.

Les principaux insights et recommandations issus de l’analyse sont documentés dans le dossier /insights
 du repository.
On y retrouve une synthèse claire des résultats, des pistes d’amélioration et des suggestions pour une meilleure planification territoriale.





## 🌍 Overview

Ce projet se concentre sur l’analyse géospatiale des bornes d’incendie à Gatineau, en relation directe avec les adresses d’immeubles résidentiels.
L’objectif principal est d’évaluer la proximité réelle entre chaque bâtiment et la borne d’incendie la plus proche, afin de mesurer la qualité de couverture du réseau de bornes à travers la ville.

Les distances ont été catégorisées en trois niveaux :

🟢 Bonne couverture : moins de 50 mètres

🟡 Couverture moyenne : entre 50 et 100 mètres

🔴 Faible couverture : au-delà de 100 mètres

Cette approche permet d’identifier les zones potentiellement sous-desservies, notamment dans les quartiers résidentiels en expansion, et d’apporter des informations utiles aux services d’urgence (pompiers, police, hôpitaux) ainsi qu’à la planification urbaine.

L’ensemble du traitement et de la visualisation a été réalisé avec Python et les bibliothèques GeoPandas, Shapely et Folium pour la cartographie interactive.
Les insights et recommandations sont disponibles dans le dossier /insights
.

## 🗺️ Data Structure

La structure des données et leurs relations sont représentées ci-dessous :

![Data Model](./assets/data_model.png)

SQL schema ![Data Model](./assets/data_model.png)


## Summary
📊 Overview of Findings

L’analyse géospatiale des bornes d’incendie à Gatineau révèle que 65.27 % des immeubles résidentiels bénéficient d’une bonne couverture, contre 30.87 % à couverture moyenne, 1.35 % à couverture faible, et 2.52 % sans borne à proximité. Le secteur de Hull se distingue par la meilleure performance (71.74 % d’adresses bien couvertes) et seulement 0.20 % à faible couverture, tandis que Masson-Angers et Aylmer affichent respectivement 64.76 % et 62.74 %. En moyenne, les immeubles bien couverts se trouvent à 32.26 m d’une borne, contre 62.14 m pour ceux en couverture moyenne. Ces résultats soulignent une bonne performance globale, mais mettent en évidence des zones ciblées d’amélioration pour atteindre une couverture quasi complète sur l’ensemble du territoire.

https://lookerstudio.google.com/reporting/761f92ad-2a7b-40ce-bcb8-b43b9fccbbba


