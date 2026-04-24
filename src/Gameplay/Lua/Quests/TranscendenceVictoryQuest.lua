local QuestScript = hmake CvQuestScript{};

----------------------------------------------------
-- Constants
---------------------------------------------------- 
local FIRST_TECH_TYPE			= GameInfo.Technologies["TECH_TRANSGENICS"].ID;
local SECOND_TECH_TYPE			= GameInfo.Technologies["TECH_SWARM_INTELLIGENCE"].ID;
local THIRD_TECH_TYPE			= GameInfo.Technologies["TECH_NANOROBOTICS"].ID;
local MIND_FLOWER_PROJECT_TYPE	= GameInfo.Projects["PROJECT_MIND_FLOWER"].ID;
local AWAKEN_BASE_DURATION		= GameDefines.TRANSCENDENCE_VICTORY_BASE_DURATION;
local AWAKEN_BUILDING_BONUS		= GameDefines.TRANSCENDENCE_VICTORY_AWAKEN_BUILDING_BONUS;

local BuildingsToSpeedAwakening = {
	GameInfo.Buildings["BUILDING_XENO_SANCTUARY"].ID,
	GameInfo.Buildings["BUILDING_MIND_STEM"].ID,
};

local Stages = {
	RevealPlanetMind = 1,
	BuildMindFlower = 2,
	AwakenPlanet = 3,
	End = 4,
};

----------------------------------------------------
-- Game Event Listeners
---------------------------------------------------- 
function QuestScript.OnStartGame(isLoadGame)
	if isLoadGame == false and Game.IsVictoryValid(GameInfo.Victories[QuestScript.Info.VictoryType].ID) then
		for playerType=0,GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			local player = Players[playerType];
			if (not player:IsMinorCiv() and player:IsEverAlive() and not HasPlayerDoneQuestType(playerType, QuestScript.Info.ID)) then
				-- === BEGIN MOD: Only start victory quest if the player picked a harmony sponsor ===
				if player:CanEverResearch(GameInfo.Technologies["TECH_ALIEN_EVOLUTION"].ID) then
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
	quest:SetPrologue("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_PROLOGUE");

	-- Set persistent data
	local player = Players[quest:GetOwner()];
	quest.PersistentData.Stage = Stages.RevealPlanetMind;
	quest.PersistentData.FinishedFirstTech = false;
	quest.PersistentData.FinishedSecondTech = false;
	quest.PersistentData.FinishedThirdTech = false;
	quest.PersistentData.StartedResearchingTechs = false;
	QuestScript.DoStage(quest);
end

function QuestScript.OnObjectiveComplete(quest, objective)
	if (quest.PersistentData.Stage == Stages.RevealPlanetMind and objective:GetType() == GameInfo.QuestObjectives["QUEST_OBJECTIVE_RESEARCH_TECH"].ID) then
		if (objective.PersistentData.TechType == FIRST_TECH_TYPE) then
			quest.PersistentData.FinishedFirstTech = true;
		elseif (objective.PersistentData.TechType == SECOND_TECH_TYPE) then
			quest.PersistentData.FinishedSecondTech = true;
		elseif (objective.PersistentData.TechType == THIRD_TECH_TYPE) then
			quest.PersistentData.FinishedThirdTech = true;
		end
	end
	
	QuestScript.DoStage(quest);
end

function QuestScript.OnRegisterListeners(quest)

	-- Certain buildings can speed up the "awaken" process.
	function quest.OnBuildingProcessed(playerType, buildingType)
		if (quest:GetOwner() == playerType and quest.PersistentData.Stage == Stages.AwakenPlanet) then

			local waitObjectiveType = GameInfo.QuestObjectives["QUEST_OBJECTIVE_WAIT"].ID;
			local objective = quest:GetObjectiveWithIndex(quest.PersistentData.WaitObjectiveIndex);

			if objective ~= nil and objective:GetType() == waitObjectiveType then
				for i,bonusBuildingType in ipairs(BuildingsToSpeedAwakening) do

					if (buildingType == bonusBuildingType) then
						
						local objectiveScript = GetObjectiveScript(waitObjectiveType);
						if objectiveScript ~= nil then
							
							local wrapper = GetObjectiveWrapper(objective);
							objectiveScript.ChangeTime(wrapper, -AWAKEN_BUILDING_BONUS);
							return;
						end
					end
				end
			end
		end 
	end
	GameEvents.BuildingProcessed.Add(quest.OnBuildingProcessed);
end

function QuestScript.OnUnregisterListeners(quest)
	if(quest ~= nil and quest.OnBuildingProcessed ~= nil) then
		GameEvents.BuildingProcessed.Remove(quest.OnBuildingProcessed);
	end
end

----------------------------------------------------
-- Quest-specific functions
---------------------------------------------------- 
function QuestScript.DoStage(quest)
	local player = Players[quest:GetOwner()];
	if (player == nil) then
		error("Invalid player");
	end
	
	local team = Teams[player:GetTeam()];
	if (team == nil) then
		error("Invalid team");
	end

	if (quest.PersistentData.Stage == Stages.RevealPlanetMind) then
		if (quest.PersistentData.FinishedFirstTech == true and
			quest.PersistentData.FinishedSecondTech == true and
			quest.PersistentData.FinishedThirdTech == true) 
		then
			-- Turn on the Mind Flower project
			team:SetQuestProjectAllowed(MIND_FLOWER_PROJECT_TYPE, true);
			quest.PersistentData.Stage = quest.PersistentData.Stage + 1;
		end
	else
		quest.PersistentData.Stage = quest.PersistentData.Stage + 1;
	end

	if (quest.PersistentData.Stage == Stages.RevealPlanetMind) then
		if (quest.PersistentData.StartedResearchingTechs == false) then

			quest.PersistentData.StartedResearchingTechs = true;
			quest:SetProgress(0);
			local objective;
			objective = AddObjective(quest, "QUEST_OBJECTIVE_RESEARCH_TECH", FIRST_TECH_TYPE);
			objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_TRANS_EPILOGUE");
			objective = AddObjective(quest, "QUEST_OBJECTIVE_RESEARCH_TECH", SECOND_TECH_TYPE);
			objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_SWARM_EPILOGUE");
			objective = AddObjective(quest, "QUEST_OBJECTIVE_RESEARCH_TECH", THIRD_TECH_TYPE);
			objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_NANO_EPILOGUE");
		end
	elseif (quest.PersistentData.Stage == Stages.BuildMindFlower) then
		quest:SetProgress(50);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(), 
			Locale.Lookup("TXT_KEY_TRANSCENDENCE_VICTORY_PROGRESS_1_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_TRANSCENDENCE_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		local objective = AddObjective(quest, "QUEST_OBJECTIVE_BUILD_PROJECT", MIND_FLOWER_PROJECT_TYPE);
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_MIND_EPILOGUE");
	elseif (quest.PersistentData.Stage == Stages.AwakenPlanet) then
		quest:SetProgress(75);

		-- Send notification
		BroadcastVictoryProgressNotification(
			quest:GetOwner(),
			Locale.Lookup("TXT_KEY_TRANSCENDENCE_VICTORY_PROGRESS_2_MESSAGE", player:GetNameKey()), 
			Locale.Lookup("TXT_KEY_TRANSCENDENCE_VICTORY_PROGRESS_SUMMARY", player:GetNameKey()), 
			-1, -1);

		-- play Victory Imminent music event
		Game.PlayMusicEvent(quest:GetOwner(), GameDefines["MUSIC_EVENT_VICTORY_IMMINENT"]);

		-- Do alien response
		--for iPlayer=0,GameDefines.MAX_MAJOR_CIVS - 1, 1 do
		--end
		Aliens.SetOpinionForPlayer(quest:GetOwner(), AIAlienOpinionTypes.ALIEN_OPINION_VERY_HOSTILE);

		-- Compute duration based on data and game speed
		local duration = math.floor((AWAKEN_BASE_DURATION * Game:GetVictoryDurationMod()) / 100);

		-- Do immediate reduction for any pre-existing time-reducing buildings
		for i,buildingID in ipairs(BuildingsToSpeedAwakening) do
			local numBuildings = player:CountNumBuildings(buildingID);
			if (numBuildings ~= nil and numBuildings > 0) then
				
				 duration = duration - (AWAKEN_BUILDING_BONUS * numBuildings);
			end
		end
		
		-- duration must be at least 1, no matter how many buildings the player has already
		duration = math.max(duration, 1);

		local objective = AddObjective(quest, "QUEST_OBJECTIVE_OPERATE_MIND_FLOWER", duration, "TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_WAIT_SUMMARY");
		objective:SetEpilogue("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_WAIT_EPILOGUE");
		quest.PersistentData.WaitObjectiveIndex = objective:GetIndex();		

	elseif (quest.PersistentData.Stage == Stages.End) then

		quest:SetProgress(100);
		quest:SetReward("TXT_KEY_QUEST_VICTORY_TRANSCENDENCE_REWARD");
		quest:Succeed();
	else

		error("Transcendence Victory: Invalid quest stage.");
	end
end

return QuestScript;