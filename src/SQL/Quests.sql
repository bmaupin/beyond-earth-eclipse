-- Delete affinity choice quests to prevent factions from being able to choose affinities
-- other than the one we want to explicitly assign to them
DELETE FROM Quests
WHERE QuestSetType = 'QUEST_SET_CHOICE_QUESTS';
