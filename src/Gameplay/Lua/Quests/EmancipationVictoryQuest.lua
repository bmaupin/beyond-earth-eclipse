local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local SATELLITE_UNIT_TYPE		= GameInfo.Units["UNIT_LASERCOM_SATELLITE"].ID;
local GATE_PROJECT_TYPE			= GameInfo.Projects["PROJECT_SUPREMACY_GATE"].ID;
local GATE_RESEARCH_TECH		= GameInfo.Projects[GATE_PROJECT_TYPE].TechPrereq;
local LANDMARK_ACTION_TYPE		= GameInfo.LandmarkActions["LANDMARK_ACTION_WARP_GATE_CONSUME_UNIT"].ID;
local STRENGTH_TO_COMMIT		= GameDefines["EMANCIPATION_VICTORY_STRENGTH_REQUIREMENT"];

local Stages = {
	ContactEarth = 1,
	UnlockGate = 2,
	BuildGate = 3,
	SendMilitary = 4,
	End = 5,
};

----------------------------------------------------
-- Game Event Listeners
---------------------------------------------------- 
function QuestScript.OnStartGame(isLoadGame)
	if isLoadGame == false and Game.IsVictoryValid(GameInfo.Victories[QuestScript.Info.VictoryType].ID) then
		-- Since this is a victory quest, loop over each player 
		-- and start the quest
		for playerType=0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			local player = Players[playerType];
			if (not player:IsMinorCiv() and player:IsEverAlive() and not HasPlayerDoneQuestType(playerType, QuestScript.Info.ID)) then
				StartQuest(playerType, QuestScript.Type);
			end
		end
	end
end
Events.SerialEventGameInitFinished.Add(QuestScript.OnStartGame);

----------------------------------------------------
-- Callbacks
---------------------------------------------------- 
function QuestScript.OnStart(quest)
	-- Set the prologue
	quest:SetPrologue("TXT_KEY_QUEST_VICTORY_EMANCIPATION_PROLOGUE");

	-- Set stage
	quest.PersistentData.Stage = Stages.ContactEarth;
	QuestScript.DoStage(quest);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	-- Since we've only got one objective per stage, we can be kind of
	-- dumb about this...
	quest.PersistentData.Stage = quest.PersistentData.Stage + 1;
	QuestScript.DoStage(quest);
end

function QuestScript.OnRegisterListeners(quest)
end

function QuestScript.OnUnregisterListeners(quest)
end

function FindValidWarpGateUnit(quest, plot)
	if (plot ~= nil) then
		-- If we have no unit on the tile, return false
		local numUnits = plot:GetNumUnits();
		if (numUnits == 0) then
			return nil;
		else
			-- If we have a military unit on the tile, we're good to go.
			for i=0, numUnits - 1, 1 do
				local unit = plot:GetUnit(i);
				if (QuestScript.IsUnitValidForWarpGate(quest, unit)) then
					return unit;
				end
			end
		end
	else
		return nil;
	end
end

function QuestScript.CanDoLandmarkAction(quest, landmarkActionType, plot, testVisible)
	if (not testVisible) then
		local player = Players[quest:GetOwner()];

		-- If the landmark action was already performed on this plot, no can do
		if (plot:GetLandmarkActionPerformed() == true) then
			return false;
		end

		local unit = FindValidWarpGateUnit(quest, plot);
		local selectedUnit = nil;
		if (player:IsHuman()) then
			selectedUnit = plot:GetSelectedUnit();
			if (selectedUnit ~= nil) then
				unit = selectedUnit;
			end
		end

		if (QuestScript.IsUnitValidForWarpGate(quest, unit)) then
			return true;
		end

		return false;
	end

	return true;
end

function QuestScript.IsUnitValidForWarpGate(quest, unit)
	return (unit ~= nil and
			unit:GetTeam() == Players[quest:GetOwner()]:GetTeam() and
			not unit:IsInOrbit() and
			(unit:GetCombatStrength() > 0 or unit:GetRangedCombatStrength() > 0));
end

----------------------------------------------------
-- Quest-specific functions
---------------------------------------------------- 
function QuestScript.DoStage(quest)
	local stage = quest.PersistentData.Stage;
	local player = Players[quest:GetOwner()];
	if (player == nil) then
		error("Invalid player");
	end

	if (stage == Stages.ContactEarth) then
		quest:SetProgress(0);
		local objective = AddObjective(quest, "QUEST_OBJECTIVE_LAUNCH_SATELLITES", SATELLITE_UNIT_TYPE, 1);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_EMANCIPATION_LAUNCH_EPILOGUE");
	elseif (stage == Stages.UnlockGate) then
		quest:SetProgress(25);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_EMANCIPATION_VICTORY_PROGRESS_1_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_EMANCIPATION_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		local techType = GameInfo.Technologies[GATE_RESEARCH_TECH].ID;
		local objective = AddObjective(quest, "QUEST_OBJECTIVE_RESEARCH_TECH", techType);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_EMANCIPATION_TECH_EPILOGUE");
	elseif (stage == Stages.BuildGate) then
		quest:SetProgress(50);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_EMANCIPATION_VICTORY_PROGRESS_2_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_EMANCIPATION_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		-- Enable the Supremacy Gate project
		local team = Teams[player:GetTeam()];
		team:SetQuestProjectAllowed(GATE_PROJECT_TYPE, true);

		local objective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_PROJECT", GATE_PROJECT_TYPE);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_EMANCIPATION_PROJECT_EPILOGUE");
	elseif (stage == Stages.SendMilitary) then
		quest:SetProgress(75);
			
		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_EMANCIPATION_VICTORY_PROGRESS_3_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_EMANCIPATION_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		-- play Victory Imminent music event
		Game.PlayMusicEvent(quest:GetOwner(), GameDefines["MUSIC_EVENT_VICTORY_IMMINENT"]);

		local objective = AddObjective(quest, "QUEST_OBJECTIVE_COMMIT_UNITS_TO_GATE", LANDMARK_ACTION_TYPE, STRENGTH_TO_COMMIT);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_EMANCIPATION_COMMIT_EPILOGUE");
	elseif (stage == Stages.End) then
		quest:SetProgress(100);
		quest:SetReward("TXT_KEY_QUEST_VICTORY_EMANCIPATION_REWARD");
		quest:Succeed();
	else
		error("Emancipation Victory: Invalid quest stage.");
	end
end

return QuestScript;