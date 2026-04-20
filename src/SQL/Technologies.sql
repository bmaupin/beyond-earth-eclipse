-- NOTE: This and any other changes to Technology_Affinities need to happen before the
-- the affinity values are adjusted below
--
-- Protogenetics is the only hybrid leaf tech, so move one of the affinities to avoid
-- hybrid affinities
UPDATE Technology_Affinities
SET TechType = 'TECH_VERTICAL_FARMING'
WHERE TechType = 'TECH_PROTOGENETICS'
  AND AffinityType = 'AFFINITY_TYPE_PURITY'
  AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');

-- Update the cost to keep the techs balanced for each affinity
UPDATE Technologies
SET COST = (
  SELECT COST FROM Technologies WHERE Type = 'TECH_PROTOGENETICS'
)
WHERE Type = 'TECH_VERTICAL_FARMING'
  AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');



-- Remove affinity points from branch techs because we don't want to block any branch
-- techs and we also don't want any hybrid affinities
DELETE FROM Technology_Affinities
WHERE AffinityValue = 7
  -- Only apply for Rising Tide
  AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');

-- Increase affinity points for leaf techs to make up for the branch tech changes
UPDATE Technology_Affinities
SET AffinityValue = 27
WHERE AffinityValue = 20
  AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');

-- This helps the AI leaders choose techs that align with their preferred affinity (as determined by Leader_Flavors)
INSERT INTO Technology_Flavors (TechType, FlavorType, Flavor)
SELECT
    a.TechType,
    CASE a.AffinityType
        WHEN 'AFFINITY_TYPE_HARMONY' THEN 'FLAVOR_HARMONY'
        WHEN 'AFFINITY_TYPE_PURITY' THEN 'FLAVOR_PURITY'
        WHEN 'AFFINITY_TYPE_SUPREMACY' THEN 'FLAVOR_SUPREMACY'
    END AS FlavorType,
    100 AS Flavor
FROM Technology_Affinities a
WHERE a.AffinityValue > 1
  AND a.AffinityType IN ('AFFINITY_TYPE_HARMONY', 'AFFINITY_TYPE_PURITY', 'AFFINITY_TYPE_SUPREMACY');
