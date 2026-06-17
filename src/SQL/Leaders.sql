-- Affinities are key to stronger units, victories, etc. Affinity points primarily come
-- from technologies, which need science to research, so give all AI players high science
-- to help them out a bit since the AI doesn't seem to be very strong.
UPDATE Leader_Flavors
-- NOTE: The game can adjust this up or down by 2 and the max is 10, so a flavor of 10 in
--       practice means 8 to 10
SET Flavor = 10
WHERE FlavorType = 'FLAVOR_SCIENCE'
AND LeaderType != 'LEADER_ALIEN';
