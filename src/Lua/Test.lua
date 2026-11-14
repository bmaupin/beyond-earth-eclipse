------------------------------------------------------------------------------------------
-- Test code; copy to Victories.lua or another lua script to use as needed
------------------------------------------------------------------------------------------



-- Give players free affinity levels
function GiveFreeAffinities()
    local affinityLevel6 = 75;
    local affinityLevel11 = 165;
    local affinityLevelToSet = affinityLevel6;

    for playerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local player = Players[playerID];

        -- Apply the logic to human and computer players alike
        if player:IsMajorCiv() and player:IsAlive() then
            local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type
            if civType == "CIVILIZATION_ARC" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_AFRICAN_UNION" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_BRASILIA" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_PAN_ASIA" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_FRANCO_IBERIA" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_KAVITHAN" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_POLYSTRALIA" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_RUSSIA" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_AL_FALAH" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_NORTH_SEA_ALLIANCE" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_INTEGR" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID, affinityLevelToSet);
            elseif civType == "CIVILIZATION_CHUNGSU" then
                player:ChangeAffinityScore(GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID, affinityLevelToSet);
            end
        end
    end
end
-- Run this once at the start of the game or when the game is loaded
Events.SequenceGameInitComplete.Add(GiveFreeAffinities);



local function AutoPlay()
    GameEvents.PlayerCityFounded.Remove(AutoPlay);

    -- local function CheckAutoPlay()
    --     local player = Players[1];
    --     for affinityInfo in GameInfo.Affinity_Types() do
    --         local affinityLevel = player:GetAffinityLevel(affinityInfo.ID);
    --         print("********************* Affinity: " .. tostring(affinityInfo.Type) .. " level: " .. tostring(affinityLevel));
    --         if affinityLevel >= 6 then
    --         -- if affinityLevel >= 11 then
    --             if Game.GetAIAutoPlay() > 0 then
    --                 Game.SetAIAutoPlay(1, 0);
    --             end
    --         end
    --     end
    -- end
    -- GameEvents.PlayerDoTurn.Add(CheckAutoPlay);

    -- First parameter is number of turns to autoplay, second is player to return control to (or -1 for none)
    Game.SetAIAutoPlay(300, 0);
end
GameEvents.PlayerCityFounded.Add(AutoPlay);
