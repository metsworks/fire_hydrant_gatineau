DROP TABLE IF EXISTS lieu_publique;
DROP TABLE IF EXISTS decoupage_administratif;
DROP TABLE IF EXISTS adresse_immeuble;



CREATE TABLE decoupage_administratif (
  decoupageid INTEGER PRIMARY KEY,
  secteur VARCHAR(100),   
  type VARCHAR(100),
  abreviation VARCHAR(50),
  aire DOUBLE PRECISION,
  perimetre DOUBLE PRECISION,
  entiteid VARCHAR(100),
  geom TEXT
);

CREATE TABLE borne (
  borneid INTEGER PRIMARY KEY,                        
  type VARCHAR(50) NOT NULL,                          
  lieu TEXT,                                         
  etiquette VARCHAR(100),                            
  proprietaire VARCHAR(100),                         
  entiteid VARCHAR(100),                              
  geom TEXT,                         
  longitude DOUBLE PRECISION,                         
  latitude DOUBLE PRECISION,                         
  decoupageid INT NOT NULL,                 

 
  CONSTRAINT fk_decoupage
    FOREIGN KEY (decoupageid)
    REFERENCES decoupage_administratif(decoupageid)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);

CREATE TABLE adresse_immeuble (
  adresseid INTEGER PRIMARY KEY,                        
  numero_civ VARCHAR(20) NOT NULL,                  
  lieu TEXT,                                         
  direction VARCHAR(50),                             
  adresse_complete TEXT NOT NULL,                   
  ruesid VARCHAR(100),                             
  entiteid VARCHAR(100),                            
  geom TEXT,                        
  longitude DOUBLE PRECISION,                       
  latitude DOUBLE PRECISION,                         
  decoupageid INTEGER NOT NULL,                       
  CONSTRAINT fk_decoupage
    FOREIGN KEY (decoupageid)
    REFERENCES decoupage_administratif(decoupageid)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);

 
CREATE TABLE lieu_publique (
  lieu_publique_id INT PRIMARY KEY,                        
  lieuid INTEGER NOT NULL,                    
  type VARCHAR(100),                                 
  lieu TEXT,                                         
  nom_topographique TEXT,                            
  entiteid VARCHAR(100),                             
  geom TEXT,                        
  longitude DOUBLE PRECISION,                        
  latitude DOUBLE PRECISION,                         
  decoupageid INTEGER NOT NULL,                       

  CONSTRAINT fk_decoupage
    FOREIGN KEY (decoupageid)
    REFERENCES decoupage_administratif(decoupageid)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);



-- formule de Haversine pour calculer la distance entre deux points géographiques
-- Créer une table avec la distance minimale de chaque borne à un lieu public
CREATE TABLE borne_distance AS
SELECT
    b.borneid,
    b.type AS borne_type,
    b.lieu AS borne_lieu,
    b.longitude AS borne_longitude,
    b.latitude AS borne_latitude,
    b.decoupageid,
    MIN(
        6371 * 2 * ASIN(
            SQRT(
                POWER(SIN(RADIANS(l.latitude - b.latitude) / 2), 2) +
                COS(RADIANS(b.latitude)) *
                COS(RADIANS(l.latitude)) *
                POWER(SIN(RADIANS(l.longitude - b.longitude) / 2), 2)
            )
        )
    ) AS distance_min_km
FROM borne b
CROSS JOIN lieu_publique l
GROUP BY b.borneid, b.type, b.lieu, b.longitude, b.latitude, b.decoupageid;

select * from borne_distance;
SELECT *
FROM lieu_publique
WHERE nom_topographique = 'Archives Nationales';


SELECT usename, usecreatedb, usesuper, passwd FROM pg_user;

ALTER USER postgres WITH PASSWORD '@bb93_26postgres';
SELECT pg_reload_conf();.


ALTER USER postgres WITH PASSWORD 'nouveau_mot_de_passe';



CREATE EXTENSION IF NOT EXISTS postgis;


DROP VIEW IF EXISTS lieux_bornes_stats;

CREATE VIEW lieux_bornes_stats AS
WITH stats AS (
    SELECT
        l.lieu_publique_id,
        COUNT(b.borneid) FILTER (
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
                100
            )
        ) AS nombre_bornes_proches,
        MIN(
            ST_Distance(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
            )
        ) AS distance_min_metre
    FROM lieu_publique l
    LEFT JOIN borne b
        ON b.longitude IS NOT NULL AND b.latitude IS NOT NULL
    GROUP BY l.lieu_publique_id
)
SELECT
    l.lieu_publique_id,
    l.nom_topographique,
    l.type AS type_lieu,
    l.longitude AS lieu_longitude,
    l.latitude AS lieu_latitude,

    b.borneid,
    b.type AS type_borne,
    b.longitude AS borne_longitude,
    b.latitude AS borne_latitude,

    ST_Distance(
        ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
    ) AS distance_metre,

    s.nombre_bornes_proches,
    s.distance_min_metre,

    CASE
        WHEN s.distance_min_metre <= 50 THEN 'Bonne couverture'
        WHEN s.distance_min_metre <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS couverture

FROM lieu_publique l
LEFT JOIN borne b
    ON ST_DWithin(
        ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
        100
    )
LEFT JOIN stats s
    ON l.lieu_publique_id = s.lieu_publique_id
ORDER BY l.nom_topographique, distance_metre;



select * from lieux_bornes_stats2
DROP VIEW IF EXISTS lieux_bornes_stats2;

CREATE VIEW lieux_bornes_stats2 AS
WITH stats AS (
    SELECT
        l.lieu_publique_id,
        COUNT(b.borneid) FILTER (
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
                100
            )
        ) AS nombre_bornes_proches,
        MIN(
            ST_Distance(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
            )
        ) AS distance_min_any
    FROM lieu_publique l
    LEFT JOIN borne b
        ON b.longitude IS NOT NULL AND b.latitude IS NOT NULL
    GROUP BY l.lieu_publique_id
),
bornes_proches AS (
    SELECT
        l.lieu_publique_id,
        b.borneid,
        b.latitude,
        b.longitude,
        ROW_NUMBER() OVER (
            PARTITION BY l.lieu_publique_id
            ORDER BY ST_Distance(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
            )
        ) AS rn
    FROM lieu_publique l
    JOIN borne b
        ON ST_DWithin(
            ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
            100
        )
)
SELECT
    l.lieu_publique_id,
    COALESCE(l.nom_topographique, 'Inconnu') AS nom_lieu,
    COALESCE(l.type, 'Non spécifié') AS type_lieu,
    l.longitude AS lieu_longitude,
    l.latitude AS lieu_latitude,

    s.nombre_bornes_proches,
    COALESCE(ROUND(s.distance_min_any::numeric, 2), -1)::double precision AS distance_min_metre,

    CASE
        WHEN s.distance_min_any IS NULL THEN 'Aucune borne'
        WHEN s.distance_min_any <= 50 THEN 'Bonne couverture'
        WHEN s.distance_min_any <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS couverture,

    CASE
        WHEN s.distance_min_any IS NULL THEN 'Aucune borne disponible'
        WHEN s.distance_min_any <= 50 THEN 'Des bornes sont présentes directement sur le lieu'
        WHEN s.distance_min_any <= 100 THEN 'Au moins une borne est très proche du lieu'
        ELSE CONCAT('La borne la plus proche est à environ ',
                    ROUND(s.distance_min_any::numeric, 0), ' mètres')
    END AS interpretation,

    bp1.latitude AS borne1_latitude,
    bp1.longitude AS borne1_longitude,
    bp2.latitude AS borne2_latitude,
    bp2.longitude AS borne2_longitude

FROM lieu_publique l
LEFT JOIN stats s ON l.lieu_publique_id = s.lieu_publique_id
LEFT JOIN bornes_proches bp1 ON l.lieu_publique_id = bp1.lieu_publique_id AND bp1.rn = 1
LEFT JOIN bornes_proches bp2 ON l.lieu_publique_id = bp2.lieu_publique_id AND bp2.rn = 2
ORDER BY l.nom_topographique;





DROP VIEW IF EXISTS lieux_bornes_stats3;
DROP VIEW IF EXISTS v_analyse_immeuble;

CREATE VIEW lieux_bornes_stats3 AS
WITH stats AS (
    SELECT
        l.lieu_publique_id,
        COUNT(b.borneid) FILTER (
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
                100
            )
        ) AS nombre_bornes_proches,
        MIN(
            ST_Distance(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
            )
        ) AS distance_min_any
    FROM lieu_publique l
    LEFT JOIN borne b
        ON b.longitude IS NOT NULL AND b.latitude IS NOT NULL
    GROUP BY l.lieu_publique_id
)
SELECT
    l.lieu_publique_id,
    COALESCE(l.nom_topographique, 'Inconnu') AS nom_lieu,
    COALESCE(l.type, 'Non spécifié') AS type_lieu,
    l.longitude AS lieu_longitude,
    l.latitude AS lieu_latitude,

    -- Statistiques par lieu
    s.nombre_bornes_proches,
    COALESCE(ROUND(s.distance_min_any::numeric, 2), -1)::double precision AS distance_min_metre,

    -- Catégorie de couverture
    CASE
        WHEN s.distance_min_any IS NULL THEN 'Aucune borne'
        WHEN s.distance_min_any <= 50 THEN 'Bonne couverture'
        WHEN s.distance_min_any <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS couverture,

    -- Interprétation textuelle
    CASE
        WHEN s.distance_min_any IS NULL THEN 'Aucune borne disponible'
        WHEN s.distance_min_any <= 50 THEN 'Des bornes sont présentes directement sur le lieu'
        WHEN s.distance_min_any <= 100 THEN 'Au moins une borne est très proche du lieu'
        ELSE CONCAT('La borne la plus proche est à environ ',
                    ROUND(s.distance_min_any::numeric, 0), ' mètres')
    END AS interpretation

FROM lieu_publique l
LEFT JOIN stats s ON l.lieu_publique_id = s.lieu_publique_id
ORDER BY l.nom_topographique;


CREATE VIEW lieux_bornes_detail AS
SELECT
    l.lieu_publique_id,
    COALESCE(l.nom_topographique, 'Inconnu') AS nom_lieu,
    COALESCE(l.type, 'Non spécifié') AS type_lieu,

    -- Coordonnées du lieu
    l.longitude AS lieu_longitude,
    l.latitude AS lieu_latitude,

    -- Coordonnées des bornes proches
    b.borneid,
    b.longitude AS borne_longitude,
    b.latitude AS borne_latitude,

    -- Distance entre le lieu et la borne
    ROUND(
        ST_Distance(
            ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
        )::numeric, 2
    ) AS distance_metre
FROM lieu_publique l
LEFT JOIN borne b
    ON b.longitude IS NOT NULL
   AND b.latitude IS NOT NULL
   AND ST_DWithin(
        ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
        100
   )
ORDER BY l.nom_topographique, distance_metre;


CREATE OR REPLACE VIEW lieux_bornes_detail6 AS
WITH stats AS (
    SELECT
        l.lieu_publique_id,
        COUNT(b.borneid) FILTER (
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
                100
            )
        ) AS nombre_bornes_proches,
        MIN(
            ST_Distance(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
            )
        ) AS distance_min_metre
    FROM lieu_publique l
    LEFT JOIN borne b
        ON b.longitude IS NOT NULL AND b.latitude IS NOT NULL
    GROUP BY l.lieu_publique_id
)

-- Partie 1 : Lieux
SELECT
    l.lieu_publique_id,
    l.nom_topographique AS nom_lieu,
    l.type AS type_lieu,
    'Lieu' AS type_point,
    l.longitude,
    l.latitude,
    NULL::int AS borneid,
    s.nombre_bornes_proches,
    COALESCE(ROUND(s.distance_min_metre::numeric, 2), -1)::double precision AS distance_min_metre,
    CASE
        WHEN s.distance_min_metre IS NULL THEN 'Aucune borne'
        WHEN s.distance_min_metre <= 50 THEN 'Bonne couverture'
        WHEN s.distance_min_metre <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS couverture,
    CASE
        WHEN s.distance_min_metre IS NULL THEN 'Aucune borne disponible'
        WHEN s.distance_min_metre <= 50 THEN 'Des bornes sont présentes directement sur le lieu'
        WHEN s.distance_min_metre <= 100 THEN 'Au moins une borne est très proche du lieu'
        ELSE CONCAT('La borne la plus proche est à environ ',
                    ROUND(s.distance_min_metre::numeric, 0), ' mètres')
    END AS interpretation
FROM lieu_publique l
LEFT JOIN stats s ON l.lieu_publique_id = s.lieu_publique_id

UNION ALL

-- Partie 2 : Bornes proches
SELECT
    l.lieu_publique_id,
    l.nom_topographique AS nom_lieu,
    l.type AS type_lieu,
    'Borne' AS type_point,
    b.longitude,
    b.latitude,
    b.borneid,
    s.nombre_bornes_proches,
    COALESCE(ROUND(s.distance_min_metre::numeric, 2), -1)::double precision AS distance_min_metre,
    CASE
        WHEN s.distance_min_metre IS NULL THEN 'Aucune borne'
        WHEN s.distance_min_metre <= 50 THEN 'Bonne couverture'
        WHEN s.distance_min_metre <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS couverture,
    CASE
        WHEN s.distance_min_metre IS NULL THEN 'Aucune borne disponible'
        WHEN s.distance_min_metre <= 50 THEN 'Des bornes sont présentes directement sur le lieu'
        WHEN s.distance_min_metre <= 100 THEN 'Au moins une borne est très proche du lieu'
        ELSE CONCAT('La borne la plus proche est à environ ',
                    ROUND(s.distance_min_metre::numeric, 0), ' mètres')
    END AS interpretation
FROM lieu_publique l
JOIN borne b
  ON ST_DWithin(
        ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
        100
     )
LEFT JOIN stats s ON l.lieu_publique_id = s.lieu_publique_id;


---------------------------------------

CREATE OR REPLACE VIEW lieux_bornes_stats_secteur AS
WITH stats AS (
    -- Calcul des distances minimales pour chaque lieu_public
    SELECT
        l.lieu_publique_id,
        d.secteur,
        MIN(
            ST_Distance(
                ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
            )
        ) AS distance_min_metre
    FROM lieu_publique l
    JOIN decoupage_administratif d
        ON l.decoupageid = d.decoupageid
    LEFT JOIN borne b
        ON b.longitude IS NOT NULL AND b.latitude IS NOT NULL
    GROUP BY l.lieu_publique_id, d.secteur
),
bornes_stats AS (
    -- Statistiques par secteur sur les bornes
    SELECT
        d.secteur,
        SUM(CASE WHEN b.type = 'eau potable' THEN 1 ELSE 0 END) AS nb_eau_potable,
        SUM(CASE WHEN b.type = 'eau brute' THEN 1 ELSE 0 END) AS nb_eau_brute,
        COUNT(DISTINCT b.proprietaire) FILTER (WHERE b.proprietaire IS NOT NULL) AS nb_proprietaires_identifies
    FROM borne b
    JOIN decoupage_administratif d
        ON b.decoupageid = d.decoupageid
    GROUP BY d.secteur
)
SELECT
    s.secteur,
    CASE
        WHEN s.distance_min_metre IS NULL THEN 'Aucune borne'
        WHEN s.distance_min_metre <= 50 THEN 'Bonne couverture'
        WHEN s.distance_min_metre <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS couverture,
    COUNT(s.lieu_publique_id) AS nombre_lieux,
    COALESCE(b.nb_eau_potable, 0) AS nb_eau_potable,
    COALESCE(b.nb_eau_brute, 0) AS nb_eau_brute,
    COALESCE(b.nb_proprietaires_identifies, 0) AS nb_proprietaires_identifies
FROM stats s
LEFT JOIN bornes_stats b
    ON s.secteur = b.secteur
GROUP BY s.secteur,
         CASE
            WHEN s.distance_min_metre IS NULL THEN 'Aucune borne'
            WHEN s.distance_min_metre <= 50 THEN 'Bonne couverture'
            WHEN s.distance_min_metre <= 100 THEN 'Couverture moyenne'
            ELSE 'Faible couverture'
         END,
         b.nb_eau_potable,
         b.nb_eau_brute,
         b.nb_proprietaires_identifies
ORDER BY s.secteur, couverture;


--------------------------------------------

-- Index spatial sur les bornes
CREATE INDEX IF NOT EXISTS idx_borne_geom 
ON borne USING GIST (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326));

-- Index spatial sur les immeubles
CREATE INDEX IF NOT EXISTS idx_adresse_geom 
ON adresse_immeuble USING GIST (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326));

-- Index spatial sur les lieux publics (police, pompiers, hôpitaux)
CREATE INDEX IF NOT EXISTS idx_lieu_geom 
ON lieu_publique USING GIST (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326));

----------  --------------------

CREATE MATERIALIZED VIEW mv_borne_stats AS
SELECT 
    a.adresseid,
    MIN(
        ST_Distance(
            ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography
        )
    ) AS distance_min_m,
    COUNT(b.borneid) FILTER (
        WHERE ST_DWithin(
            ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
            100
        )
    ) AS nombre_bornes_proches
FROM adresse_immeuble a
JOIN borne b 
  ON ST_DWithin(
      ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
      300
  ) -- petit rayon de pré-filtrage pour accélérer
GROUP BY a.adresseid;

-----------   -----------------------
DROP MATERIALIZED VIEW IF EXISTS mv_borne_stats;
DROP MATERIALIZED VIEW IF EXISTS mv_services_proches;


CREATE MATERIALIZED VIEW mv_services_proches AS
SELECT 
    a.adresseid,

    -- Poste de police le plus proche
    (SELECT l.nom_topographique 
     FROM lieu_publique l
     WHERE l.type ILIKE '%Police%'
     ORDER BY ST_Distance(
         ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
     )
     LIMIT 1) AS police_nom,

    (SELECT ROUND(
        (ST_Distance(
            ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
        ) / 1000)::numeric, 3)
     FROM lieu_publique l
     WHERE l.type ILIKE '%Police%'
     ORDER BY ST_Distance(
         ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
     )
     LIMIT 1) AS police_distance_km,

    -- Caserne de pompiers
    (SELECT l.nom_topographique 
     FROM lieu_publique l
     WHERE l.type ILIKE '%Incendie%'
     ORDER BY ST_Distance(
         ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
     )
     LIMIT 1) AS pompiers_nom,

    (SELECT ROUND(
        (ST_Distance(
            ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
        ) / 1000)::numeric, 3)
     FROM lieu_publique l
     WHERE l.type ILIKE '%Incendie%'
     ORDER BY ST_Distance(
         ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
     )
     LIMIT 1) AS pompiers_distance_km,

    -- Hôpital le plus proche
    (SELECT l.nom_topographique 
     FROM lieu_publique l
     WHERE l.type ILIKE '%Centre Hospitalier%' OR l.type ILIKE '%Centre Hospitalier%'
     ORDER BY ST_Distance(
         ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
     )
     LIMIT 1) AS hopital_nom,

    (SELECT ROUND(
        (ST_Distance(
            ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
        ) / 1000)::numeric, 3)
     FROM lieu_publique l
     WHERE l.type ILIKE '%Centre Hospitalier%' OR l.type ILIKE '%Centre Hospitalier%'
     ORDER BY ST_Distance(
         ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
         ST_SetSRID(ST_MakePoint(l.longitude, l.latitude), 4326)::geography
     )
     LIMIT 1) AS hopital_distance_km

FROM adresse_immeuble a;




CREATE OR REPLACE VIEW v_analyse_immeuble AS
SELECT 
    a.adresseid,
    a.adresse_complete,
    d.secteur,
    ROUND(b.distance_min_m::numeric, 2) AS distance_min_borne_m,
    b.nombre_bornes_proches,
    CASE
        WHEN b.distance_min_m IS NULL THEN 'Aucune borne'
        WHEN b.distance_min_m <= 50 THEN 'Bonne couverture'
        WHEN b.distance_min_m <= 100 THEN 'Couverture moyenne'
        ELSE 'Faible couverture'
    END AS statut_couverture,

    -- Nom topographique + distance des services
    s.police_nom AS police_nom_topographique,
    s.police_distance_km,
    s.pompiers_nom AS pompiers_nom_topographique,
    s.pompiers_distance_km,
    s.hopital_nom AS hopital_nom_topographique,
    s.hopital_distance_km

FROM adresse_immeuble a
JOIN decoupage_administratif d ON a.decoupageid = d.decoupageid
LEFT JOIN mv_borne_stats b ON a.adresseid = b.adresseid
LEFT JOIN mv_services_proches s ON a.adresseid = s.adresseid
ORDER BY d.secteur, a.adresse_complete;


-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_borne_stats;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_services_proches;



----------------------------------



CREATE MATERIALIZED VIEW v_map_points_simple AS
-- Partie A : Point principal (adresse)
SELECT
  a.adresseid,
  a.adresse_complete,
  'Adresse' AS type_point,
  a.longitude,
  a.latitude
FROM adresse_immeuble a

UNION ALL

-- Partie B : Bornes proches de chaque adresse
SELECT
  a.adresseid,
  a.adresse_complete,
  'Borne' AS type_point,
  b.longitude,
  b.latitude
FROM adresse_immeuble a
JOIN borne b
  ON ST_DWithin(
       ST_SetSRID(ST_MakePoint(a.longitude, a.latitude), 4326)::geography,
       ST_SetSRID(ST_MakePoint(b.longitude, b.latitude), 4326)::geography,
       100  -- rayon en mètres (modifiable)
     );


  

------------------Pourcentage d’immeubles par statut de couverture-----------------------------

SELECT 
    statut_couverture,
    COUNT(*) AS nb_immeubles,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_immeubles
FROM v_analyse_immeuble
GROUP BY statut_couverture
ORDER BY pct_immeubles DESC;





-- ----------------- Pourcentage par secteur -------------------------------------

SELECT 
    secteur,
    statut_couverture,
    COUNT(*) AS nb_immeubles,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY secteur), 2) AS pct_immeubles
FROM v_analyse_immeuble
GROUP BY secteur, statut_couverture
ORDER BY secteur, pct_immeubles DESC;



--------------- Moyenne de distance par statut---------------------------------


SELECT 
    statut_couverture,
    ROUND(AVG(distance_min_borne_m), 2) AS distance_moyenne
FROM v_analyse_immeuble
GROUP BY statut_couverture
ORDER BY distance_moyenne;



----------Top 5 secteurs les mieux couverts ------ 
SELECT 
    secteur,
    ROUND(AVG(CASE WHEN statut_couverture = 'Bonne couverture' THEN 1 ELSE 0 END) * 100, 2) AS pct_bonne_couverture
FROM v_analyse_immeuble
GROUP BY secteur
ORDER BY pct_bonne_couverture DESC
LIMIT 5;


----------------- Nbres total d'immeubles ------------------
SELECT COUNT(*) AS total_immeubles
FROM v_analyse_immeuble;




----- Distance moyenne des services par secteur-------- 
SELECT 
    secteur,
    ROUND(AVG(pompiers_distance_km), 2) AS dist_moy_pompiers_km,
    ROUND(AVG(police_distance_km), 2) AS dist_moy_police_km,
    ROUND(AVG(hopital_distance_km), 2) AS dist_moy_hopital_km
FROM v_analyse_immeuble
GROUP BY secteur
ORDER BY dist_moy_pompiers_km;



------------ 🔍 b. Corrélation entre couverture incendie et distance des pompiers-----------    

SELECT 
    statut_couverture,
    ROUND(AVG(pompiers_distance_km), 2) AS distance_moy_pompiers_km
FROM v_analyse_immeuble
GROUP BY statut_couverture
ORDER BY distance_moy_pompiers_km;




select * from lieux_bornes_detail
select * from v_analyse_immeuble;
select * from v_map_points_simple;
select * from lieux_bornes_combine
select * from v_analyse_immeuble;
select * from adresse_immeuble;
select type from lieu_publique;




