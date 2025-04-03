function ShowPopup(victoryType, textKey)
    Events.SerialEventGameMessagePopup( {
        Type = ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS,
        Data1 = GameInfo.Quests[victoryType].ID,
        Text = textKey
    } );

    -- ButtonPopupTypes.BUTTONPOPUP_QUEST_LOG
    -- ButtonPopupTypes.BUTTONPOPUP_QUEST_OBJECTIVE_RECEIVED
end

function OnTechResearched(teamType, techType, change)
    print("(Beyond Earth Eclipse) OnTechResearched")

    local activePlayer
    if Game.GetActivePlayer() ~= nil then
        activePlayer = Players[Game.GetActivePlayer()]
    else
        activePlayer = Players[0]
    end
    if activePlayer:GetTeam() == teamType and activePlayer:IsHuman() then
        if techType == GameInfo.Technologies["TECH_TRANSGENICS"].ID then
            print("(Beyond Earth Eclipse) showing popup for transgenics")
            ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_TRANS_EPILOGUE")
        elseif techType == GameInfo.Technologies["TECH_SWARM_INTELLIGENCE"].ID then
            ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_SWARM_EPILOGUE")
        elseif techType == GameInfo.Technologies["TECH_NANOROBOTICS"].ID then
            ShowPopup("QUEST_VICTORY_TRANSCENDENCE", "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_NANO_EPILOGUE")
        end
    end
end

GameEvents.TeamTechResearched.Add(OnTechResearched)
