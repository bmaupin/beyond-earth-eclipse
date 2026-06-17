local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local SATELLITE_UNIT_TYPE			= GameInfo.Units["UNIT_LASERCOM_SATELLITE"].ID;
local GATE_PROJECT_TYPE				= GameInfo.Projects["PROJECT_PURITY_GATE"].ID;
local GATE_RESEARCH_TECH			= GameInfo.Projects[GATE_PROJECT_TYPE].TechPrereq;
local EARTHLING_SETTLER_UNIT_TYPE	= GameInfo.Units["UNIT_EARTHLING_SETTLER"].ID;
local LANDMARK_ACTION_TYPE			= GameInfo.LandmarkActions["LANDMARK_ACTION_SPAWN_EARTHLING_UNIT"].ID;
local NUM_EARTHLINGS_TO_SETTLE		= GameDefines["PROMISED_LAND_EARTHLINGS_SETTLED_REQUIREMENT"];

local Stages = {
	ContactEarth = 1,
	UnlockGate = 2,
	BuildGate = 3,
	SettleEarthlings = 4,
	End = 5,
};

----------------------------------------------------
-- Game Event Listeners
---------------------------------------------------- 
function QuestScript.OnStartGame(isLoadGame)
	if isLoadGame == false and Game.IsVictoryValid(GameInfo.Victories[QuestScript.Info.VictoryType].ID) then
		for playerType=0,GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			local player = Players[playerType];
			if (not player:IsMinorCiv() and player:IsEverAlive() and not HasPlayerDoneQuestType(playerType, QuestScript.Info.ID)) then
				-- === BEGIN MOD: Only start victory quest if the player picked a purity sponsor ===
				if player:CanEverResearch(GameInfo.Technologies["TECH_TACTICAL_LEV"].ID) then
					StartQuest(playerType, QuestScript.Type);
				end
				-- === END MOD ===
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
	quest:SetPrologue("TXT_KEY_QUEST_VICTORY_PROMISED_LAND_PROLOGUE");

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
	-- When we've built the warp gate, we need to listen for the gate's landmark action
	-- and place earthling settlers.
	function quest.OnLandmarkAction(playerType, landmarkActionType, plotIndex)
		if (landmarkActionType == LANDMARK_ACTION_TYPE) then
			if (quest:GetOwner() == playerType and quest.PersistentData.Stage == Stages.SettleEarthlings) then
				local plot = Map.GetPlotByIndex(plotIndex);
				local unit = Players[playerType]:InitUnit(EARTHLING_SETTLER_UNIT_TYPE, plot:GetX(), plot:GetY());
				local hex = ToHexFromGrid( Vector2( plot:GetX(), plot:GetY() ) );
				Events.GameplayFX( hex.x, hex.y, "WarpGate_Activation_P");

				plot:SetLandmarkActionPerformed(true);
				--unit:JumpToNearestValidPlot();
			end
		end
	end
	GameEvents.LandmarkAction.Add(quest.OnLandmarkAction);
end

function QuestScript.OnUnregisterListeners(quest)
	if(quest ~= nil and quest.OnLandmarkAction ~= nil) then
		GameEvents.LandmarkAction.Remove(quest.OnLandmarkAction);
	end
end

function QuestScript.CanDoLandmarkAction(quest, landmarkActionType, plot, testVisible)

	if (not testVisible) then

		local pPlayer = Players[quest:GetOwner()];

		local gatePlot = pPlayer:GetPurityGatePlot();
		if (gatePlot ~= nil) then
			-- If the landmark action was already performed on this plot this turn, no can do
			if (gatePlot:GetLandmarkActionPerformed() == true) then
				return false;
			end

			-- Something occupying the gate?
			if (gatePlot:GetNumUnits() > 0) then
				return false;
			end
		else
			return false;
		end
	end

	return true;
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
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_PROMISED_LAND_LAUNCH_EPILOGUE");
	elseif (stage == Stages.UnlockGate) then
		quest:SetProgress(25);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_PROMISED_LAND_VICTORY_PROGRESS_1_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_PROMISED_LAND_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		local techType = GameInfo.Technologies[GATE_RESEARCH_TECH].ID;
		local objective = AddObjective(quest, "QUEST_OBJECTIVE_RESEARCH_TECH", techType);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_PROMISED_LAND_TECH_EPILOGUE");
	elseif (stage == Stages.BuildGate) then
		quest:SetProgress(50);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_PROMISED_LAND_VICTORY_PROGRESS_2_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_PROMISED_LAND_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		-- Enable the Purity Gate project
		local team = Teams[player:GetTeam()];
		team:SetQuestProjectAllowed(GATE_PROJECT_TYPE, true);

		local objective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_PROJECT", GATE_PROJECT_TYPE);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_PROMISED_LAND_PROJECT_EPILOGUE");
	elseif (stage == Stages.SettleEarthlings) then
		quest:SetProgress(75);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_PROMISED_LAND_VICTORY_PROGRESS_3_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_PROMISED_LAND_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		-- play Victory Imminent music event
		Game.PlayMusicEvent(quest:GetOwner(), GameDefines["MUSIC_EVENT_VICTORY_IMMINENT"]);

		local objective = AddObjective(quest, "QUEST_OBJECTIVE_SETTLE_EARTHLINGS", NUM_EARTHLINGS_TO_SETTLE);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_PROMISED_LAND_SETTLE_EPILOGUE");
	elseif (stage == Stages.End) then
		quest:SetProgress(100);
		quest:SetReward("TXT_KEY_QUEST_VICTORY_PROMISED_LAND_REWARD");
		quest:Succeed();
	else
		error("Promised Land Victory: Invalid quest stage.");
	end
end

return QuestScript;