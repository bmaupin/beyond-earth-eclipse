include("DiplomacyAI");

-- Table of AIFact keys to function handlers, filled out in this file as each function is declared (below)
local g_DefaultHandlersTable : table = {};

local HARMONY_AFFINITY_TYPE : number = GameInfo.Affinity_Types["AFFINITY_TYPE_HARMONY"].ID;
local PURITY_AFFINITY_TYPE : number = GameInfo.Affinity_Types["AFFINITY_TYPE_PURITY"].ID;
local SUPREMACY_AFFINITY_TYPE : number = GameInfo.Affinity_Types["AFFINITY_TYPE_SUPREMACY"].ID;

--	===============================================================================

-- Associate fact handlers for all the "default" facts that every character trait should handle
--	These can be overridden by the specific trait script if the character needs special handling
function RegisterDefaultReactionHandlers(traitScript : CvPersonalityTraitScript)

	if (traitScript == nil or traitScript.FactHandlers == nil) then
		return;
	end

	-- Don't register reaction handlers for human players
	if (Players[traitScript.Owner]:IsHuman()) then
		return;
	end

	for factType, handler in pairs(g_DefaultHandlersTable) do
		traitScript.FactHandlers[GameInfo.AIFacts[factType].ID] = function(playerType : number, factType : number, factID : number, wasAdded : boolean)
			handler(traitScript, playerType, factType, factID, wasAdded);
		end;	
	end
end

--	===============================================================================
--	DEFAULT REACTION HANDLERS
--	===============================================================================
local OUTPOST_ALARM_DIST : number = 10;

-----------------------------------------------------------------------------------
-- Outpost Founded
function DefaultHandler_OutpostFounded(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end

	local sourcePlayerType : number = fact:GetPlayerSource();

	if (traitScript.Owner ~= sourcePlayerType) then
		local traitPlayer : object = Players[traitScript.Owner];		
		local sourcePlayer : object = Players[sourcePlayerType];
		
		-- Ignore facts involving non-Civ players
		if (not traitPlayer:IsMajorCiv() or not sourcePlayer:IsMajorCiv()) then
			return;
		end
		
		-- If the outpost is too close, we do not like it
		local factX : number = fact:GetPlotX();
		local factY : number = fact:GetPlotY();

		for city : object in traitPlayer:Cities() do
			local dist : number = Map.PlotDistance(city:GetX(), city:GetY(), factX, factY);
			if (dist <= OUTPOST_ALARM_DIST) then

				local reactionInfo : table = GameInfo.Reactions["REACTION_OUTPOST_FOUNDED_DISLIKE"];
				if (reactionInfo ~= nil) then						
					traitPlayer:SendReaction(reactionInfo.ID, sourcePlayerType);
					break;
				end
			end
		end		
	end
end
g_DefaultHandlersTable["AIFACT_OUTPOST_FOUNDED"] = DefaultHandler_OutpostFounded;

-----------------------------------------------------------------------------------
-- Wonder Built
function DefaultHandler_BuiltWonder(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end

	local sourcePlayerType : number = fact:GetPlayerSource();
	if (sourcePlayerType ~= traitScript.Owner) then

		local traitPlayer : object = Players[traitScript.Owner];
		local sourcePlayer : object = Players[sourcePlayerType];

		-- Ignore facts involving non-Civ players
		if (not traitPlayer:IsMajorCiv() or not sourcePlayer:IsMajorCiv()) then
			return;
		end
		
		local wonderType : number = fact:GetSourceInfoType();
		if (wonderType == -1) then
			return;
		end
		local buildingInfo : table = GameInfo.Buildings[wonderType];
		if (buildingInfo ~= nil) then

			-- If we own the tech that unlocks this wonder, we don't like it
			local prereqTechInfo : table = GameInfo.Technologies[buildingInfo.PrereqTech];
			if (prereqTechInfo ~= nil) then
				if (traitPlayer:HasTech(prereqTechInfo.ID)) then
					local reactionInfo : table = GameInfo.Reactions["REACTION_BUILT_WONDER_DISLIKE"];
					if (reactionInfo ~= nil) then						
						traitPlayer:SendReaction(reactionInfo.ID, sourcePlayerType);
					end
				-- Otherwise we do like it
				else
					local reactionInfo : table = GameInfo.Reactions["REACTION_BUILT_WONDER_LIKE"];
					if (reactionInfo ~= nil) then						
						traitPlayer:SendReaction(reactionInfo.ID, sourcePlayerType);
					end
				end
			end
		end
	end
end
g_DefaultHandlersTable["AIFACT_BUILT_WONDER"] = DefaultHandler_BuiltWonder;

-----------------------------------------------------------------------------------
-- Unit Killed
function DefaultHandler_UnitKilled(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
			
	local sourcePlayerType : number = fact:GetPlayerSource();
	local destPlayerType : number = fact:GetPlayerDest();

	-- They attacked and killed our unit
	if (destPlayerType == traitScript.Owner) then
		local reactionInfo : table = GameInfo.Reactions["REACTION_YOUR_UNIT_KILLED_MINE"];
		if (reactionInfo ~= nil) then						
			Players[traitScript.Owner]:SendReaction(reactionInfo.ID, sourcePlayerType);
		end
	
	-- We attacked and killed their unit
	elseif (sourcePlayerType == traitScript.Owner) then

		local sourcePlayer : object = Players[sourcePlayerType];
		local destPlayer : object = Players[destPlayerType];

		-- Ignore facts involving non-Civ players
		if (not sourcePlayer:IsMajorCiv() or not destPlayer:IsMajorCiv()) then
			return;
		end

		local reactionInfo : table = GameInfo.Reactions["REACTION_MY_UNIT_KILLED_YOURS"];
		if (reactionInfo ~= nil) then						
			Players[traitScript.Owner]:SendReaction(reactionInfo.ID, destPlayerType);
		end
	end
end
g_DefaultHandlersTable["AIFACT_UNIT_KILLED"] = DefaultHandler_UnitKilled;

-----------------------------------------------------------------------------------
-- City Attacked
function DefaultHandler_CityAttacked(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
			
	local sourcePlayerType : number = fact:GetPlayerSource();
	local destPlayerType : number = fact:GetPlayerDest();
	local sourcePlayer : object = Players[sourcePlayerType];
	local destPlayer : object = Players[destPlayerType];

	-- Ignore facts involving non-Civ players
	if (not sourcePlayer:IsMajorCiv() or not destPlayer:IsMajorCiv()) then
		return;
	end

	-- They attacked our city but didn't kill it
	if (destPlayerType == traitScript.Owner) then
		local reactionInfo : table = GameInfo.Reactions["REACTION_CITY_ATTACK_WIN_DISLIKE"];
		if (reactionInfo ~= nil) then						
			Players[traitScript.Owner]:SendReaction(reactionInfo.ID, sourcePlayerType);
		end
	
	-- We attacked their city but didn't kill it
	elseif (sourcePlayerType == traitScript.Owner) then
		local reactionInfo : table = GameInfo.Reactions["REACTION_CITY_DEFEND_WIN_DISLIKE"];
		if (reactionInfo ~= nil) then						
			Players[traitScript.Owner]:SendReaction(reactionInfo.ID, destPlayerType);
		end
	end
end
g_DefaultHandlersTable["AIFACT_CITY_ATTACKED"] = DefaultHandler_CityAttacked;

-----------------------------------------------------------------------------------
-- City Conquered
function DefaultHandler_CityConquered(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
			
	local sourcePlayerType : number = fact:GetPlayerSource();
	local destPlayerType : number = fact:GetPlayerDest();
	local sourcePlayer : object = Players[sourcePlayerType];
	local destPlayer : object = Players[destPlayerType];

	-- Ignore facts involving non-Civ players
	if (not sourcePlayer:IsMajorCiv() or not destPlayer:IsMajorCiv()) then
		return;
	end

	-- They conquered our city
	if (destPlayerType == traitScript.Owner) then
		local reactionInfo : table = GameInfo.Reactions["REACTION_YOU_TOOK_MY_CITY"];
		if (reactionInfo ~= nil) then						
			Players[traitScript.Owner]:SendReaction(reactionInfo.ID, sourcePlayerType);
		end
	
	-- We conquered their city
	elseif (sourcePlayerType == traitScript.Owner) then
		local reactionInfo : table = GameInfo.Reactions["REACTION_I_TOOK_YOUR_CITY"];
		if (reactionInfo ~= nil) then						
			Players[traitScript.Owner]:SendReaction(reactionInfo.ID, destPlayerType);
		end
	end
end
g_DefaultHandlersTable["AIFACT_CITY_CONQUERED"] = DefaultHandler_CityConquered;

-----------------------------------------------------------------------------------
-- Agreement Made
function DefaultHandler_AgreementMade(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
			
	local sourcePlayerType : number = fact:GetPlayerSource();
	local destPlayerType : number = fact:GetPlayerDest();
	local sourcePlayer : object = Players[sourcePlayerType];
	local destPlayer : object = Players[destPlayerType];

	-- Ignore facts involving non-Civ players
	if (not sourcePlayer:IsMajorCiv() or not destPlayer:IsMajorCiv()) then
		return;
	end

	-- Early-out if we made the agreement
	if (sourcePlayerType == traitScript.Owner) then
		return;
	end

	local reactionInfo : table = nil;

	-- They made an agreement with us
	if (destPlayerType == traitScript.Owner) then
		reactionInfo = GameInfo.Reactions["REACTION_AGREEMENT_MADE_LIKE"];
	else
		local relationship : number = Game.GetRelationship(traitScript.Owner, destPlayerType);
		if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			-- They made an agreement with one of my friends
			reactionInfo = GameInfo.Reactions["REACTION_AGREEMENT_MADE_LIKE"];
		elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			-- They made an agreement with one of my enemies
			reactionInfo = GameInfo.Reactions["REACTION_AGREEMENT_MADE_DISLIKE"];
		end
	end

	if (reactionInfo ~= nil) then
		Players[traitScript.Owner]:SendReaction(reactionInfo.ID, sourcePlayerType);
	end
end
g_DefaultHandlersTable["AIFACT_AGREEMENT_MADE"] = DefaultHandler_AgreementMade;

-----------------------------------------------------------------------------------
-- Agreement Cancelled
function DefaultHandler_AgreementCancelled(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
			
	local playerA : number = fact:GetPlayerSource();
	local playerB : number = fact:GetPlayerDest();
	local playerAtFault : number = fact:GetIntValue("PlayerAtFault");
	
	-- Early-out if nobody was at fault
	if (playerAtFault == -1) then
		return;
	end

	-- Early-out if we canceled the agreement
	if (traitScript.Owner == playerAtFault) then
		return;
	end

	local otherPlayer : number;
	if (playerAtFault == playerA) then
		otherPlayer = playerB;
	else
		otherPlayer = playerA;
	end

	local reactionInfo : table = nil;

	if (otherPlayer == traitScript.Owner) then
		-- We're the other player.  Complain
		reactionInfo = GameInfo.Reactions["REACTION_AGREEMENT_CANCELLED_DISLIKE"];
	else
		local relationship : number = Game.GetRelationship(traitScript.Owner, otherPlayer);
		if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			-- They canceled an agreement with one of my friends
			reactionInfo = GameInfo.Reactions["REACTION_AGREEMENT_CANCELLED_DISLIKE"];
		elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			-- They canceled an agreement with one of my enemies
			reactionInfo = GameInfo.Reactions["REACTION_AGREEMENT_CANCELLED_LIKE"];
		end
	end

	if (reactionInfo ~= nil) then
		Players[traitScript.Owner]:SendReaction(reactionInfo.ID, playerAtFault);
	end
end
g_DefaultHandlersTable["AIFACT_AGREEMENT_CANCELLED"] = DefaultHandler_AgreementCancelled;

-----------------------------------------------------------------------------------
-- War Established
function DefaultHandler_WarEstablished(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
	
	-- WRM: Early-out if the war was declared because of an alliance.  When we get
	--		specific communiques for this, remove this.
	if (fact:GetBooleanValue("Alliance") == true) then
		return;
	end

	local sourceTeamType : number = fact:GetSourceID();
	local destTeamType : number = fact:GetDestID();
	local sourceTeam : object = Teams[sourceTeamType];
	local destTeam : object = Teams[destTeamType];
	local traitPlayer : object = Players[traitScript.Owner];

	-- Ignore facts involving Neutral or Alien teams
	if (sourceTeam:IsNeutral() or sourceTeam:IsAlien() or destTeam:IsNeutral() or destTeam:IsAlien()) then
		return;
	end

	-- If our team established the war, ignore
	if (traitPlayer:GetTeam() == sourceTeamType) then
		return;
	end

	local reactionInfo : table = nil;

	-- If war was established against us, we dislike it
	if (traitPlayer:GetTeam() == destTeamType) then
		reactionInfo = GameInfo.Reactions["REACTION_WAR_ESTABLISHED_DISLIKE"];
	else
		-- Count the number of friends and enemies on the team that war has been declared on
		local enemiesOnTeam : number = 0;
		local friendsOnTeam : number = 0;

		for loopPlayerType : number = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			if (Players[loopPlayerType]:GetTeam() == destTeamType) then
				local relationship : number = Game.GetRelationship(traitScript.Owner, loopPlayerType);
				
				if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
					friendsOnTeam = friendsOnTeam + 1;
				elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
					enemiesOnTeam = enemiesOnTeam + 1;
				end
			end
		end

		-- Raise a reaction based on how many friends or enemies were affected.
		if (enemiesOnTeam + friendsOnTeam > 0) then
			if (enemiesOnTeam > friendsOnTeam) then
				reactionInfo = GameInfo.Reactions["REACTION_DECLARED_WAR_ON_ENEMY_LIKE"];
			elseif (enemiesOnTeam < friendsOnTeam) then
				reactionInfo = GameInfo.Reactions["REACTION_DECLARED_WAR_ON_FRIEND_DISLIKE"];
			end
		end
	end

	-- Send reactions to everyone on the team who started the war
	if (reactionInfo ~= nil) then
		for loopPlayerType : number = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			if (Players[loopPlayerType]:GetTeam() == sourceTeamType and loopPlayerType ~= traitScript.Owner) then
				traitPlayer:SendReaction(reactionInfo.ID, loopPlayerType);
			end
		end
	end
end
g_DefaultHandlersTable["AIFACT_WAR_ESTABLISHED"] = DefaultHandler_WarEstablished;

-----------------------------------------------------------------------------------
-- Peace Established
function DefaultHandler_PeaceEstablished(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
		return;
	end
	
	local sourceTeamType : number = fact:GetSourceID();
	local destTeamType : number = fact:GetDestID();
	local sourceTeam : object = Teams[sourceTeamType];
	local destTeam : object = Teams[destTeamType];
	local traitPlayer : object = Players[traitScript.Owner];

	-- Ignore facts involving Neutral or Alien teams
	if (sourceTeam:IsNeutral() or sourceTeam:IsAlien() or destTeam:IsNeutral() or destTeam:IsAlien()) then
		return;
	end

	-- If our team established peace, ignore
	if (traitPlayer:GetTeam() == sourceTeam) then
		return;
	end

	local reactionInfo : table = nil;

	-- If peace was established with us, we like it
	if (traitPlayer:GetTeam() == destTeamType) then
		reactionInfo = GameInfo.Reactions["REACTION_PEACE_ESTABLISHED_LIKE"];
	else
		-- Count the number of friends and enemies on the team that war has been declared on
		local enemiesOnTeam : number = 0;
		local friendsOnTeam : number = 0;

		for playerType : number = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			if (Players[playerType]:GetTeam() == destTeamType) then
				local relationship : number = Game.GetRelationship(traitScript.Owner, playerType);
				
				if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
					friendsOnTeam = friendsOnTeam + 1;
				elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
					enemiesOnTeam = enemiesOnTeam + 1;
				end
			end
		end

		-- Raise a reaction based on how many friends or enemies were affected.
		if (enemiesOnTeam + friendsOnTeam > 0) then
			if (enemiesOnTeam > friendsOnTeam) then
				reactionInfo = GameInfo.Reactions["REACTION_PEACE_ESTABLISHED_DISLIKE"];
			elseif (enemiesOnTeam < friendsOnTeam) then
				reactionInfo = GameInfo.Reactions["REACTION_PEACE_ESTABLISHED_LIKE"];
			end
		end
	end

	-- Send reactions to everyone on the team who established peace
	if (reactionType ~= nil) then
		for playerType : number = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			if (Players[playerType]:GetTeam() == sourceTeamType and playerType ~= traitScript.Owner) then
				traitPlayer:SendReaction(reactionInfo.ID, playerType);
			end
		end
	end
end
g_DefaultHandlersTable["AIFACT_PEACE_ESTABLISHED"] = DefaultHandler_PeaceEstablished;

-----------------------------------------------------------------------------------
-- Aggressive Expansion
function DefaultHandler_AggressiveExpansion(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	if (wasAdded) then
		return;
	end

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local landDisputeLevel : number = fact:GetIntValue("LandDisputeLevel");
	local landDisputeLevelLastTurn : number = fact:GetIntValue("LandDisputeLevelLastTurn");

	if (Players[fact:GetPlayerDest()]:GetTurnsSinceSettledLastCity() >= GameDefines.EXPANSION_BICKER_TIMEOUT) then
		return;
	end

	local reactionInfo : table = nil;
	if (landDisputeLevel >= DisputeLevelTypes.DISPUTE_LEVEL_FIERCE) then
		reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_EXPANSION_CONFRONTATION"];
	elseif (landDisputeLevel >= DisputeLevelTypes.DISPUTE_LEVEL_STRONG) then
		reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_EXPANSION_WARNING"]; 
	end

	if (reactionInfo ~= nil) then
		traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
	end
end
g_DefaultHandlersTable["AIFACT_AGGRESSIVE_EXPANSION"] = DefaultHandler_AggressiveExpansion;

-----------------------------------------------------------------------------------
-- Aggressive Military
function DefaultHandler_AggressiveMilitary(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	if (wasAdded) then
		return;
	end

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local militaryAggressivePosture : number = fact:GetIntValue("MilitaryAggressivePosture");
	local wasResurrectedByUs : boolean = fact:GetBooleanValue("WasResurrectedByUs");
	local isCoopAgreementAccepted : boolean = fact:GetBooleanValue("IsCoopAgreementAccepted");

	-- They must be able to declare war on us
	if (not Teams[traitPlayer:GetTeam()]:CanDeclareWar(Players[fact:GetPlayerDest()]:GetTeam())) then
		return;
	end

	-- Don't threaten if this person resurrected us
	if (wasResurrectedByUs) then
		return;
	end

	-- Don't care if we're cooperating
	if (isCoopAggreementAccepted) then
		return;
	end

	local reactionInfo : table = nil;
	if (militaryAggressivePosture >= AggressivePostureTypes.AGGRESSIVE_POSTURE_HIGH) then
		reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_MILITARY_CONFRONTATION"];
	elseif (militaryAggressivePosture > AggressivePostureTypes.AGGRESSIVE_POSTURE_MEDIUM) then
		reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_MILITARY_WARNING"];
	end

	if (reactionInfo ~= nil) then
		traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
	end
end
g_DefaultHandlersTable["AIFACT_AGGRESSIVE_MILITARY"] = DefaultHandler_AggressiveMilitary;

-----------------------------------------------------------------------------------
-- Caught agent
function DefaultHandler_CaughtAgent(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	if (wasAdded) then
		return;
	end

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local numAgentsCaught : number = fact:GetIntValue("NumAgentsCaught");
	if (numAgentsCaught == 0) then
		return;
	end

	local reactionInfo : table = nil;
	if (numAgentsCaught == 3) then -- Complain every 4th agent caught
		reactionInfo = GameInfo.Reactions["REACTION_CAUGHT_AGENT_WARNING"];
	elseif (numAgentsCaught % 4 == 0) then
		reactionInfo = GameInfo.Reactions["REACTION_CAUGHT_AGENT_CONFRONTATION"]; -- Confront every 10th agent
	end

	if (reactionInfo ~= nil) then
		traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
	end 
end
g_DefaultHandlersTable["AIFACT_CAUGHT_AGENT"] = DefaultHandler_CaughtAgent;

-----------------------------------------------------------------------------------
-- Was Victim of Bombshell Covert Op
function DefaultHandler_WasVictimOfBombshellCovertOp(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	if (not wasAdded) then
		return;
	end

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local reactionInfo : table = GameInfo.Reactions["REACTION_VICTIM_OF_COVERT_OPS_BOMBSHELL"];

	if (reactionInfo ~= nil) then
		traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
	end
end
g_DefaultHandlersTable["AIFACT_WAS_VICTIM_OF_BOMBSHELL_COVERT_OP"] = DefaultHandler_WasVictimOfBombshellCovertOp;

-----------------------------------------------------------------------------------
-- Aggressive Orbital Units
function DefaultHandler_AggressiveOrbitalUnitDetected(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	if (wasAdded) then
		return;
	end

	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local reactionInfo : table = nil;
	
	if (fact:GetBooleanValue("IsOverOurCity") == true) then
		reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_ORBITAL_UNIT_CONFRONTATION"];
	else
		local numAggressiveOrbitalUnitsDeployed : number = fact:GetIntValue("NumAggressiveOrbitalUnits");
		if (numAggressiveOrbitalUnitsDeployed == -1) then
			return;
		end

		if (numAggressiveOrbitalUnitsDeployed == 2) then
			reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_ORBITAL_UNIT_WARNING"];
		elseif (numAggressiveOrbitalUnitsDeployed % 3 == 0) then
			reactionInfo = GameInfo.Reactions["REACTION_AGGRESSIVE_ORBITAL_UNIT_CONFRONTATION"];
		end
	end
	
	if (reactionInfo ~= nil) then
		traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
	end
end
g_DefaultHandlersTable["AIFACT_AGGRESSIVE_ORBITAL_UNIT_DETECTED"] = DefaultHandler_AggressiveOrbitalUnitDetected;

-----------------------------------------------------------------------------------
-- Affinity differs
function DefaultHandler_AffinityDiffers(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	if (wasAdded) then
		return;
	end
	
	local fact : object = GetAIFactObject(playerType, factID)
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local affinityDiffersScore : number = fact:GetIntValue("AffinityDiffersScore");

	local reactionInfo : table = nil;

	if (affinityDiffersScore > 50) then
		reactionInfo = GameInfo.Reactions["REACTION_AFFINITY_DIFFERS_CONFRONTATION"];	
	elseif (affinityDiffersScore > 25) then
		reactionInfo = GameInfo.Reactions["REACTION_AFFINITY_DIFFERS_WARNING"];	
	end

	if (reactionInfo ~= nil) then
		traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
	end
end
g_DefaultHandlersTable["AIFACT_AFFINITY_DIFFERS"] = DefaultHandler_AffinityDiffers;

-----------------------------------------------------------------------------------
-- Relationship changed
function DefaultHandler_RelationshipChanged(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	local requestingPlayerType : number = fact:GetPlayerSource();
	local targetPlayerType : number = fact:GetPlayerDest();
	
	-- Early-out if we were the one who made the relationship change
	if (requestingPlayerType == traitScript.Owner) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	local oldRelationship : number = fact:GetIntValue("OldRelationship");
	local newRelationship : number = fact:GetIntValue("NewRelationship");
	local isImprovement : boolean = newRelationship > oldRelationship;

	local reactionInfo : table = nil;

	-- For any relationship change except war, since that is not a mutual decision
	-- (War handled above in DefaultHandler_WarEstablished)
	if (newRelationship ~= RelationshipLevels.RELATIONSHIP_WAR) then
		-- If we're the target, react
		if (targetPlayerType == traitScript.Owner) then
			if (isImprovement) then
				reactionInfo = GameInfo.Reactions["REACTION_RELATIONSHIP_IMPROVED_WITH_ME"];
			else
				reactionInfo = GameInfo.Reactions["REACTION_REALTIONSHIP_DEGRADED_WITH_ME"];
			end
		else
			--local myRelationshipWithTarget : number = Game.GetRelationship(traitScript.Owner, targetPlayerType);

			local DoRelationshipReaction : ifunction = function(playerAType : number, playerBType : number)
				if (playerBType == traitPlayer:GetID()) then
					return;
				end

				local relationship : number = Game.GetRelationship(playerAType, traitScript.Owner);

				local reactionInfo : table = nil;
				if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
					if (isImprovement) then
						reactionInfo = GameInfo.Reactions["REACTION_RELATIONSHIP_WITH_FRIEND_IMPROVED_LIKE"];
					end
				elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
					if (isImprovement) then
						reactionInfo = GameInfo.Reactions["REACTION_RELATIONSHIP_WITH_ENEMY_IMPROVED_DISLIKE"];
					end
				end

				if (reactionInfo ~= nil) then
					traitPlayer:SendReaction(reactionInfo.ID, playerBType);
				end
			end

			-- Do reactions for both sides of the relationship change, potentially sending reactions to both players involved
			DoRelationshipReaction(requestingPlayerType, targetPlayerType);
			DoRelationshipReaction(targetPlayerType, requestingPlayerType);
		end
	end
end
g_DefaultHandlersTable["AIFACT_RELATIONSHIP_CHANGED"] = DefaultHandler_RelationshipChanged;

-----------------------------------------------------------------------------------
-- Trade route established
function DefaultHandler_TradeRouteEstablished(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	local establishingPlayerType : number = fact:GetPlayerSource();
	local targetPlayerType : number = fact:GetPlayerDest();

	if (not Players[establishingPlayerType]:IsMajorCiv() or not Players[targetPlayerType]:IsMajorCiv()) then
		return;
	end

	-- Early-out if we've established the trade route
	if (establishingPlayerType == traitScript.Owner) then
		return;
	end

	local reactionInfo : table = nil;

	if (targetPlayerType == traitScript.Owner) then
		reactionInfo = GameInfo.Reactions["REACTION_TRADE_ROUTE_ESTABLISHED_LIKE"];
	else
		local relationship : number = Game.GetRelationship(traitScript.Owner, targetPlayerType);

		-- See the route was established with one of our friends or enemies
		if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			reactionInfo = GameInfo.Reactions["REACTION_TRADE_ROUTE_ESTABLISHED_LIKE"];
		elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			reactionInfo = GameInfo.Reactions["REACTION_TRADE_ROUTE_ESTABLISHED_DISLIKE"];
		end
	end

	if (reactionInfo ~= nil) then
		Players[traitScript.Owner]:SendReaction(reactionInfo.ID, establishingPlayerType);
	end
end
g_DefaultHandlersTable["AIFACT_TRADE_ROUTE_ESTABLISHED"] = DefaultHandler_TradeRouteEstablished;

-----------------------------------------------------------------------------------
-- Trade route plundered
function DefaultHandler_TradeRoutePlundered(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	local plunderingPlayerType : number = fact:GetPlayerSource();
	local targetPlayerType : number = fact:GetPlayerDest();

	-- Early-out if we're the plunderer
	if (plunderingPlayerType == traitScript.Owner) then
		return;
	end

	local reactionInfo : table = nil;

	if (targetPlayerType == traitScript.Owner) then
		reactionInfo = GameInfo.Reactions["REACTION_TRADE_ROUTES_PLUNDER_DISLIKE"];
	else
		local relationship : number = Game.GetRelationship(traitScript.Owner, targetPlayerType);

		-- See if the route belonged to one of our friends or enemies
		if (relationship > RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			reactionInfo = GameInfo.Reactions["REACTION_TRADE_ROUTES_PLUNDER_DISLIKE"];
		elseif (relationship < RelationshipLevels.RELATIONSHIP_NEUTRAL) then
			reactionInfo = GameInfo.Reactions["REACTION_TRADE_ROUTES_PLUNDER_LIKE"];
		end
	end

	if (reactionInfo ~= nil) then
		Players[traitScript.Owner]:SendReaction(reactionInfo.ID, plunderingPlayerType);
	end
end
g_DefaultHandlersTable["AIFACT_TRADE_ROUTE_PLUNDERED"] = DefaultHandler_TradeRoutePlundered;

-----------------------------------------------------------------------------------
-- Disputed Project Started (e.g. off-affinity planetary wonder)
function DefaultHandler_DisputedProjectStarted(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	-- This fact is only added when the AI determines a player should make an affinity-motivated threat
	-- towards the target player's project. No further conditions apply -- send the reaction immediately.	
	local reactionInfo : table = nil;
	local projectAffinityType = fact:GetIntValue("ProjectAffinityType")
	if (projectAffinityType == HARMONY_AFFINITY_TYPE) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_HARMONY_PROJECT_WARNING"];
	elseif (projectAffinityType == PURITY_AFFINITY_TYPE) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_PURITY_PROJECT_WARNING"];
	elseif (projectAffinityType == SUPREMACY_AFFINITY_TYPE) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_SUPREMACY_PROJECT_WARNING"];
	elseif (projectAffinityType == -1) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_BEACON_PROJECT_WARNING"];
	end

	if (reactionInfo ~= nil) then
		if (CanSendReactionThisTurn(reactionInfo, traitScript.Owner, fact:GetPlayerDest())) then
			traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
		end
	end
end
g_DefaultHandlersTable["AIFACT_DISPUTED_PROJECT_STARTED"] = DefaultHandler_DisputedProjectStarted;

-----------------------------------------------------------------------------------
-- Disputed Project Finished (e.g. off-affinity planetary wonder)
function DefaultHandler_DisputedProjectFinished(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, wasAdded : boolean)
	local fact : object = GetAIFactObject(playerType, factID);
	if (fact == nil) then
		error("Could not retrieve fact object");
	end

	if (fact:GetPlayerSource() ~= traitScript.Owner) then
		return;
	end

	-- Early-out if we're at war
	if (Game.GetRelationship(traitScript.Owner, fact:GetPlayerDest()) == RelationshipLevels.RELATIONSHIP_WAR) then
		return;
	end

	local traitPlayer : object = Players[traitScript.Owner];

	-- This fact is only added when the AI determines a player should make an affinity-motivated threat
	-- towards the target player's project. No further conditions apply -- send the reaction immediately.	
	local reactionInfo : table = nil;
	local projectAffinityType = fact:GetIntValue("ProjectAffinityType")
	if (projectAffinityType == HARMONY_AFFINITY_TYPE) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_HARMONY_PROJECT_CONFRONTATION"];
	elseif (projectAffinityType == PURITY_AFFINITY_TYPE) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_PURITY_PROJECT_CONFRONTATION"];
	elseif (projectAffinityType == SUPREMACY_AFFINITY_TYPE) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_SUPREMACY_PROJECT_CONFRONTATION"];
	elseif (projectAffinityType == -1) then
		reactionInfo = GameInfo.Reactions["REACTION_DISPUTED_BEACON_PROJECT_CONFRONTATION"];
	end

	if (reactionInfo ~= nil) then
		if (CanSendReactionThisTurn(reactionInfo, traitScript.Owner, fact:GetPlayerDest())) then
			traitPlayer:SendReaction(reactionInfo.ID, fact:GetPlayerDest());
		end
	end
end
g_DefaultHandlersTable["AIFACT_DISPUTED_PROJECT_FINISHED"] = DefaultHandler_DisputedProjectFinished;

--	===============================================================================
--	UTILITIES

-- Retrieves a fact object from either the player or game fact manager, if possible
function GetAIFactObject(playerType : number, factID : number)

	local fact : object;
	local factManager : object;

	if (playerType >= 0) then
		factManager = Players[playerType]:GetAIFactManager();
	else
		factManager = Game.GetAIFactManager();
	end

	if (factManager ~= nil) then
		fact = factManager:FindFactByID(factID);
	end

	return fact;
end

-- Dispatches the associated reaction each time a fact of the given type is added
function DefaultDispatchReaction(traitScript : CvPersonalityTraitScript, playerType : number, factType : number, factID : number, reactionType : string)
	-- Make sure the fact is valid
	if (factType ~= -1) then
		local factManager : object = Game.GetAIFactManager();
		if (factManager ~= nil) then
			local fact : object = factManager:FindFactByID(factID);
			if (fact ~= nil) then
				-- Don't dispatch reactions from a player to themselves
				local sourcePlayerType : number = fact:GetPlayerSource();
				if (sourcePlayerType ~= traitScript.Owner) then

					local traitPlayer : object = Players[traitScript.Owner];		
					local sourcePlayer : object = Players[sourcePlayerType];
		
					-- Ignore facts involving non-Civ players
					if (not traitPlayer:IsMajorCiv() or not sourcePlayer:IsMajorCiv()) then
						return;
					end

					local reactionInfo : table = GameInfo.Reactions[reactionType];
					if (reactionInfo ~= nil) then						
						local sourcePlayer = Players[sourcePlayerType];
						sourcePlayer:SendReaction(reactionInfo.ID, traitScript.Owner);
					end
				end
			end
		end
	end
end