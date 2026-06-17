-- Apollo gives all AI one free affinity level for all affinities, which we don't want
-- because we only want each faction to have one affinity
UPDATE HandicapInfos SET AIFreeAffinityLevel = 0;
