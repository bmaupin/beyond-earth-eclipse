-- TODO: clean this up
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

    -- Emancipation and promised land victories share the first objective.
    -- If the player has a tied purity and supremacy level, both of them
    -- would be shown at once. Instead, we pick one of them randomly to
    -- show and don't show the other one.
    local showPurityProloguePopup = math.random() < 0.5;

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
                    -- TODO: show domination prologue after first capital is conquered?

                    local showObjectivePopup = false;
                    local showProloguePopup = true;

                    -- Unfortunately the epilogue text for the transcendence victory tech
                    -- objectives are repetitive, so only show whichever is finished
                    -- last.
                    if (
                        questType == "QUEST_VICTORY_TRANSCENDENCE" and
                        objectives[1]:DidSucceed() and
                        objectives[2]:DidSucceed() and
                        objectives[3]:DidSucceed()
                    ) then
                        showObjectivePopup = true;
                    end

                    -- TODO: test this
                    -- For affinity victory types, only show the popup if it's the
                    -- highest affinity (or tied)
                    local purityLevel = player:GetAffinityLevel(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID);
                    local harmonyLevel = player:GetAffinityLevel(GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID);
                    local supremacyLevel = player:GetAffinityLevel(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID);
                    if (
                        (
                            questType == "QUEST_VICTORY_EMANCIPATION" and
                            supremacyLevel < purityLevel and
                            supremacyLevel < harmonyLevel
                        ) or
                        (
                            questType == "QUEST_VICTORY_PROMISED_LAND" and
                            purityLevel < harmonyLevel and
                            purityLevel < supremacyLevel
                        ) or
                        (
                            questType == "QUEST_VICTORY_TRANSCENDENCE" and
                            harmonyLevel < purityLevel and
                            harmonyLevel < supremacyLevel
                        )
                    ) then
                        showProloguePopup = false;
                    end

                    -- TODO: test this
                    -- Show purity first objective popup but not supremacy
                    if (
                        purityLevel == supremacyLevel and
                        objectiveEpilogue == "TXT_KEY_QUEST_VICTORY_EMANCIPATION_LAUNCH_EPILOGUE" and
                        showPurityProloguePopup
                    ) then
                        showProloguePopup = false;
                    -- Show supremacy first objective popup but not purity
                    elseif (
                        purityLevel == supremacyLevel and
                        objectiveEpilogue == "TXT_KEY_QUEST_VICTORY_PROMISED_LAND_LAUNCH_EPILOGUE" and
                        not showPurityProloguePopup
                    ) then
                        showProloguePopup = false;
                    end

                    local isRisingTideActive = ContentManager.IsActive("54D2B257-C591-4045-8F17-A69F033166C7", ContentType.GAMEPLAY);
                    if (questType == "QUEST_VICTORY_TRANSCENDENCE" and showObjectivePopup and isRisingTideActive) then
                        print("(Beyond Earth Eclipse) showing objective popup for victory " .. questType .. " objective " .. objective:GetSummary())

                        if (questType == "QUEST_VICTORY_TRANSCENDENCE") then
                            Events.SerialEventGameMessagePopup({
                                Type = ButtonPopupTypes.BUTTONPOPUP_QUEST_OBJECTIVE_RECEIVED_ECLIPSE,
                                Data1 = playerID,
                                Data2 = quest:GetIndex(),
                                -- This is the index of the next objective; Lua indexes
                                -- start at 1 so we have to add 2 😝
                                Data3 = objective:GetIndex() + 2
                            });
                        end
                    end

                    if (showProloguePopup and not shownVictoryQuestStrings[questPrologue]) then
                        print("(Beyond Earth Eclipse) showing prologue popup for victory " .. questType .. " objective " .. objective:GetSummary())

                        Events.SerialEventGameMessagePopup({
                            Type = ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROLOGUE,
                            Data1 = GameInfo.Quests[questType].ID,
                            Text = quest:GetPrologue()
                        });
                    end

                    -- Always add the text key to the list whether or not we show a popup
                    if (not shownVictoryQuestStrings[objectiveEpilogue]) then
                        shownVictoryQuestStrings[objectiveEpilogue] = true;
                    end
                    if (not shownVictoryQuestStrings[questPrologue]) then
                        shownVictoryQuestStrings[questPrologue] = true;
                    end

                    -- DELETEME
                    print("(Beyond Earth Eclipse) completedVictoryObjectiveIds=", "    ")
                    printTable(shownVictoryQuestStrings)
                end
            end
        end
    end
end
GameEvents.PlayerDoTurn.Add(ShowVictoryPopup);
