function ShowPopup(victoryType, victoryObjectiveKey, showVictoryPrologue)
    Events.SerialEventGameMessagePopup( {
        Type = ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS,
        Data1 = GameInfo.Quests[victoryType].ID,
        Option1 = showVictoryPrologue,
        Text = victoryObjectiveKey
    } );
end

-- function OnTechResearched(teamType, techType, change)
--     print("(Beyond Earth Eclipse) OnTechResearched")

--     local activePlayer
--     if Game.GetActivePlayer() ~= nil then
--         activePlayer = Players[Game.GetActivePlayer()]
--     else
--         activePlayer = Players[0]
--     end
--     if activePlayer:GetTeam() == teamType and activePlayer:IsHuman() then
--         if techType == GameInfo.Technologies["TECH_TRANSGENICS"].ID then
--             print("(Beyond Earth Eclipse) showing popup for transgenics")
--             ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_TRANS_EPILOGUE")
--         elseif techType == GameInfo.Technologies["TECH_SWARM_INTELLIGENCE"].ID then
--             ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_SWARM_EPILOGUE")
--         elseif techType == GameInfo.Technologies["TECH_NANOROBOTICS"].ID then
--             ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_NANO_EPILOGUE")
--         end
--     end
-- end
-- GameEvents.TeamTechResearched.Add(OnTechResearched)

-- local contactVictoryStage = 0;
-- local emancipationVictoryStage = 0;
-- local promisedLandVictoryStage = 0;
-- local transcendenceVictoryStage = 0;

-- function UpdateVictoryStages()
--     local player = Players[Game.GetActivePlayer()]

--     if not player:IsHuman() or not player:IsAlive() then
--         return;
--     end

--     local quests = player:GetQuests()

--     for i, quest in ipairs(quests) do
--         if quest:GetType() == "QUEST_VICTORY_CONTACT" then
--             contactVictoryStage = quest:GetPersistentData().Stage
--         elseif quest:GetType() == "QUEST_VICTORY_EMANCIPATION" then
--             emancipationVictoryStage = quest:GetStage()
--         elseif quest:GetType() == "QUEST_VICTORY_PROMISED_LAND" then
--             promisedLandVictoryStage = quest:GetStage()
--         elseif quest:GetType() == "QUEST_VICTORY_TRANSCENDENCE" then
--             transcendenceVictoryStage = quest:GetStage()
--         end
--     end


-- end

-- Events.SequenceGameInitComplete.Add(UpdateVictoryStages);

-- local victoryObjectives;
-- function UpdateVictoryObjectives()
--     local player = Players[Game.GetActivePlayer()]

--     if not player:IsHuman() or not player:IsAlive() then
--         return;
--     end

--     local quests = player:GetQuests()

--     for i, quest in ipairs(quests) do
--         if quest:GetType() == "QUEST_VICTORY_CONTACT" then
--             victoryObjectives = quest:GetObjectives()
--         elseif quest:GetType() == "QUEST_VICTORY_EMANCIPATION" then
--             victoryObjectives = quest:GetObjectives()
--         elseif quest:GetType() == "QUEST_VICTORY_PROMISED_LAND" then
--             victoryObjectives = quest:GetObjectives()
--         elseif quest:GetType() == "QUEST_VICTORY_TRANSCENDENCE" then
--             victoryObjectives = quest:GetObjectives()
--         end
--     end

-- end

-- Events.SequenceGameInitComplete.Add(UpdateVictoryObjectives);



-- function ShowVictoryStagePopup(victoryType, stage)
--     local textKey = "TXT_KEY_QUEST_VICTORY_" .. victoryType .. "_STAGE_" .. stage
--     ShowPopup(victoryType, textKey)
-- if contactVictoryStage > 0 then
--     ShowPopup("QUEST_VICTORY_CONTACT", "TXT_KEY_QUEST_VICTORY_CONTACT_STAGE_" .. contactVictoryStage)
-- end

-- if emancipationVictoryStage > 0 then
--     ShowPopup("QUEST_VICTORY_EMANCIPATION", "TXT_KEY_QUEST_VICTORY_EMANCIPATION_STAGE_" .. emancipationVictoryStage)
-- end

-- if promisedLandVictoryStage > 0 then
--     ShowPopup("QUEST_VICTORY_PROMISED_LAND", "TXT_KEY_QUEST_VICTORY_PROMISED_LAND_STAGE_" .. promisedLandVictoryStage)
-- end

-- if transcendenceVictoryStage > 0 then
--     ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_STAGE_" .. transcendenceVictoryStage)
-- end
-- end


-- Track which victory quest strings we've shown by storing the text key for each one
local shownVictoryQuestStrings = {}

-- DELETEME
local function printTable(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. " = {")
            printTable(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. k .. " = " .. tostring(v))
        end
    end
end

function PopulateCompletedVictoryObjectives()
    for playerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local player = Players[playerID];

        if player:IsHuman() and player:IsAlive() then
            -- DELETEME
            print("(Beyond Earth Eclipse) === populating completed victory objective IDs " .. playerID .. " ===");

            local quests = player:GetQuests()
            for _, quest in ipairs(quests) do
                local questPrologue = quest:GetPrologue();
                local questId = quest:GetType()
                local questInfo = GameInfo.Quests[questId];
                local questType = questInfo.Type;

                -- if (quest:IsInProgress() and
                if (
                    (questType == "QUEST_VICTORY_CONTACT" or
                    questType == "QUEST_VICTORY_EMANCIPATION" or
                    questType == "QUEST_VICTORY_PROMISED_LAND" or
                    questType == "QUEST_VICTORY_TRANSCENDENCE")
                ) then
                    -- DELETEME
                    print("(Beyond Earth Eclipse) questType = " .. questType)

                    local objectives = quest:GetObjectives()
                    for _, objective in ipairs(objectives) do
                        local objectiveEpilogue = objective:GetEpilogue()

                        if ((not objective:IsInProgress()) and
                            objective:DidSucceed() and
                            not shownVictoryQuestStrings[objectiveEpilogue]
                        ) then
                            shownVictoryQuestStrings[objectiveEpilogue] = true;

                            -- Add the quest prologue text key as well; we should only
                            -- show this once per victory type
                            if (not shownVictoryQuestStrings[questPrologue]) then
                                shownVictoryQuestStrings[questPrologue] = true;
                            end
                        end
                    end
                end
            end

            -- DELETEME
            print("(Beyond Earth Eclipse) completedVictoryObjectiveIds=", "    ")
            print("(Beyond Earth Eclipse) completedVictoryObjectives is nil? ", shownVictoryQuestStrings == nil)
            print("(Beyond Earth Eclipse) completedVictoryObjectives count = ", table.count(shownVictoryQuestStrings))
            print(shownVictoryQuestStrings)
            printTable(shownVictoryQuestStrings)
        end
    end
end
-- Run this once when the game is first started/loaded
Events.SequenceGameInitComplete.Add(PopulateCompletedVictoryObjectives);

function ShowVictoryPopup(playerID)
    local player = Players[playerID];
    if not player:IsHuman() or not player:IsAlive() then
        return;
    end

    print("(Beyond Earth Eclipse) === Turn for Player " .. playerID .. " ===")

    local quests = player:GetQuests()
    for _, quest in ipairs(quests) do
        local questPrologue = quest:GetPrologue();
        local questId = quest:GetType()
        local questInfo = GameInfo.Quests[questId];
        local questType = questInfo.Type;

        -- NOTE: We don't need logic to determine whether a victory type has been disabled
        --       in the game options because disabled victories won't show up in the
        --       player's quests
        if (quest:IsInProgress() and
            (questType == "QUEST_VICTORY_CONTACT" or
            questType == "QUEST_VICTORY_EMANCIPATION" or
            questType == "QUEST_VICTORY_PROMISED_LAND" or
            questType == "QUEST_VICTORY_TRANSCENDENCE")
        ) then
            -- DELETEME
            print("(Beyond Earth Eclipse) questType = " .. questType)

            local objectives = quest:GetObjectives()
            for _, objective in ipairs(objectives) do
                local objectiveEpilogue = objective:GetEpilogue()

                if ((not objective:IsInProgress()) and
                    objective:DidSucceed() and
                    not shownVictoryQuestStrings[objectiveEpilogue]
                ) then
                    -- TODO: only show text for highest affinity
                       -- Get affinity levels for all affinities and record highest level
                       -- Check that affinity for victory matches highest level, this way it will also match if they're tied
                    -- TODO: add logic for overlapping emancipation/promised land first objective
                       -- Randomly show one or the other? Or a custom message?
                       -- Requires Orbital Networks, which could potentially be researched with tied purity/supremacy
                    -- TODO: do we need to exclude the quest epilogue objectives?, e.g. TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_WAIT_EPILOGUE
                    -- TODO: do we need to include the quest wait summary? e.g. TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_WAIT_EPILOGUE
                    -- TODO: show domination prologue after first capital is conquered?

                    -- Show the victory quest prologue the first time we show a popup for
                    -- a particular victory type
                    local showVictoryPrologue = false;
                    if (not shownVictoryQuestStrings[questPrologue]) then
                        showVictoryPrologue = true;
                        shownVictoryQuestStrings[questPrologue] = true;
                    end

                    print("(Beyond Earth Eclipse) showing popup for victory " .. questType .. " objective " .. objective:GetSummary())
                    -- Unfortunately the epilogue text for the transcendence victory tech
                    -- objectives are repetitive, so only show whichever is finished
                    -- first.
                    if (
                        not shownVictoryQuestStrings["TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_NANO_EPILOGUE"] and
                        not shownVictoryQuestStrings["TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_SWARM_EPILOGUE"] and
                        not shownVictoryQuestStrings["TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_TRANS_EPILOGUE"]
                    ) then
                        ShowPopup(questType, objectiveEpilogue, showVictoryPrologue);
                    end
                    shownVictoryQuestStrings[objectiveEpilogue] = true;

                    -- DELETEME
                    print("(Beyond Earth Eclipse) completedVictoryObjectiveIds=", "    ")
                    printTable(shownVictoryQuestStrings)
                end
            end
        end
    end
end
GameEvents.PlayerDoTurn.Add(ShowVictoryPopup);
