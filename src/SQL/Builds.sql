-- The Node improvement is only available to supremacy, so make these improvements
-- affinity-specific as well for more balanced and assymetric gameplay
-- Harmony
UPDATE Builds
SET PrereqTech = 'TECH_TISSUE_ENGINEERING'
WHERE Type = 'BUILD_BIOWELL';

-- Purity
UPDATE Builds
SET PrereqTech = 'TECH_CIVIL_SUPPORT'
WHERE Type = 'BUILD_DOME';


-- TODO: Test; if affinity resources/units take too long to get to, we could move these
--       to earlier leaf techs (TECH_ALIEN_LIFEFORMS, TECH_BALLISTICS, TECH_POWER_SYSTEMS)
-- Limit the tile improvements for affinity resources to the corresponding affinity by
-- moving each one from the branch tech to the affinity-specific leaf tech under it
-- Harmony
UPDATE Builds
SET PrereqTech = 'TECH_ALIEN_ADAPTATION'
WHERE Type = 'BUILD_XENOMASS_WELL';

-- Purity
UPDATE Builds
SET PrereqTech = 'TECH_BIOSPHERES'
WHERE Type = 'BUILD_FLOAT_STONE_QUARRY';

-- Supremacy
UPDATE Builds
SET PrereqTech = 'TECH_TACTICAL_ROBOTICS'
WHERE Type = 'BUILD_FIRAXITE_MINE';
