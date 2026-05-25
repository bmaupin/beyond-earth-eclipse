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
