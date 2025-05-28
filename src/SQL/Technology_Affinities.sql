-- This updates the tech web as intended but the AI leaders don't seem to advance in affinities as well
-- -- Remove affinity points from branch techs
-- DELETE FROM Technology_Affinities
-- WHERE AffinityValue = 7
--     -- Only apply for Rising Tide
--     AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');

-- -- Increase affinity points for leaf techs to make up for the branch tech changes
-- UPDATE Technology_Affinities
-- SET AffinityValue = 27
-- WHERE AffinityValue = 20
--     AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');

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
