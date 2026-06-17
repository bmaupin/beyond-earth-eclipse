-- Prevent non-harmony factions from researching harmony techs
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
WHERE Civilizations.Playable = 1
  AND Civilizations.Type NOT IN
  (
    'CIVILIZATION_AL_FALAH',
    'CIVILIZATION_FRANCO_IBERIA',
    'CIVILIZATION_KAVITHAN',
    'CIVILIZATION_POLYSTRALIA'
  )
  AND AffinityType = 'AFFINITY_TYPE_HARMONY'
  AND AffinityValue >= 20;

-- Prevent non-purity factions from researching purity techs
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
WHERE Civilizations.Playable = 1
  AND Civilizations.Type NOT IN
  (
    'CIVILIZATION_AFRICAN_UNION',
    'CIVILIZATION_BRASILIA',
    'CIVILIZATION_INTEGR',
    'CIVILIZATION_RUSSIA'
  )
  AND AffinityType = 'AFFINITY_TYPE_PURITY'
  AND AffinityValue >= 20;

-- Prevent non-supremacy factions from researching supremacy techs
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
WHERE Civilizations.Playable = 1
  AND Civilizations.Type NOT IN
  (
    'CIVILIZATION_ARC',
    'CIVILIZATION_CHUNGSU',
    'CIVILIZATION_NORTH_SEA_ALLIANCE',
    'CIVILIZATION_PAN_ASIA'
  )
  AND AffinityType = 'AFFINITY_TYPE_SUPREMACY'
  AND AffinityValue >= 20;
