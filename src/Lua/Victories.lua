function ShowVictoryProloguePopup(playerID, questType)
    -- DELETEME
    print("(Beyond Earth Eclipse) ShowVictoryProloguePopup()")

    local player = Players[playerID];
    if not player:IsHuman() or not player:IsAlive() then
        return;
    end

    print("(Beyond Earth Eclipse) ShowVictoryProloguePopup() playerID=", playerID)
    print("(Beyond Earth Eclipse) ShowVictoryProloguePopup() questType=", questType)

    local quest = player:GetQuest(GameInfo.Quests[questType].ID);
    if not quest then return end

    -- This is just a minimal sanity check that should hopefully fail if the victory
    -- objectives have been modified by another mod to avoid potential compatibility issues
    local objectives = quest:GetObjectives();
    local objectiveEpilogue = objectives[1]:GetEpilogue();
    if (
        objectiveEpilogue ~= nil and
        (
            objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_TRANS_EPILOGUE" and
            objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_SWARM_EPILOGUE" and
            objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_NANO_EPILOGUE" and
            objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_PROMISED_LAND_LAUNCH_EPILOGUE" and
            objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_EMANCIPATION_LAUNCH_EPILOGUE" and
            objectiveEpilogue ~= "TXT_KEY_QUEST_VICTORY_CONTACT_SIGNAL_EPILOGUE"
        )
    ) then
        return;
    end

    local questPrologue = quest:GetPrologue();
    print("(Beyond Earth Eclipse) questPrologue = " .. questPrologue)

    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROLOGUE,
        Data1 = GameInfo.Quests[questType].ID,
        Text = quest:GetPrologue()
    });
end

function TriggerVictoryProloguePopup(playerID)
    -- Use hard-coded turn number to trigger victory prologue popup, because unlike the
    -- other victory objectives, the first objective is in progress from the beginning of
    -- the game so we can't use that to trigger it
    -- TODO: Tweak this as needed
    if Game.GetGameTurn() ~= 25 then
        return;
    end

    local player = Players[playerID];
    if not player:IsHuman() or not player:IsAlive() then
        return;
    end

    -- Use the tech required to research each affinity's highest affinity unit
    -- Harmony
    if player:CanEverResearch(GameInfo.Technologies["TECH_ALIEN_EVOLUTION"].ID) then
        ShowVictoryProloguePopup(playerID, "QUEST_VICTORY_TRANSCENDENCE");
    -- Purity
    elseif player:CanEverResearch(GameInfo.Technologies["TECH_TACTICAL_LEV"].ID) then
        ShowVictoryProloguePopup(playerID, "QUEST_VICTORY_PROMISED_LAND");
    -- Supremacy
    elseif player:CanEverResearch(GameInfo.Technologies["TECH_NEURAL_UPLOADING"].ID) then
        ShowVictoryProloguePopup(playerID, "QUEST_VICTORY_EMANCIPATION");
    end
end
GameEvents.PlayerDoTurn.Add(TriggerVictoryProloguePopup);

-- -- TODO: Uncomment if we decide to show the contact victory prologue popup
-- function OnOrbitalUnitLaunched(playerID, unitType, _plotX, _plotY)
--     print("(Beyond Earth Eclipse) OnOrbitalUnitLaunched()")

--     local player = Players[playerID];
--     if not player:IsHuman() or not player:IsAlive() then
--         return;
--     end

--     if (unitType == GameInfo.Units["UNIT_DEEP_SPACE_TELESCOPE"].ID) then
--         ShowVictoryProloguePopup(playerID, "QUEST_VICTORY_CONTACT")
--     end
-- end
-- GameEvents.OrbitalUnitLaunched.Add(OnOrbitalUnitLaunched);

-- -- TODO: Uncomment if we decide to show domination victory prologue
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


-- -- NOTE: autoplay has some quirks
-- --       - all affinity techs are hidden in tech web, not just techs for other affinities
-- --       - in-progress research isn't shown (normally it's shown in the top left)
-- local function AutoPlay()
--     -- First parameter is number of turns to autoplay, second is player to return control to (or -1 for none)
--     Game.SetAIAutoPlay(300, 0);
-- end
-- Events.SequenceGameInitComplete.Add(AutoPlay);

-- local function MaybeStopAutoplay(playerID)
--     -- Only run the check once per turn
--     if playerID == 0 then
--         local player = Players[playerID];

--         -- Test transcendence victory popup. To use:
--         --
--         -- - Set autoplay to a high value (at least 300)
--         -- - In game setup, use the smallest map, turn off all victories except transcendence, enable Always peace, select non-harmony AI players
--         --
--         -- Stop after player has transcendence victory stage 1; we can go back and load previous save to test victory popup
--         if (player:HasTech(GameInfo.Technologies["TECH_NANOROBOTICS"].ID) and
--             player:HasTech(GameInfo.Technologies["TECH_SWARM_INTELLIGENCE"].ID) and
--             player:HasTech(GameInfo.Technologies["TECH_TRANSGENICS"].ID)
--         ) then
--             if Game.GetAIAutoPlay() > 0 then
--                 print("***************************** (Beyond Earth Eclipse) stopping autoplay");
--                 Game.SetAIAutoPlay(1, 0);
--             end
--         end
--     end
-- end
-- GameEvents.PlayerDoTurn.Add(MaybeStopAutoplay);
