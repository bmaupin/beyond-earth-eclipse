-- Track which victory quest strings we've shown by storing the text key for each one.
-- This includes the objective epilogue strings and the quest prologue strings.
local shownVictoryQuestStrings = {}

function PopulateCompletedVictoryObjectives()
    for playerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local player = Players[playerID];

        if player:IsHuman() and player:IsAlive() then
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
        end
    end
end
-- Run this once when the game is first started/loaded
Events.SequenceGameInitComplete.Add(PopulateCompletedVictoryObjectives);

function ShowVictoryObjectivePopup(playerID)
    local player = Players[playerID];
    if not player:IsHuman() or not player:IsAlive() then
        return;
    end

    local quests = player:GetQuests()
    for _, quest in ipairs(quests) do
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
            local objectives = quest:GetObjectives()
            for _, objective in ipairs(objectives) do
                local objectiveEpilogue = objective:GetEpilogue()

                if ((not objective:IsInProgress()) and
                    objective:DidSucceed() and
                    not shownVictoryQuestStrings[objectiveEpilogue]
                ) then
                    local showObjectivePopup = false;

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

                    -- Always add the text key to the list whether or not we show a popup
                    if (not shownVictoryQuestStrings[objectiveEpilogue]) then
                        shownVictoryQuestStrings[objectiveEpilogue] = true;
                    end
                end
            end
        end
    end
end
GameEvents.PlayerDoTurn.Add(ShowVictoryObjectivePopup);

-- TODO: Uncomment if we ever decide to show victory prologue popups
-- function ShowVictoryProloguePopup(playerID, questType)
--     -- DELETEME
--     print("(Beyond Earth Eclipse) ShowVictoryProloguePopup()")

--     local player = Players[playerID];
--     if not player:IsHuman() or not player:IsAlive() then
--         return;
--     end

--     print("(Beyond Earth Eclipse) ShowVictoryProloguePopup() playerID=", playerID)
--     print("(Beyond Earth Eclipse) ShowVictoryProloguePopup() questType=", questType)

--     local purityLevel = player:GetAffinityLevel(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID);
--     local harmonyLevel = player:GetAffinityLevel(GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID);
--     local supremacyLevel = player:GetAffinityLevel(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID);

--     -- Only show the harmony victory prologue if that's the player's highest affinity (or
--     -- tied)
--     if (
--         questType == "QUEST_VICTORY_TRANSCENDENCE" and
--         (
--             harmonyLevel < purityLevel or
--             harmonyLevel < supremacyLevel
--         )
--     ) then
--         return;
--     end

--     -- Emancipation and promised land victories share the first objective so we have to
--     -- handle them together
--     if (
--         questType == "QUEST_VICTORY_EMANCIPATION" or
--         questType == "QUEST_VICTORY_PROMISED_LAND"
--     ) then
--         -- Make sure one or the other are higher than or tied with harmony affinity level
--         if (
--             purityLevel < harmonyLevel or
--             supremacyLevel < harmonyLevel
--         ) then
--             return;
--         end

--         if (purityLevel > supremacyLevel) then
--             questType = "QUEST_VICTORY_PROMISED_LAND";
--         elseif (supremacyLevel > purityLevel) then
--             questType = "QUEST_VICTORY_EMANCIPATION";
--         elseif (purityLevel == supremacyLevel) then
--             -- If the player has a tied purity and supremacy level, pick one of them
--             -- randomly to show
--             local showPurityProloguePopup = math.random() < 0.5;
--             if showPurityProloguePopup then
--                 questType = "QUEST_VICTORY_PROMISED_LAND";
--             else
--                 questType = "QUEST_VICTORY_EMANCIPATION";
--             end
--         end
--     end

--     local quest = player:GetQuest(GameInfo.Quests[questType].ID);
--     if not quest then return end

--     -- This is just a minimal sanity check that should hopefully fail if the victory
--     -- objectives have been modified by another mod to avoid potential compatibility issues
--     local objectives = quest:GetObjectives();
--     local objectiveEpilogue = objectives[1]:GetEpilogue();
--     if (
--         objectiveEpilogue ~= nil and
--         (
--             objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_TRANS_EPILOGUE" or
--             objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_SWARM_EPILOGUE" or
--             objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_NANO_EPILOGUE" or
--             objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_PROMISED_LAND_LAUNCH_EPILOGUE" or
--             objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_EMANCIPATION_LAUNCH_EPILOGUE" or
--             objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_CONTACT_SIGNAL_EPILOGUE"
--         )
--     ) then
--         return
--     end

--     local questPrologue = quest:GetPrologue();
--     print("(Beyond Earth Eclipse) questPrologue = " .. questPrologue)

--     if (not shownVictoryQuestStrings[questPrologue]) then
--         print("(Beyond Earth Eclipse) showing prologue popup for victory " .. questType)

--         Events.SerialEventGameMessagePopup({
--             Type = ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROLOGUE,
--             Data1 = GameInfo.Quests[questType].ID,
--             Text = quest:GetPrologue()
--         });

--         shownVictoryQuestStrings[questPrologue] = true;
--     end
-- end

-- function OnTechResearched(teamType, techType, _change)
--     local activePlayer
--     if Game.GetActivePlayer() ~= nil then
--         activePlayer = Players[Game.GetActivePlayer()]
--     else
--         activePlayer = Players[0]
--     end

--     if not activePlayer:IsHuman() or not activePlayer:IsAlive() then
--         return;
--     end

--     if activePlayer:GetTeam() == teamType and activePlayer:IsHuman() then
--         if (techType == GameInfo.Technologies["TECH_TRANSGENICS"].ID or
--             techType == GameInfo.Technologies["TECH_SWARM_INTELLIGENCE"].ID or
--             techType == GameInfo.Technologies["TECH_NANOROBOTICS"].ID) then
--             ShowVictoryProloguePopup(activePlayer:GetID(), "QUEST_VICTORY_TRANSCENDENCE")
--         end
--     end
-- end
-- GameEvents.TeamTechResearched.Add(OnTechResearched)

-- function OnOrbitalUnitLaunched(playerID, unitType, _plotX, _plotY)
--     print("(Beyond Earth Eclipse) OnOrbitalUnitLaunched()")

--     local player = Players[playerID];
--     if not player:IsHuman() or not player:IsAlive() then
--         return;
--     end

--     if (unitType == GameInfo.Units["UNIT_DEEP_SPACE_TELESCOPE"].ID) then
--         ShowVictoryProloguePopup(playerID, "QUEST_VICTORY_CONTACT")
--     elseif (unitType == GameInfo.Units["UNIT_LASERCOM_SATELLITE"].ID) then
--         -- This satellite is for both the emancipation and promised land victories;
--         -- ShowVictoryProloguePopup has logic to decide which one to show
--         ShowVictoryProloguePopup(playerID, "QUEST_VICTORY_EMANCIPATION")
--     end
-- end
-- GameEvents.OrbitalUnitLaunched.Add(OnOrbitalUnitLaunched);

-- -- Possibly show domination victory prologue
-- local function OnCityCaptureComplete(cityX, cityY)
--     local plot = Map.GetPlot(cityX, cityY)
--     if not plot then return end

--     local city = plot:GetPlotCity()
--     if not city or not city:IsOriginalMajorCapital() then return end

--     local newOwnerID = city:GetOwner()
--     local player = Players[newOwnerID]
--     if not player:IsHuman() or not player:IsAlive() then
--         return;
--     end

--     local team = Teams[player:GetTeam()]
--     local numCapturedCapitals = team:CountNumCapturedCapitals()

--     print("(Beyond Earth Eclipse) numCapturedCapitals= ", numCapturedCapitals)

--     if (numCapturedCapitals > 1) then
--         ShowVictoryProloguePopup(newOwnerID, "QUEST_VICTORY_DOMINATION")
--     end
-- end
-- GameEvents.CityCaptureComplete.Add(OnCityCaptureComplete)
