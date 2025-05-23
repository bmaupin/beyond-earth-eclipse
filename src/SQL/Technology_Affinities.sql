-- Remove affinity points from branch techs
DELETE FROM Technology_Affinities
WHERE AffinityValue = 7
    -- Only apply for Rising Tide
    AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');

-- Increase affinity points for leaf techs to make up for the branch tech changes
UPDATE Technology_Affinities
SET AffinityValue = 27
WHERE AffinityValue = 20
    AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');
