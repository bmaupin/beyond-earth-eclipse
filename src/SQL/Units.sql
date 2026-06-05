-- Encourage AI to build affinity-specific units. It's hard to tell how effective this is
-- (see docs/notes/test-results.md) but it doesn't seem to be detrimental.
INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT DISTINCT uap.UnitType, 'FLAVOR_HARMONY', 100
FROM Unit_AffinityPrereqs AS uap
WHERE uap.AffinityType = 'AFFINITY_TYPE_HARMONY'
  AND NOT EXISTS (
    SELECT 1
    FROM Unit_AffinityPrereqs AS other
    WHERE other.UnitType = uap.UnitType
      AND other.AffinityType <> 'AFFINITY_TYPE_HARMONY'
  );

INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT DISTINCT uap.UnitType, 'FLAVOR_PURITY', 100
FROM Unit_AffinityPrereqs AS uap
WHERE uap.AffinityType = 'AFFINITY_TYPE_PURITY'
  AND NOT EXISTS (
    SELECT 1
    FROM Unit_AffinityPrereqs AS other
    WHERE other.UnitType = uap.UnitType
      AND other.AffinityType <> 'AFFINITY_TYPE_PURITY'
  );

INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT DISTINCT uap.UnitType, 'FLAVOR_SUPREMACY', 100
FROM Unit_AffinityPrereqs AS uap
WHERE uap.AffinityType = 'AFFINITY_TYPE_SUPREMACY'
  AND NOT EXISTS (
    SELECT 1
    FROM Unit_AffinityPrereqs AS other
    WHERE other.UnitType = uap.UnitType
      AND other.AffinityType <> 'AFFINITY_TYPE_SUPREMACY'
  );

-- For Rising Tide, give the vapor shield promotion to all units for free; this removes
-- the unit strength penalty when embarked, because the AI is very bad about putting land
-- units in the water
INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT Type, 'PROMOTION_VAPOR_SHIELD'
FROM Units
WHERE Units.AlienLifeform = 0
  -- Limit to Rising Tide only; unfortunately the promotion only exists in Rising Tide,
  -- and attempts to add it to the base game seemed to have no effect; maybe the logic for
  -- EmbarkDefenseModifier that the promotion relies on was only added in Rising Tide?
  AND EXISTS (SELECT Description FROM Civilizations WHERE Type = 'CIVILIZATION_CHUNGSU');
