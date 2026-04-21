------------------------------------------------------------------------------
--	FILE:	  AssignStartingPlots.lua
--	AUTHOR:   Bob Thomas
--	PURPOSE:  Start plot assignment method and resource handling, BE version.
------------------------------------------------------------------------------
--	REGIONAL DIVISION CONCEPT:   Bob Thomas
--	DIVISION ALGORITHM CONCEPT:  Ed Beach
--	CENTER BIAS CONCEPT:         Bob Thomas
--	RESOURCE BALANCING:          Bob Thomas
--	LUA IMPLEMENTATION:          Bob Thomas
--	BE ADAPTATION:               Bob Thomas
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapmakerUtilities");

------------------------------------------------------------------------------
-- NOTE FOR MODDERS: There is a detailed Reference at the end of the file.
------------------------------------------------------------------------------

--                             FOREWORD

-- Jon wanted a lot of changes to terrain composition for Civ5. These have
-- had the effect of making different parts of each randomly generated map
-- more distinct, more unique, but it has also necessitated a complete
-- overhaul of where civs are placed on the map and how resources are
-- distributed. The new placements are much more precise, both for civs 
-- and resources. As such, any modifications to terrain or resource types 
-- will no longer be "plug and play" in the XML. Terrain modders will have 
-- to work with this file as well as the XML, to integrate their mods in to
-- the new system.

-- Some civs will be purposely placed in difficult terrain, depending on what
-- a given map instance has to offer. Civs placed in tough environments will
-- receive specific amounts of assistance, primarily in the form of Bonus food
-- from Wheat, Cows, Deer, Bananas, or Fish. This part of the new system is 
-- very precisely calibrated and balanced, so be aware that any changes or 
-- additions to how resources are placed near start points will have a 
-- dramatic effect on the game, and could pose challenges of a sort that were
-- not present in the sphere of Civ4 modding.

-- The Luxury resources are also carefully calibrated. In a given game, some
-- will be clustered near a small number of civs (perhaps even a monopoly 
-- given to one). Some will be placed only near City States, requiring civs 
-- to go through a City State, one way or another, to obtain any instances of
-- that luxury type. Some will be left up to fate, appearing randomly in 
-- whatever is their normal habitat. Yet others may be oversupplied or perhaps
-- even absent from a given game. Which luxuries fall in to which category 
-- will be scrambled, to keep players guessing, and to help further the sense
-- of curiosity when exploring a new map in a new game.

-- Bob Thomas  -  April 16, 2010

-- There is a Reference section at the end of the file.

------------------------------------------------------------------------------
-- Notes for Civ:Beyond Earth.
--
-- City States, Start Biases, Natural Wonders and Luxury resources are removed.
--
-- 

------------------------------------------------------------------------------
------------------------------------------------------------------------------
AssignStartingPlots = {};
------------------------------------------------------------------------------

-- WARNING: There must not be any recalculation of AreaIDs at any time during
-- the execution of any operations in or attached to this table. Recalculating
-- will invalidate all data based on AreaID relationships with plots, which
-- will destroy Regional definitions for all but the Rectangular method. A fix
-- for scrambled AreaID data is theoretically possible, but I have not spent
-- development resources and time on this, directing attention to other tasks.

------------------------------------------------------------------------------
function AssignStartingPlots.Create()
	-- There are three methods of dividing the map in to regions.
	-- OneLandmass, Continents, Oceanic. Default method is Continents.
	--
	-- Standard start plot finding uses a regional division method, then
	-- assigns one civ per region. Regions with lowest average fertility
	-- get their assignment first, to avoid the poor getting poorer.
	--
	-- Default methods for civ and city state placement both rely on having
	-- regional division data. If the desired process for a given map script
	-- would not define regions of this type, replace the start finder
	-- with your custom method.
	--
	-- Note that this operation relies on inclusion of the Mapmaker Utilities.
	local iW, iH = Map.GetGridSize();
	local feature_atoll;
	for thisFeature in GameInfo.Features() do
		if thisFeature.Type == "FEATURE_ATOLL" then
			feature_atoll = thisFeature.ID;
		end
	end

	-- Main data table ("self dot" table).
	--
	-- Scripters have the opportunity to replace member methods without
	-- having to replace the entire process.
	local findStarts = {

		-- Core Process member methods
		__Init = AssignStartingPlots.__Init,
		__InitLuxuryWeights = AssignStartingPlots.__InitLuxuryWeights,
		__CustomInit = AssignStartingPlots.__CustomInit,
		ApplyHexAdjustment = AssignStartingPlots.ApplyHexAdjustment,
		GenerateRegions = AssignStartingPlots.GenerateRegions,
		ChooseLocations = AssignStartingPlots.ChooseLocations,
		BalanceAndAssign = AssignStartingPlots.BalanceAndAssign,
		SpecialSort = AssignStartingPlots.SpecialSort,
		PlaceNaturalWonders = AssignStartingPlots.PlaceNaturalWonders,
		PlaceResourcesAndCityStates = AssignStartingPlots.PlaceResourcesAndCityStates,
		
		-- Generate Regions member methods
		MeasureStartPlacementFertilityOfPlot = AssignStartingPlots.MeasureStartPlacementFertilityOfPlot,
		BadAdjacency = AssignStartingPlots.BadAdjacency,
		MeasureStartPlacementFertilityInRectangle = AssignStartingPlots.MeasureStartPlacementFertilityInRectangle,
		MeasureStartPlacementFertilityOfLandmass = AssignStartingPlots.MeasureStartPlacementFertilityOfLandmass,
		MeasureStartPlacementFertilityOfMap = AssignStartingPlots.MeasureStartPlacementFertilityOfMap,
		RemoveDeadRows = AssignStartingPlots.RemoveDeadRows,
		DivideIntoRegions = AssignStartingPlots.DivideIntoRegions,
		ChopIntoThreeRegions = AssignStartingPlots.ChopIntoThreeRegions,
		ChopIntoTwoRegions = AssignStartingPlots.ChopIntoTwoRegions,
		CustomOverride = AssignStartingPlots.CustomOverride,

		-- Choose Locations member methods
		WildAreasImpactLayer = AssignStartingPlots.WildAreasImpactLayer,
		MeasureTerrainInRegions = AssignStartingPlots.MeasureTerrainInRegions,
		DetermineRegionTypes = AssignStartingPlots.DetermineRegionTypes,
		PlaceImpactAndRipples = AssignStartingPlots.PlaceImpactAndRipples,
		MeasureSinglePlot = AssignStartingPlots.MeasureSinglePlot,
		EvaluateCandidatePlot = AssignStartingPlots.EvaluateCandidatePlot,
		IterateThroughCandidatePlotList = AssignStartingPlots.IterateThroughCandidatePlotList,
		FindStart = AssignStartingPlots.FindStart,
		FindCoastalStart = AssignStartingPlots.FindCoastalStart,
		FindStartWithoutRegardToAreaID = AssignStartingPlots.FindStartWithoutRegardToAreaID,
		FindAllStart = AssignStartingPlots.FindAllStart,

		-- Balance and Assign member methods
		AttemptToPlaceHillsAtPlot = AssignStartingPlots.AttemptToPlaceHillsAtPlot,
		AttemptToPlaceSmallStrategicAtPlot = AssignStartingPlots.AttemptToPlaceSmallStrategicAtPlot,
		FindFallbackForUnmatchedRegionPriority = AssignStartingPlots.FindFallbackForUnmatchedRegionPriority,
		NormalizeStartLocation = AssignStartingPlots.NormalizeStartLocation,
		NormalizeTeamLocations = AssignStartingPlots.NormalizeTeamLocations,

		-- City States member methods
		AssignCityStatesToRegionsOrToUninhabited = AssignStartingPlots.AssignCityStatesToRegionsOrToUninhabited,
		CanPlaceCityStateAt = AssignStartingPlots.CanPlaceCityStateAt,
		ObtainNextSectionInRegion = AssignStartingPlots.ObtainNextSectionInRegion,
		SetStationStartingPlots = AssignStartingPlots.SetStationStartingPlots,
		CollectStationCandidatePlotsUninhabited = AssignStartingPlots.CollectStationCandidatePlotsUninhabited,
		CollectStationCandidatePlotsForRegion = AssignStartingPlots.CollectStationCandidatePlotsForRegion,
		PlaceCityState = AssignStartingPlots.PlaceCityState,
		PlaceCityStateInRegion = AssignStartingPlots.PlaceCityStateInRegion,
		PlaceCityStates = AssignStartingPlots.PlaceCityStates,	-- Dependent on AssignLuxuryRoles being executed first, so beware.
		NormalizeCityState = AssignStartingPlots.NormalizeCityState,
		NormalizeCityStateLocations = AssignStartingPlots.NormalizeCityStateLocations, -- Dependent on PlaceLuxuries being executed first.

		-- Resources member methods
		CreateResources = AssignStartingPlots.CreateResources,
		Quantities = AssignStartingPlots.Quantities, -- Call from Create Resources
		InvalidBorderRegion = AssignStartingPlots.InvalidBorderRegion, -- Call from Create Resources
		ReachableByWaterCity = AssignStartingPlots.ReachableByWaterCity, -- Call from Create Resources
		BalanceCivStarts = AssignStartingPlots.BalanceCivStarts, -- Called from BalanceAndAssign
		BasicFood = AssignStartingPlots.BasicFood, -- Called from BalanceCivStarts
		BasicEnergyProduction = AssignStartingPlots.BasicEnergyProduction, -- Called from BalanceCivStarts
		SetResources = AssignStartingPlots.SetResources, --Called from BasicFood and ProductionAndEnergy
		PlaceResourceImpact = AssignStartingPlots.PlaceResourceImpact,		-- Note: called from PlaceImpactAndRipples
		RelaxMiasmaNearStartLocations = AssignStartingPlots.RelaxMiasmaNearStartLocations,
		
		-- BE functions for resources.
		
		
		-- Civ start position variables
		startingPlots = {},				-- Stores x and y coordinates (and "score") of starting plots for civs, indexed by region number
		startingWaterPlots = {},		-- Stores x and y coordinates (and "score") of starting water plots for civs, indexed by region number
		method = 2,						-- Method of regional division, default is 2
		iNumCivs = 0,					-- Number of civs at game start
		player_ID_list = {},			-- Correct list of player IDs (includes handling of any 'gaps' that occur in MP games)
		plotDataIsCoastal = {},			-- Stores table of NextToSaltWater plots to reduce redundant calculations
		plotDataIsNextToCoast = {},		-- Stores table of TwoAwayFromSaltWater plots to reduce redundant calculations
		regionData = {},				-- Stores data returned from regional division algorithm
		regionTerrainCounts = {},		-- Stores counts of terrain elements for all regions
		regionTypes = {},				-- Stores region types
		distanceData = table.fill(0, iW * iH), -- Stores "impact and ripple" data of start points as each is placed
		playerCollisionData = table.fill(false, iW * iH), -- Stores "impact" data only, of start points, to avoid player collisions
		startLocationConditions = {},   -- Stores info regarding conditions at each start location
		
		-- Team info variables (not used in the core process, but necessary to many Multiplayer map scripts)
		bTeamGame,
		iNumTeamsOfCivs,
		teams_with_major_civs,
		number_civs_per_team,
		
		-- Rectangular Division, dimensions within which all regions reside. (Unused by the other methods)
		inhabited_WestX,
		inhabited_SouthY,
		inhabited_Width,
		inhabited_Height,

		-- Natural Wonders variables
		naturalWondersData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the natural wonders layer
		bWorldHasOceans,
		iBiggestLandmassID,
		iNumNW = 0,
		wonder_list = {},
		eligibility_lists = {},
		xml_row_numbers = {},
		placed_natural_wonder = {},
		feature_atoll,
		
		-- City States variables
		cityStatePlots = {},			-- Stores x and y coordinates, and region number, of city state sites
		iNumCityStates = 0,				-- Number of city states at game start
		iNumCityStatesUnassigned = 0,	-- Number of City States still in need of placement method assignment
		iNumCityStatesPerRegion = 0,	-- Number of City States to be placed in each civ's region
		iNumCityStatesUninhabited = 0,	-- Number of City States to be placed on landmasses uninhabited by civs
		iNumCityStatesSharedLux = 0,	-- Number of City States to be placed in regions whose luxury type is shared with other regions
		iNumCityStatesLowFertility = 0,	-- Number of extra City States to be placed in regions with low fertility per land plot
		cityStateData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the city state layer
		city_state_region_assignments = table.fill(-1, 41), -- Stores region number of each city state (-1 if not in a region)
		uninhabited_areas_coastal_plots = {}, -- For use in placing city states outside of Regions
		uninhabited_areas_inland_plots = {},
		iNumCityStatesDiscarded = 0,	-- If a city state cannot be placed without being too close to another start, it will be discarded
		city_state_validity_table = table.fill(false, 41), -- Value set to true when a given city state is successfully assigned a start plot
		
		-- Minor Power variables
		iNumStations = 0,

		-- Resources variables
		resources = {},                 -- Stores all resource data, pulled from the XML
		resource_setting,				-- User selection for Resource Setting, chosen on game launch (when applicable)
		amounts_of_resources_placed = table.fill(0, 45), -- Stores amounts of each resource ID placed. WARNING: This table uses adjusted resource ID (+1) to account for Lua indexing. Add 1 to all IDs to index this table.
		luxury_assignment_count = table.fill(0, 45), -- Stores amount of each luxury type assigned to regions. WARNING: current implementation will crash if a Luxury is attached to resource ID 0 (default = titanium), because this table uses unadjusted resource ID as table index.
		luxury_low_fert_compensation = table.fill(0, 45), -- Stores number of times each resource ID had extras handed out at civ starts. WARNING: Indexed by resource ID.
		luxury_region_weights = {},		-- Stores weighted assignments for the types of regions
		luxury_fallback_weights = {},	-- In case all options for a given region type got assigned or disabled, also used for Undefined regions
		luxury_city_state_weights = {},	-- Stores weighted assignments for city state exclusive luxuries
		strategicData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the strategic resources layer
		luxuryData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the luxury resources layer
		bonusData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the bonus resources layer
		fishData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the fish layer
		sheepData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the sheep layer -- Sheep use regular bonus layer PLUS this one
		--
		wildData = table.fill(0, iW * iH), -- Stores "impact and ripple" data in the Wild Areas layer
		wild_score_forgiveness_factor = 50, -- Out of a range of 0 to 199, the score amount to overlook/ignore/forgive, in regard to start location proximity to wild areas.
		miasma_chance_on_algae = 25,	-- Percentage chance for miasma to appear on a given algae plot; does not occur for normalized sources at start locations.
		--
		regions_sorted_by_type = {},	-- Stores table that includes region number and Luxury ID (this is where the two are first matched)
		region_luxury_assignment = {},	-- Stores luxury assignments, keyed by region number.
		iNumTypesUnassigned = 20,		-- Total number of luxuries. Adjust if modifying number of luxury resources.
		iNumMaxAllowedForRegions = 8,	-- Maximum luxury types allowed to be assigned to regional distribution. CANNOT be reduced below 8!
		iNumTypesAssignedToRegions = 0,
		resourceIDs_assigned_to_regions = {},
		iNumTypesAssignedToCS = 3,		-- Luxury types that will be placed only near city states
		resourceIDs_assigned_to_cs = {},
		resourceIDs_assigned_to_special_case = {},
		iNumTypesRandom = 0,
		resourceIDs_assigned_to_random = {},
		iNumTypesDisabled = 0,
		resourceIDs_not_being_used = {},
		totalLuxPlacedSoFar = 0,
		bonus_multiplier = 1,
		--
		--
		--

		-- Plot lists for use with global distribution of Luxuries.
		--
		-- NOTE: These lists are best synchronized with the equivalent plot list generations
		-- for regions and individual city sites, to keep Luxury behavior globally consistent.
		-- All three list sets are acted upon by a single set of indices, which apply only to 
		-- Luxury resources. These are controlled in the function GetIndicesForLuxuryType.
		-- 
		feature_atoll = feature_atoll,
		
		-- Additional Plot lists for use with global distribution of Strategics and Bonus.
		--
		-- Unlike Luxuries, which have sophisticated handling to foster supply and demand
		-- in support of Trade and Diplomacy, the Strategic and Bonus resources are 
		-- allowed to conform to the terrain of a given map, with their quantities 
		-- available in any given game only loosely controlled. Thanks to the new method
		-- of quantifying strategic resources, the controls on their distribution no
		-- longer need to be as strenuous. Likewise with Bonus no longer affecting trade.
		grass_flat_no_feature = {},
		tundra_flat_no_feature = {},
		snow_flat_list = {},
		hills_list = {},
		land_list = {},
		coast_list = {},
		extra_deer_list = {},
		desert_wheat_list = {},
		banana_list = {},
		barren_plots = 0,
		-- BE lists
		next_to_canyon_list = {},
		coastal_land_list = {},
		next_to_mountain_list = {},
		river_list = {},
		wild_area_list = {},
		wild_area_flatlands_list = {},
		next_to_wild_area_list = {},
		wild_desert_list = {},
		wild_tundra_list = {},
		wild_ocean_list = {},
		
		-- Positioner defaults. These are the controls for the "Center Bias" placement method for civ starts in regions.
		centerBias = 50, -- % of radius from region center to examine first
		middleBias = 80, -- % of radius from region center to check second
		minFoodInner = 1,
		minProdInner = 0,
		minGoodInner = 3,
		minFoodMiddle = 4,
		minProdMiddle = 0,
		minGoodMiddle = 6,
		minFoodOuter = 4,
		minProdOuter = 2,
		minGoodOuter = 8,
		maxJunk = 10,

		-- Hex Adjustment tables. These tables direct plot by plot scans in a radius 
		-- around a center hex, starting to Northeast, moving clockwise.
		firstRingYIsEven = {{0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}},
		secondRingYIsEven = {
		{1, 2}, {1, 1}, {2, 0}, {1, -1}, {1, -2}, {0, -2},
		{-1, -2}, {-2, -1}, {-2, 0}, {-2, 1}, {-1, 2}, {0, 2}
		},
		thirdRingYIsEven = {
		{1, 3}, {2, 2}, {2, 1}, {3, 0}, {2, -1}, {2, -2},
		{1, -3}, {0, -3}, {-1, -3}, {-2, -3}, {-2, -2}, {-3, -1},
		{-3, 0}, {-3, 1}, {-2, 2}, {-2, 3}, {-1, 3}, {0, 3}
		},
		firstRingYIsOdd = {{1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}},
		secondRingYIsOdd = {		
		{1, 2}, {2, 1}, {2, 0}, {2, -1}, {1, -2}, {0, -2},
		{-1, -2}, {-1, -1}, {-2, 0}, {-1, 1}, {-1, 2}, {0, 2}
		},
		thirdRingYIsOdd = {		
		{2, 3}, {2, 2}, {3, 1}, {3, 0}, {3, -1}, {2, -2},
		{2, -3}, {1, -3}, {0, -3}, {-1, -3}, {-2, -2}, {-2, -1},
		{-3, 0}, {-2, 1}, {-2, 2}, {-1, 3}, {0, 3}, {1, 3}
		},
		-- Direction types table, another method of handling hex adjustments, in combination with Map.PlotDirection()
		direction_types = {
			DirectionTypes.DIRECTION_NORTHEAST,
			DirectionTypes.DIRECTION_EAST,
			DirectionTypes.DIRECTION_SOUTHEAST,
			DirectionTypes.DIRECTION_SOUTHWEST,
			DirectionTypes.DIRECTION_WEST,
			DirectionTypes.DIRECTION_NORTHWEST
			},
		
		-- Handy resource ID shortcuts
		petroleum_ID,
		titanium_ID,
		geothermal_ID,
		xenomass_ID,
		firaxite_ID,
		floatstone_ID,

		fiber_ID,
		coral_ID,
		chitin_ID,
		silica_ID,
		fungus_ID,
		basalt_ID,
		gold_ID,
		copper_ID,
		fruit_ID,
		algae_ID,
		resilin_ID,
		tubers_ID,
		shell_ID,
		vents_ID,
		minerals_ID,
		plankton_ID,
		chelonia_ID,

		basic_culture = {},
		basic_science = {},
		reach = false,

		-- Resource ID-String lookup table
		ResIDStrings = {},

		resourceQuantity = {},

		resourcesSet = 0,

		-- strategic balance resources
		strategic_balance = {},
		strategic_balance_count = 1,

		water_civ_starts = 1;

		mustBeInWater = false;
		mustBeInOrAdjacentToWater = false;
	}
	
	findStarts:__Init()
	
	-- Entry point for easy overrides, for instance if only a couple things need to change.
	findStarts:__CustomInit()
	
	return findStarts
end
------------------------------------------------------------------------------
function AssignStartingPlots:__Init()
	-- Set up data tables that record whether a plot is coastal land and whether a plot is adjacent to coastal land.
	self.plotDataIsCoastal, self.plotDataIsNextToCoast = GenerateNextToCoastalLandDataTables()

		-- Set up data for resource ID shortcuts.
	for resource_data in GameInfo.Resources() do
		table.insert(self.resources, resource_data);

		-- Set up Strategic IDs
		if resourceType == "RESOURCE_PETROLEUM" then
			self.petroleum_ID = resourceID;	-- was petroleum_ID
			self.ResIDStrings[resourceID] = "PETROLEUM";
		elseif resourceType == "RESOURCE_TITANIUM" then
			self.titanium_ID = resourceID;
			self.ResIDStrings[resourceID] = "TITANIUM";
		elseif resourceType == "RESOURCE_GEOTHERMAL_ENERGY" then
			self.geothermal_ID = resourceID;	-- was geothermal_ID
			self.ResIDStrings[resourceID] = "GEOTHERMAL";
		elseif resourceType == "RESOURCE_XENOMASS" then
			self.xenomass_ID = resourceID;
			self.ResIDStrings[resourceID] = "XENOMASS";
		elseif resourceType == "RESOURCE_FLOAT_STONE" then
			self.floatstone_ID = resourceID;	-- was floatstone_ID
			self.ResIDStrings[resourceID] = "FLOATSTONE";
		elseif resourceType == "RESOURCE_FIRAXITE" then
			self.firaxite_ID = resourceID;	-- was firaxite_ID
			self.ResIDStrings[resourceID] = "FIRAXITE";
			
		-- Set up Basic IDs
		elseif resourceType == "RESOURCE_CORAL" then
			self.coral_ID = resourceID;	-- was coral_ID
			self.ResIDStrings[resourceID] = "CORAL";
		elseif resourceType == "RESOURCE_SILICA" then
			self.silica_ID = resourceID;	-- was silica_ID
			self.ResIDStrings[resourceID] = "SILICA";
		elseif resourceType == "RESOURCE_CHITIN" then
			self.chitin_ID = resourceID;	-- was chitin_ID
			self.ResIDStrings[resourceID] = "CHITIN";
		elseif resourceType == "RESOURCE_RESILIN" then
			self.resilin_ID = resourceID;
			self.ResIDStrings[resourceID] = "RESILIN";
		elseif resourceType == "RESOURCE_FUNGUS" then
			self.fungus_ID = resourceID;
			self.ResIDStrings[resourceID] = "FUNGUS";
		elseif resourceType == "RESOURCE_FIBER" then
			self.fiber_ID = resourceID;	-- was fiber_ID
			self.ResIDStrings[resourceID] = "FIBER";
		elseif resourceType == "RESOURCE_GOLD" then
			self.gold_ID = resourceID;
			self.ResIDStrings[resourceID] = "GOLD";
		elseif resourceType == "RESOURCE_BASALT" then
			self.basalt_ID = resourceID;	-- was stone_ID
			self.ResIDStrings[resourceID] = "BASALT";
		elseif resourceType == "RESOURCE_COPPER" then
			self.copper_ID = resourceID;
			self.ResIDStrings[resourceID] = "COPPER";
		elseif resourceType == "RESOURCE_FRUIT" then
			self.fruit_ID = resourceID;	-- was fruit_ID
			self.ResIDStrings[resourceID] = "FRUIT";
		elseif resourceType == "RESOURCE_ALGAE" then
			self.algae_ID = resourceID;	-- was algae_ID
			self.ResIDStrings[resourceID] = "ALGAE";
		elseif resourceType == "RESOURCE_TUBERS" then
			self.tubers_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "TUBERS";
		elseif resourceType == "RESOURCE_VENTS" then
			self.vents_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "VENTS";
		elseif resourceType == "RESOURCE_SHELL" then
			self.shell_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "SHELL";
		elseif resourceType == "RESOURCE_EGGS" then
			self.eggs_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "EGGS";
		elseif resourceType == "RESOURCE_MINERALS" then
			self.minerals_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "TUBERS";
		elseif resourceType == "RESOURCE_PLANKTON" then
			self.plankton_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "PLANKTON";
		elseif resourceType == "RESOURCE_CHELONIA" then
			self.chelonia_ID = resourceID; -- was algae_ID
			self.ResIDStrings[resourceID] = "CHELONIA";
		end
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:__CustomInit()
	-- This function included to provide a quick and easy override for changing 
	-- any initial settings. Add your customized version to the map script.
end	
------------------------------------------------------------------------------
function AssignStartingPlots:ApplyHexAdjustment(x, y, plot_adjustments)
	-- Used this bit of code so many times, I had to make it a function.
	local iW, iH = Map.GetGridSize();
	local adjusted_x, adjusted_y;
	if Map:IsWrapX() == true then
		adjusted_x = (x + plot_adjustments[1]) % iW;
	else
		adjusted_x = x + plot_adjustments[1];
	end
	if Map:IsWrapY() == true then
		adjusted_y = (y + plot_adjustments[2]) % iH;
	else
		adjusted_y = y + plot_adjustments[2];
	end
	return adjusted_x, adjusted_y;
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Luxury methods. Luxuries are not placed for Civ:BE - Bob.
------------------------------------------------------------------------------
function AssignStartingPlots:__InitLuxuryWeights()
end	
------------------------------------------------------------------------------
function AssignStartingPlots:IdentifyRegionsOfThisType(region_type)
end
------------------------------------------------------------------------------
function AssignStartingPlots:SortRegionsByType()
end
------------------------------------------------------------------------------
function AssignStartingPlots:GenerateLuxuryPlotListsInRegion(region_number)
end
------------------------------------------------------------------------------
function AssignStartingPlots:GetIndicesForLuxuryType(resource_ID)
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Start of functions tied to GenerateRegions()
------------------------------------------------------------------------------
function AssignStartingPlots:BadAdjacency(x, y)
	--This function prevents resources from being too close to ice

	local iBadAdjacency = 0;
	for loop, direction in ipairs(self.direction_types) do
		local adjacentPlot = Map.PlotDirection(x, y, direction);

		if (adjacentPlot ~= nil and bNotIce == true) then
			local adjacentFeature = adjacentPlot:GetFeatureType();
			if(adjacentFeature == FeatureTypes.FEATURE_ICE ) then
				iBadAdjacency = iBadAdjacency - 1;
			end
		end
	end

	return iBadAdjacency;
end
function AssignStartingPlots:MeasureStartPlacementFertilityOfPlot(x, y)
	-- BE NOTES: Jungles, Oases are out. Canyons, Miasma are in. Wild Area plots get ignored.
	--
	-- Fertility of plots is used to divide continents or areas in to Regions.
	-- Regions are used to assign starting plots and place some resources.
	-- Usage: x, y are plot coords, with 0,0 in SW. The check is a boolean.
	--
	--[[ If you modify the terrain values or add or remove any terrain elements, you
		 will need to add or modify processes here to accomodate your changes. Please 
		 be aware that the default process includes numerous assumptions that your
		 terrain changes may invalidate, so you may need to rebalance the system. ]]--
	--
	
	-- Check for membership in a Wild Area. Wild Area plots are completely ignored for plot fertility calculations.
	-- This is intended to exclude them from the regional definitions. Civs with a substantial Wild Area in their
	-- region will have that much extra land included in their region.
	--
	-- NOTE: To have Wild Values in play that are *not* ignored for start region fertility, delay generating these Wild 
	-- values until after regions have been defined. Any wild value in place prior to dividing regions, those plots will be ignored.
	local plotFertility = 0;
	local plot = Map.GetPlot(x, y);
	local featureType = plot:GetFeatureType();
	local iW, iH = Map.GetGridSize()
	local i = y * iW + x + 1;
	local wild_value = plot:GetWildness()
	if wild_value > 0 then -- Plot is member of a Wild Area. Return Negative 1 if water! If Land Return 0!
		if (plot:IsWater() and featureType ~= FeatureTypes.FEATURE_ICE) then
			return -1;
		else
			return 0;
		end
	end
	
	local iBadAdjacency =self:BadAdjacency(x,y);

	local plotType = plot:GetPlotType();
	local terrainType = plot:GetTerrainType();
	-- Measure Fertility -- Any cases absent from the process have a 0 value. This currently includes Canyons.
	if (iBadAdjacency > 0) then
		plotFetility = iBadAdjacency;
	elseif plotType == PlotTypes.PLOT_MOUNTAIN then -- Note, mountains cannot belong to a landmass AreaID, so they usually go unmeasured.
		plotFertility =  -2;
	elseif terrainType == TerrainTypes.TERRAIN_SNOW then
		plotFertility = -1;
	elseif featureType == FeatureTypes.FEATURE_FLOOD_PLAINS then
		plotFertility = 5;
	else
		if terrainType == TerrainTypes.TERRAIN_GRASS then
			plotFertility = 3;
		elseif terrainType == TerrainTypes.TERRAIN_PLAINS then
			plotFertility = 4;
		elseif terrainType == TerrainTypes.TERRAIN_TUNDRA then
			plotFertility = 2;
		elseif terrainType == TerrainTypes.TERRAIN_COAST then
			plotFertility = 3;
		elseif terrainType == TerrainTypes.TERRAIN_OCEAN then
			plotFertility = 2;
		elseif terrainType == TerrainTypes.TERRAIN_DESERT then
			plotFertility = 1;
		elseif terrainType == TerrainTypes.TERRAIN_TRENCH  then
			plotFertility = -1;
		end
		if plotType == PlotTypes.PLOT_HILLS then
			plotFertility = plotFertility + 1;
		end
		if featureType == FeatureTypes.FEATURE_FOREST then
			plotFertility = plotFertility + 0;
		elseif featureType == FeatureTypes.FEATURE_MARSH then
			plotFertility = - 1;
		elseif featureType == FeatureTypes.FEATURE_ICE then
			plotFertility = - 3;
		end
		if (not plot:IsWater() and plot:IsRiverSide()) then
			plotFertility = plotFertility + 1;
		end
	end
	
	if plot:HasMiasma() then
		plotFertility = plotFertility - 0.5;
	end

	return plotFertility
end
------------------------------------------------------------------------------
function CalculateFertilityMap()
	local fertilityMap : table = {};

	local closeFertilities : table = { 0, 1, 1, 1, 2, 2, 2, 3 };
	local farFertilities : table = { 0, 1, 1, 2, 2, 3, 3, 4 };

	-- First pass, give each plot a fertility roughly softened by distance from the
	-- region's centroid.  Also, cache centroid plots
	local centroidPlots : table = {};
	for _,plot : table in Plots() do
		local distFromCentroid : number = MapGenerator.GetPlotHexDistanceFromRegionCentroid(plot);

		local randomFertility : number = 1;
		if (distFromCentroid <= 5) then
			randomFertility = closeFertilities[Game.Rand(#closeFertilities, "Choosing plot fertility") + 1];
		else
			randomFertility = farFertilities[Game.Rand(#farFertilities, "Choosing plot fertility") + 1];
		end

		fertilityMap[plot:GetPlotIndex()] = randomFertility;

		if (distFromCentroid == 0) then
			table.insert(centroidPlots, plot);
		end
	end

	-- Second pass, create fertility concentrations around focal points
	local ringMedianFertility : number = 3;
	local maxIdealFertility : number = 4;
	local varianceAbove : number = maxIdealFertility - ringMedianFertility;
	local varianceBelow : number = -1;

	for _,plot : table in ipairs(centroidPlots) do
		for ringRadius=1,3 do
			local ringPlots : table = {};
			AssignStartingPlots.DoForEachRingPlot(plot, ringRadius, function(neighborPlot : table) 
				table.insert(ringPlots, neighborPlot);
			end);

			local variances : table = {};
			for variance : number =1,#ringPlots / 2 do
				local variance : number = Game.RandRange(varianceBelow, varianceAbove, "Calculating plot fertility variance");
				table.insert(variances, variance);
				table.insert(variances, -variance);
			end

			-- if number of rings is odd, set last variance to an average
			if (#variances < #ringPlots) then
				table.insert(variances, ringMedianFertility);
			end

			-- Apply random variance to plot
			for _,ringPlot : table in ipairs(ringPlots) do
				local randomIndex = Game.Rand(#variances, "Selecting random variance") + 1;
				fertilityMap[ringPlot:GetPlotIndex()] = variances[randomIndex];
				table.remove(variances, randomIndex);
			end

			-- Decrease the ideal per-plot fertility for the next ring
			ringMedianFertility = ringMedianFertility - 1;
		end
	end

	return fertilityMap;
end
------------------------------------------------------------------------------
function AssignStartingPlots:MeasureStartPlacementFertilityInRectangle(iWestX, iSouthY, iWidth, iHeight)
	-- This function is designed to provide initial data for regional division recursion.
	-- Loop through plots in this rectangle and measure Fertility Rating.
	-- Results will include a data table of all measured plots.
	local areaFertilityTable = {};
	local areaFertilityCount = 0;
	local plotCount = iWidth * iHeight;
	for y = iSouthY, iSouthY + iHeight - 1 do -- When generating a plot data table incrementally, process Y first so that plots go row by row.
		for x = iWestX, iWestX + iWidth - 1 do
			local plotFertility = self:MeasureStartPlacementFertilityOfPlot(x, y); -- Check for coastal land is disabled.
			table.insert(areaFertilityTable, plotFertility);
			areaFertilityCount = areaFertilityCount + plotFertility;
		end
	end

	-- Returns table, integer, integer.
	return areaFertilityTable, areaFertilityCount, plotCount
end
------------------------------------------------------------------------------
function AssignStartingPlots:MeasureStartPlacementFertilityOfLandmass(iAreaID, iWestX, iEastX, iSouthY, iNorthY, wrapsX, wrapsY)
	-- This function is designed to provide initial data for regional division recursion.
	-- Loop through plots in this landmass and measure Fertility Rating.
	-- Results will include a data table of all plots within the rectangle that includes the entirety of this landmass.
	--
	-- This function will account for any wrapping around the world this landmass may do.
	local iW, iH = Map.GetGridSize()
	local xEnd, yEnd; --[[ These coordinates will be used in case of wrapping landmass, 
	                       extending the landmass "off the map", in to imaginary space 
	                       to process it. Modulo math will correct the coordinates for 
	                       accessing the plot data array. ]]--
	if wrapsX then
		xEnd = iEastX + iW;
	else
		xEnd = iEastX;
	end
	if wrapsY then
		yEnd = iNorthY + iH;
	else
		yEnd = iNorthY;
	end
	--
	local areaFertilityTable = {};
	local areaFertilityCount = 0;
	local plotCount = 0;
	for yLoop = iSouthY, yEnd do -- When generating a plot data table incrementally, process Y first so that plots go row by row.
		for xLoop = iWestX, xEnd do
			plotCount = plotCount + 1;
			local x = xLoop % iW;
			local y = yLoop % iH;
			local plot = Map.GetPlot(x, y);
			local thisPlotsArea = plot:GetArea()
			if thisPlotsArea ~= iAreaID then -- This plot is not a member of the landmass, set value to 0
				table.insert(areaFertilityTable, 0);
			else -- This plot is a member, process it.
				local plotFertility = self:MeasureStartPlacementFertilityOfPlot(x, y);
				table.insert(areaFertilityTable, plotFertility);
				areaFertilityCount = areaFertilityCount + plotFertility;
			end
		end
	end
	
	-- Note: The table accounts for world wrap, so make sure to translate its index correctly.
	-- Plots in the table run from the southwest corner along the bottom row, then upward row by row, per normal plot data indexing.
	return areaFertilityTable, areaFertilityCount, plotCount
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function AssignStartingPlots:MeasureStartPlacementFertilityOfMap(iWestX, iEastX, iSouthY, iNorthY)
	-- This function is designed to provide initial data for regional division recursion.
	-- Loop through plots in this landmass and measure Fertility Rating.
	-- Results will include a data table of all plots within the rectangle that includes the entirety of this landmass.
	--
	--
	local iW, iH = Map.GetGridSize();

	local areaFertilityTable = {};
	local areaFertilityCount = 0;
	local plotCount = 0;
	for yLoop = iSouthY, iNorthY do -- When generating a plot data table incrementally, process Y first so that plots go row by row.
		for xLoop = iWestX, iEastX do
			plotCount = plotCount + 1;
			local x = xLoop % iW;
			local y = yLoop % iH;
			local plot = Map.GetPlot(x, y);
			local terrainType = plot:GetTerrainType();
			local featureType = plot:GetFeatureType();
			if plotType == PlotTypes.PLOT_MOUNTAIN or featureType == FeatureTypes.FEATURE_ICE or terrainType == TerrainTypes.TERRAIN_TRENCH then -- This plot is not a member of the landmass, set value to 0
				table.insert(areaFertilityTable, 0);
			else
				local plotFertility = self:MeasureStartPlacementFertilityOfPlot(x, y); -- This plot is a member, process it.
				table.insert(areaFertilityTable, plotFertility);
				areaFertilityCount = areaFertilityCount + plotFertility;
			end
		end
	end
	
	-- Note: The table accounts for world wrap, so make sure to translate its index correctly.
	-- Plots in the table run from the southwest corner along the bottom row, then upward row by row, per normal plot data indexing.
	return areaFertilityTable, areaFertilityCount, plotCount
end
------------------------------------------------------------------------------

function AssignStartingPlots:RemoveDeadRows(fertility_table, iWestX, iSouthY, iWidth, iHeight)
	-- Any outside rows in the fertility table of a just-divided region that 
	-- contains all zeroes can be safely removed.
	-- This will improve the accuracy of operations involving any applicable region.
	local iW, iH = Map.GetGridSize()
	local adjusted_table = {};
	local adjusted_WestX;
	local adjusted_SouthY
	local adjusted_Width
	local adjusted_Height;
	
	-- Check for rows to remove on the bottom.
	local adjustSouth = 0;
	for y = 0, iHeight - 1 do
		local bKeepThisRow = false;
		for x = 0, iWidth - 1 do
			local i = y * iWidth + x + 1;
			if fertility_table[i] > 0 then
				bKeepThisRow = true;
				break
			end
		end
		if bKeepThisRow == true then
			break
		else
			adjustSouth = adjustSouth + 1;
		end
	end

	-- Check for rows to remove on the top.
	local adjustNorth = 0;
	for y = iHeight - 1, 0, -1 do
		local bKeepThisRow = false;
		for x = 0, iWidth - 1 do
			local i = y * iWidth + x + 1;
			if fertility_table[i] > 0 then
				bKeepThisRow = true;
				break
			end
		end
		if bKeepThisRow == true then
			break
		else
			adjustNorth = adjustNorth + 1;
		end
	end

	-- Check for columns to remove on the left.
	local adjustWest = 0;
	for x = 0, iWidth - 1 do
		local bKeepThisColumn = false;
		for y = 0, iHeight - 1 do
			local i = y * iWidth + x + 1;
			if fertility_table[i] > 0 then
				bKeepThisColumn = true;
				break
			end
		end
		if bKeepThisColumn == true then
			break
		else
			adjustWest = adjustWest + 1;
		end
	end

	-- Check for columns to remove on the right.
	local adjustEast = 0;
	for x = iWidth - 1, 0, -1 do
		local bKeepThisColumn = false;
		for y = 0, iHeight - 1 do
			local i = y * iWidth + x + 1;
			if fertility_table[i] > 0 then
				bKeepThisColumn = true;
				break
			end
		end
		if bKeepThisColumn == true then
			break
		else
			adjustEast = adjustEast + 1;
		end
	end

	if adjustSouth > 0 or adjustNorth > 0 or adjustWest > 0 or adjustEast > 0 then
		-- Truncate this region to remove dead rows.
		adjusted_WestX = (iWestX + adjustWest) % iW;
		adjusted_SouthY = (iSouthY + adjustSouth) % iH;
		adjusted_Width = (iWidth - adjustWest) - adjustEast;
		adjusted_Height = (iHeight - adjustSouth) - adjustNorth;
		-- Reconstruct fertility table. This must be done row by row, so process Y coord first.
		for y = 0, adjusted_Height - 1 do
			for x = 0, adjusted_Width - 1 do
				local i = (y + adjustSouth) * iWidth + (x + adjustWest) + 1;
				local plotFert = fertility_table[i];
				table.insert(adjusted_table, plotFert);
			end
		end
		--
		print("-");
		print("Removed Dead Rows, West: ", adjustWest, " East: ", adjustEast);
		print("Removed Dead Rows, South: ", adjustSouth, " North: ", adjustNorth);
		print("-");
		print("Incoming values: ", iWestX, iSouthY, iWidth, iHeight);
		print("Outgoing values: ", adjusted_WestX, adjusted_SouthY, adjusted_Width, adjusted_Height);
		print("-");
		local incoming_index = table.maxn(fertility_table);
		local outgoing_index = table.maxn(adjusted_table);
		print("Size of incoming fertility table: ", incoming_index);
		print("Size of outgoing fertility table: ", outgoing_index);
		--
		return adjusted_table, adjusted_WestX, adjusted_SouthY, adjusted_Width, adjusted_Height;
	
	else -- Region not adjusted, return original values unaltered.
		return fertility_table, iWestX, iSouthY, iWidth, iHeight;
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:DivideIntoRegions(iNumDivisions, fertility_table, rectangle_data_table)
	-- This is a recursive algorithm. (Original concept and implementation by Ed Beach).
	--
	-- Fertility table is a plot data array including data for all plots to be processed here.
	-- The fertility table is obtained as part of the MeasureFertility functions, or via division during the recursion.
	--
	-- Rectangle table includes seven data fields:
	-- westX, southY, width, height, AreaID, fertilityCount, plotCount
	--
	-- If AreaID is -1, it means the rectangle contains fertility data from all plots regardless of their AreaIDs.
	-- The plotCount is an absolute count of plots within the rectangle, without regard to AreaID membership.
	-- This is going to purposely reduce average fertility per plot for Order-of-Assignment priority.
	-- Rectangles with a lot of non-member plots will tend to be misshapen and need to be on the favorable side of minDistance elements.
	-- print("-"); print("DivideIntoRegions called.");

	--[[ Log dump of incoming table data. Activate for debug only.
	print("Data tables passed to DivideIntoRegions.");
	PrintContentsOfTable(fertility_table)
	PrintContentsOfTable(rectangle_data_table)
	print("End of this instance, DivideIntoRegions tables.");
	]]--
	
	local iNumDivides = 0;
	local iSubdivisions = 0;
	local bPrimeGreaterThanThree = false;
	local firstSubdivisions = 0;
	local laterSubdivisions = 0;

	-- If this rectangle is not to be divided, break recursion and record the data.
	if (iNumDivisions == 1) then -- This area is to be defined as a Region.
		-- Expand rectangle table to include an eighth field for average fertility per plot.
		local fAverageFertility = rectangle_data_table[6] / rectangle_data_table[7]; -- fertilityCount/plotCount
		table.insert(rectangle_data_table, fAverageFertility);
		-- Insert this record in to the instance data for start placement regions for this game.
		-- (This is the crux of the entire regional definition process, determining an actual region.)
		table.insert(self.regionData, rectangle_data_table);
		--
		local iNumberOfThisRegion = table.maxn(self.regionData);
		print("-");
		print("---------------------------------------------");
		print("Defined location of Start Region #", iNumberOfThisRegion);
		print("---------------------------------------------");
		print("-");
		--
		return

	--[[ Divide this rectangle into iNumDivisions worth of subdivisions, then send each
	     subdivision back through this function in a recursive loop. ]]--
	elseif (iNumDivisions > 1) then
		-- See if region is taller or wider.
		local iWidth = rectangle_data_table[3];
		local iHeight = rectangle_data_table[4];
		local bTaller = false;
		if iHeight > iWidth then
			bTaller = true;
		end

		-- If the number of divisions is 2 or 3, no further subdivision is required.
		if (iNumDivisions == 2) then
			iNumDivides = 2;
			iSubdivisions = 1;
		elseif (iNumDivisions == 3) then
			iNumDivides = 3;
			iSubdivisions = 1;
		
		-- If the number of divisions is greater than 3 and a prime number,
		-- divide all of these cases in to an odd plus an even number, then subdivide.
		--
		--[[ Ed's original algorithm skipped this step and produced "extra" divisions,
		     which I would have had to account for. I decided it was far far easier to
		     improve the algorithm and remove all extra divisions than it was to have
		     to write large chunks of code trying to process empty regions. Not to 
		     mention the added precision of using all land on the continent or map to
		     determine where to place major civilizations.  - Bob Thomas, April 2010 ]]--
		elseif (iNumDivisions == 5) then
			bPrimeGreaterThanThree = true;
			chopPercent = 59.2; -- These chopPercents are all set to undershoot slightly, averaging out the actual result closer to target.
			firstSubdivisions = 3; -- This is because if you aim for the exact target, there is never undershoot and almost always overshoot.
			laterSubdivisions = 2; -- So a well calibrated target ends up compensating for that overshoot factor, to improve total fairness.
		elseif (iNumDivisions == 7) then
			bPrimeGreaterThanThree = true;
			chopPercent = 42.2;
			firstSubdivisions = 3;
			laterSubdivisions = 4;
		elseif (iNumDivisions == 11) then
			bPrimeGreaterThanThree = true;
			chopPercent = 27;
			firstSubdivisions = 3;
			laterSubdivisions = 8;
		elseif (iNumDivisions == 13) then
			bPrimeGreaterThanThree = true;
			chopPercent = 38.1;
			firstSubdivisions = 5;
			laterSubdivisions = 8;
		elseif (iNumDivisions == 17) then
			bPrimeGreaterThanThree = true;
			chopPercent = 52.8;
			firstSubdivisions = 9;
			laterSubdivisions = 8;
		elseif (iNumDivisions == 19) then
			bPrimeGreaterThanThree = true;
			chopPercent = 36.7;
			firstSubdivisions = 7;
			laterSubdivisions = 12;

		-- If the number of divisions is greater than 3 and not a prime number,
		-- then chop this rectangle in to 2 or 3 parts and subdivide those.
		elseif (iNumDivisions == 4) then
			iNumDivides = 2;
			iSubdivisions = 2;
		elseif (iNumDivisions == 6) then
			iNumDivides = 3;
			iSubdivisions = 2;
		elseif (iNumDivisions == 8) then
			iNumDivides = 2;
			iSubdivisions = 4;
		elseif (iNumDivisions == 9) then
			iNumDivides = 3;
			iSubdivisions = 3;
		elseif (iNumDivisions == 10) then
			iNumDivides = 2;
			iSubdivisions = 5;
		elseif (iNumDivisions == 12) then
			iNumDivides = 3;
			iSubdivisions = 4;
		elseif (iNumDivisions == 14) then
			iNumDivides = 2;
			iSubdivisions = 7;
		elseif (iNumDivisions == 15) then
			iNumDivides = 3;
			iSubdivisions = 5;
		elseif (iNumDivisions == 16) then
			iNumDivides = 2;
			iSubdivisions = 8;
		elseif (iNumDivisions == 18) then
			iNumDivides = 3;
			iSubdivisions = 6;
		elseif (iNumDivisions == 20) then
			iNumDivides = 2;
			iSubdivisions = 10;
		elseif (iNumDivisions == 21) then
			iNumDivides = 3;
			iSubdivisions = 7;
		elseif (iNumDivisions == 22) then
			iNumDivides = 2;
			iSubdivisions = 11;
		else
			print("Erroneous number of regional divisions : ", iNumDivisions);
		end

		-- Now process the division via one of the three methods.
		-- All methods involve recursion, to obtain the best manner of subdividing each rectangle involved.
		if bPrimeGreaterThanThree then
			print("DivideIntoRegions: Uneven Division for handling prime numbers selected.");
			local results = self:ChopIntoTwoRegions(fertility_table, rectangle_data_table, bTaller, chopPercent);
			local first_section_fertility_table = results[1];
			local first_section_data_table = results[2];
			local second_section_fertility_table = results[3];
			local second_section_data_table = results[4];
			--
			self:DivideIntoRegions(firstSubdivisions, first_section_fertility_table, first_section_data_table)
			self:DivideIntoRegions(laterSubdivisions, second_section_fertility_table, second_section_data_table)

		else
			if (iNumDivides == 2) then
				print("DivideIntoRegions: Divide in to Halves selected.");
				local results = self:ChopIntoTwoRegions(fertility_table, rectangle_data_table, bTaller, 49.5); -- Undershoot by design, to compensate for inevitable overshoot. Gets the actual result closer to target.
				local first_section_fertility_table = results[1];
				local first_section_data_table = results[2];
				local second_section_fertility_table = results[3];
				local second_section_data_table = results[4];
				--
				self:DivideIntoRegions(iSubdivisions, first_section_fertility_table, first_section_data_table)
				self:DivideIntoRegions(iSubdivisions, second_section_fertility_table, second_section_data_table)

			elseif (iNumDivides == 3) then
				print("DivideIntoRegions: Divide in to Thirds selected.");
				local results = self:ChopIntoThreeRegions(fertility_table, rectangle_data_table, bTaller);
				local first_section_fertility_table = results[1];
				local first_section_data_table = results[2];
				local second_section_fertility_table = results[3];
				local second_section_data_table = results[4];
				local third_section_fertility_table = results[5];
				local third_section_data_table = results[6];
				--
				self:DivideIntoRegions(iSubdivisions, first_section_fertility_table, first_section_data_table)
				self:DivideIntoRegions(iSubdivisions, second_section_fertility_table, second_section_data_table)
				self:DivideIntoRegions(iSubdivisions, third_section_fertility_table, third_section_data_table)

			else
				print("Invalid iNumDivides value (from DivideIntoRegions): must be 2 or 3.");
			end
		end
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:ChopIntoThreeRegions(fertility_table, rectangle_data_table, bTaller, chopPercent)
	print("-"); print("ChopIntoThree called.");
	-- Performs the mechanics of dividing a region into three roughly equal fertility subregions.
	local results = {};

	-- Chop off the first third.
	local initial_results = self:ChopIntoTwoRegions(fertility_table, rectangle_data_table, bTaller, 33); -- Undershoot by a bit, tends to make the actual result closer to accurate.
	-- add first subdivision to results
	local temptable = initial_results[1];
	table.insert(results, temptable); 

	--[[ Activate table printouts for debug purposes only, then deactivate when done. ]]--
	--print("Data returned to ChopIntoThree from ChopIntoTwo.");
	--PrintContentsOfTable(temptable)

	local temptable = initial_results[2];
	table.insert(results, temptable);

	--PrintContentsOfTable(temptable)

	-- Prepare the remainder for further processing.
	local second_section_fertility_table = initial_results[3]; 

	--PrintContentsOfTable(second_section_fertility_table)

	local second_section_data_table = initial_results[4];

	--PrintContentsOfTable(second_section_data_table)
	--print("End of this instance, ChopIntoThree tables.");

	-- See if this piece is taller or wider. (Ed's original implementation skipped this step).
	local bTallerForRemainder = false;
	local width = second_section_data_table[3];
	local height = second_section_data_table[4];
	if height > width then
		bTallerForRemainder = true;
	end

	-- Chop the bigger piece in half.		
	local interim_results = self:ChopIntoTwoRegions(second_section_fertility_table, second_section_data_table, bTallerForRemainder, 48.5); -- Undershoot just a little.
	table.insert(results, interim_results[1]); 
	table.insert(results, interim_results[2]); 
	table.insert(results, interim_results[3]); 
	table.insert(results, interim_results[4]); 

	--[[ Returns a table of six entries, each of which is a nested table.
	1: fertility_table of first subdivision
	2: rectangle_data_table of first subdivision.
	3: fertility_table of second subdivision
	4: rectangle_data_table of second subdivision.
	5: fertility_table of third subdivision
	6: rectangle_data_table of third subdivision.  ]]--
	return results
end
------------------------------------------------------------------------------
function AssignStartingPlots:ChopIntoTwoRegions(fertility_table, rectangle_data_table, bTaller, chopPercent)
	-- Performs the mechanics of dividing a region into two subregions.
	--
	-- Fertility table is a plot data array including data for all plots to be processed here.
	-- This data already factors any need for processing AreaID.
	--
	-- Rectangle table includes seven data fields:
	-- westX, southY, width, height, AreaID, fertilityCount, plotCount
	--print("-"); print("ChopIntoTwo called.");

	--[[ Log dump of incoming table data. Activate for debug only.
	print("Data tables passed to ChopIntoTwoRegions.");
	PrintContentsOfTable(fertility_table)
	PrintContentsOfTable(rectangle_data_table)
	print("End of this instance, ChopIntoTwoRegions tables.");
	]]--

	-- Read the incoming data table.
	local iW, iH = Map.GetGridSize()
	local iWestX = rectangle_data_table[1];
	local iSouthY = rectangle_data_table[2];
	local iRectWidth = rectangle_data_table[3];
	local iRectHeight = rectangle_data_table[4];
	local iAreaID = rectangle_data_table[5];
	local iTargetFertility = rectangle_data_table[6] * chopPercent / 100;
	
	-- Now divide the region.
	--
	-- West and South edges remain the same for first region.
	local firstRegionWestX = iWestX;
	local firstRegionSouthY = iSouthY;
	-- scope variables that get decided conditionally.
	local firstRegionWidth, firstRegionHeight;
	local secondRegionWestX, secondRegionSouthY, secondRegionWidth, secondRegionHeight;
	local iFirstRegionFertility = 0;
	local iSecondRegionFertility = 0;
	local region_one_fertility = {};
	local region_two_fertility = {};

	if (bTaller) then -- We will divide horizontally, resulting in first region on bottom, second on top.
		--
		-- Width for both will remain the same as the parent rectangle.
		firstRegionWidth = iRectWidth;
		secondRegionWestX = iWestX;
		secondRegionWidth = iRectWidth;

		-- Measure one row at a time, moving up from bottom, until we have exceeded the target fertility.
		local reachedTargetRow = false;
		local rectY = 0;
		while reachedTargetRow == false do
			-- Process the next row in line.
			for rectX = 0, iRectWidth - 1 do
				local fertIndex = rectY * iRectWidth + rectX + 1;
				local plotFertility = fertility_table[fertIndex];
				-- Add this plot's fertility to the region total so far.
				iFirstRegionFertility = iFirstRegionFertility + plotFertility;
				-- Record this plot in a new fertility table. (Needed for further subdivisions).
				-- Note, building this plot data table incrementally, so it must go row by row.
				table.insert(region_one_fertility, plotFertility);
			end
			if iFirstRegionFertility >= iTargetFertility then
				-- This row has completed the region.
				firstRegionHeight = rectY + 1;
				secondRegionSouthY = (iSouthY + rectY + 1) % iH;
				secondRegionHeight = iRectHeight - firstRegionHeight;
				reachedTargetRow = true;
				break
			else
				rectY = rectY + 1;
			end
		end
		
		-- Debug printout of division location.
		print("Dividing along horizontal line between rows: ", secondRegionSouthY - 1, "-", secondRegionSouthY);
		
		-- Create the fertility table for the second region, the one on top.
		-- Data must be added row by row, to keep the table index behavior consistent.
		for rectY = firstRegionHeight, iRectHeight - 1 do
			for rectX = 0, iRectWidth - 1 do
				local fertIndex = rectY * iRectWidth + rectX + 1;
				local plotFertility = fertility_table[fertIndex];
				-- Add this plot's fertility to the region total so far.
				iSecondRegionFertility = iSecondRegionFertility + plotFertility;
				-- Record this plot in a new fertility table. (Needed for further subdivisions).
				-- Note, building this plot data table incrementally, so it must go row by row.
				table.insert(region_two_fertility, plotFertility);
			end
		end
				
	else -- We will divide vertically, resulting in first region on left, second on right.
		--
		-- Height for both will remain the same as the parent rectangle.
		firstRegionHeight = iRectHeight;
		secondRegionSouthY = iSouthY;
		secondRegionHeight = iRectHeight;
		
		--[[ First region's new fertility table will be a little tricky. We don't know how many 
		     table entries it will need beforehand, and we cannot add the entries sequentially
		     when the data is being generated column by column, yet the table index needs to 
		     proceed row by row. So we will have to make a second pass.  ]]--

		-- Measure one column at a time, moving left to right, until we have exceeded the target fertility.
		local reachedTargetColumn = false;
		local rectX = 0;
		while reachedTargetColumn == false do
			-- Process the next column in line.
			for rectY = 0, iRectHeight - 1 do
				local fertIndex = rectY * iRectWidth + rectX + 1;
				local plotFertility = fertility_table[fertIndex];
				-- Add this plot's fertility to the region total so far.
				iFirstRegionFertility = iFirstRegionFertility + plotFertility;
				-- No table record here, handle later row by row.
			end
			if iFirstRegionFertility >= iTargetFertility then
				-- This column has completed the region.
				firstRegionWidth = rectX + 1;
				secondRegionWestX = (iWestX + rectX + 1) % iW;
				secondRegionWidth = iRectWidth - firstRegionWidth;
				reachedTargetColumn = true;
				break
			else
				rectX = rectX + 1;
			end
		end

		-- Debug printout of division location.
		print("Dividing along vertical line between columns: ", secondRegionWestX - 1, "-", secondRegionWestX);

		-- Create the fertility table for the second region, the one on the right.
		-- Data must be added row by row, to keep the table index behavior consistent.
		for rectY = 0, iRectHeight - 1 do
			for rectX = firstRegionWidth, iRectWidth - 1 do
				local fertIndex = rectY * iRectWidth + rectX + 1;
				local plotFertility = fertility_table[fertIndex];
				-- Add this plot's fertility to the region total so far.
				iSecondRegionFertility = iSecondRegionFertility + plotFertility;
				-- Record this plot in a new fertility table. (Needed for further subdivisions).
				-- Note, building this plot data table incrementally, so it must go row by row.
				table.insert(region_two_fertility, plotFertility);
			end
		end
		-- Now create the fertility table for the first region.
		for rectY = 0, iRectHeight - 1 do
			for rectX = 0, firstRegionWidth - 1 do
				local fertIndex = rectY * iRectWidth + rectX + 1;
				local plotFertility = fertility_table[fertIndex];
				table.insert(region_one_fertility, plotFertility);
			end
		end
	end
	
	-- Now check the newly divided regions for dead rows (all zero values) along
	-- the edges and remove any found.
	--
	-- First region
	local FRFertT, FRWX, FRSY, FRWid, FRHei;
	FRFertT, FRWX, FRSY, FRWid, FRHei = self:RemoveDeadRows(region_one_fertility,
		firstRegionWestX, firstRegionSouthY, firstRegionWidth, firstRegionHeight);
	--
	-- Second region
	local SRFertT, SRWX, SRSY, SRWid, SRHei;
	SRFertT, SRWX, SRSY, SRWid, SRHei = self:RemoveDeadRows(region_two_fertility,
		secondRegionWestX, secondRegionSouthY, secondRegionWidth, secondRegionHeight);
	--
	
	-- Generate the data tables that record the location of the new subdivisions.
	local firstPlots = FRWid * FRHei;
	local secondPlots = SRWid * SRHei;
	local region_one_data = {FRWX, FRSY, FRWid, FRHei, iAreaID, iFirstRegionFertility, firstPlots};
	local region_two_data = {SRWX, SRSY, SRWid, SRHei, iAreaID, iSecondRegionFertility, secondPlots};
	-- Generate the final data.
	local outcome = {FRFertT, region_one_data, SRFertT, region_two_data};
	return outcome
end
------------------------------------------------------------------------------
function AssignStartingPlots:CustomOverride()
	-- This function allows an easy entry point for overrides that need to 
	-- take place after regional division, but before anything else.
end
------------------------------------------------------------------------------
function AssignStartingPlots:GenerateRegions(args)
	print("Map Generation - Dividing the map in to Regions");
	-- This function stores its data in the instance (self) data table.
	--
	-- The "Three Methods" of regional division:
	-- 1. Biggest Landmass: All civs start on the biggest landmass.
	-- 2. Continental: Civs are assigned to continents. Any continents with more than one civ are divided.
	-- 3. Rectangular: Civs start within a given rectangle that spans the whole map, without regard to landmass sizes.
	--                 This method is primarily applied to Archipelago and other maps with lots of tiny islands.
	-- 4. Rectangular: Civs start within a given rectangle defined by arguments passed in on the function call.
	--                 Arguments required for this method: iWestX, iSouthY, iWidth, iHeight
	local args = args or {};
	local iW, iH = Map.GetGridSize();
	self.method = args.method or self.method; -- Continental method is default.
	self.resource_setting = args.resources or 2; -- Each map script has to pass in parameter for Resource setting chosen by user.

	-- Adjust appearance rate per Resource Setting chosen by user.
	if self.resource_setting == 1 then -- Sparse, so increase the number of tiles per bonus.
		self.bonus_multiplier = 1.5;
	elseif self.resource_setting == 3 then -- Abundant, so reduce the number of tiles per bonus.
		self.bonus_multiplier = 0.66667;
	end

	-- Determine number of civilizations and city states present in this game.
	self.iNumCivs, self.iNumCityStates, self.player_ID_list, self.bTeamGame, self.teams_with_major_civs, self.number_civs_per_team = GetPlayerAndTeamInfo()
	self.iNumCityStatesUnassigned = self.iNumCityStates;
	print("-"); print("Civs:", self.iNumCivs); print("City States:", self.iNumCityStates);

	if self.method == 1 then -- Biggest Landmass
		-- Identify the biggest landmass.
		local biggest_area = Map.FindBiggestArea(False);
		local iAreaID = biggest_area:GetID();
		-- We'll need all eight data fields returned in the results table from the boundary finder:
		local landmass_data = ObtainLandmassBoundaries(iAreaID);
		local iWestX = landmass_data[1];
		local iSouthY = landmass_data[2];
		local iEastX = landmass_data[3];
		local iNorthY = landmass_data[4];
		local iWidth = landmass_data[5];
		local iHeight = landmass_data[6];
		local wrapsX = landmass_data[7];
		local wrapsY = landmass_data[8];
		
		-- Obtain "Start Placement Fertility" of the landmass. (This measurement is customized for start placement).
		-- This call returns a table recording fertility of all plots within a rectangle that contains the landmass,
		-- with a zero value for any plots not part of the landmass -- plus a fertility sum and plot count.
		local fert_table, fertCount, plotCount = self:MeasureStartPlacementFertilityOfLandmass(iAreaID, 
		                                         iWestX, iEastX, iSouthY, iNorthY, wrapsX, wrapsY);
		-- Now divide this landmass in to regions, one per civ.
		-- The regional divider requires three arguments:
		-- 1. Number of divisions. (For "Biggest Landmass" this means number of civs in the game).
		-- 2. Fertility table. (This was obtained from the last call.)
		-- 3. Rectangle table. This table includes seven data fields:
		-- westX, southY, width, height, AreaID, fertilityCount, plotCount
		-- This is why we got the fertCount and plotCount from the fertility function.
		--
		-- Assemble the Rectangle data table:
		local rect_table = {iWestX, iSouthY, iWidth, iHeight, iAreaID, fertCount, plotCount};
		-- The data from this call is processed in to self.regionData during the process.
		self:DivideIntoRegions(self.iNumCivs, fert_table, rect_table)
		-- The regions have been defined.

	elseif self.method == 3 or self.method == 4 then -- Rectangular
		-- Obtain the boundaries of the rectangle to be processed.
		-- If no coords were passed via the args table, default to processing the entire map.
		-- Note that it matters if method 3 or 4 is designated, because the difference affects
		-- how city states are placed, whether they look for any uninhabited lands outside the rectangle.
		self.inhabited_WestX = args.iWestX or 0;
		self.inhabited_SouthY = args.iSouthY or 0;
		self.inhabited_Width = args.iWidth or iW;
		self.inhabited_Height = args.iHeight or iH;


		-- Obtain "Start Placement Fertility" inside the rectangle.
		-- Data returned is: fertility table, sum of all fertility, plot count.
		local fert_table, fertCount, plotCount = self:MeasureStartPlacementFertilityInRectangle(self.inhabited_WestX, 
		                                         self.inhabited_SouthY, self.inhabited_Width, self.inhabited_Height)
		-- Assemble the Rectangle data table:
		local rect_table = {self.inhabited_WestX, self.inhabited_SouthY, self.inhabited_Width, 
		                    self.inhabited_Height, -1, fertCount, plotCount}; -- AreaID -1 means ignore area IDs.
		-- Divide the rectangle.
		self:DivideIntoRegions(self.iNumCivs, fert_table, rect_table)
		-- The regions have been defined.
	elseif  self.method == 5 then -- Whole Map
		
		-- We'll need all eight data fields returned in the results table from the boundary finder:
		local iWestX = 0;
		local iSouthY =  0;
		local iEastX = iW;
		local iNorthY = iH;
		-- Assemble the Rectangle data table:
		local fert_table, fertCount, plotCount = self:MeasureStartPlacementFertilityOfMap( 
		                                         iWestX, iEastX, iSouthY, iNorthY);

		local rect_table = {iWestX, iSouthY, iW, iH, -1, fertCount, plotCount};
		-- The data from this call is processed in to self.regionData during the process.
		self:DivideIntoRegions(self.iNumCivs, fert_table, rect_table)
		-- The regions have been defined.
	else -- Continental.
		--[[ Loop through all plots on the map, measuring fertility of each land 
		     plot, identifying its AreaID, building a list of landmass AreaIDs, and
		     tallying the Start Placement Fertility for each landmass. ]]--

		-- region_data: [WestX, EastX, SouthY, NorthY, 
		-- numLandPlotsinRegion, numCoastalPlotsinRegion,
		-- numOceanPlotsinRegion, iRegionNetYield, 
		-- iNumLandAreas, iNumPlotsinRegion]
		local best_areas = {};
		local globalFertilityOfLands = {};

		-- Obtain info on all landmasses for comparision purposes.
		local iGlobalFertilityOfLands = 0;
		local iNumLandPlots = 0;
		local iNumLandAreas = 0;
		local land_area_IDs = {};
		local land_area_plots = {};
		local land_area_fert = {};
		-- Cycle through all plots in the world, checking their Start Placement Fertility and AreaID.
		for x = 0, iW - 1 do
			for y = 0, iH - 1 do
				local i = y * iW + x + 1;
				local plot = Map.GetPlot(x, y);
				if not plot:IsWater() then -- Land plot, process it.
					iNumLandPlots = iNumLandPlots + 1;
					local iArea = plot:GetArea();
					local plotFertility = self:MeasureStartPlacementFertilityOfPlot(x, y); -- Check for coastal land is enabled.
					iGlobalFertilityOfLands = iGlobalFertilityOfLands + plotFertility;
					--
					if TestMembership(land_area_IDs, iArea) == false then -- This plot is the first detected in its AreaID.
						iNumLandAreas = iNumLandAreas + 1;
						table.insert(land_area_IDs, iArea);
						land_area_plots[iArea] = 1;
						land_area_fert[iArea] = plotFertility;
					else -- This AreaID already known.
						land_area_plots[iArea] = land_area_plots[iArea] + 1;
						land_area_fert[iArea] = land_area_fert[iArea] + plotFertility;
					end
				end
			end
		end
		
		--[[ Debug printout
		print("* * * * * * * * * *");
		for area_loop, AreaID in ipairs(land_area_IDs) do
			print("Area ID " .. AreaID .. " is land.");
		end ]]--
		print("* * * * * * * * * *");
		for AreaID, fert in pairs(land_area_fert) do
			print("Area ID " .. AreaID .. " has fertility of " .. fert);
		end
		print("* * * * * * * * * *");
		--		
		
		-- Sort areas, achieving a list of AreaIDs with best areas first.
		--
		-- Fertility data in land_area_fert is stored with areaID index keys.
		-- Need to generate a version of this table with indices of 1 to n, where n is number of land areas.
		local interim_table = {};
		for loop_index, data_entry in pairs(land_area_fert) do
			table.insert(interim_table, data_entry);
		end
		
		--[[for AreaID, fert in ipairs(interim_table) do
			print("Interim Table ID " .. AreaID .. " has fertility of " .. fert);
		end
		print("* * * * * * * * * *"); ]]--
		
		-- Sort the fertility values stored in the interim table. Sort order in Lua is lowest to highest.
		table.sort(interim_table);

		for AreaID, fert in ipairs(interim_table) do
			print("Interim Table ID " .. AreaID .. " has fertility of " .. fert);
		end
		print("* * * * * * * * * *");

		-- If less players than landmasses, we will ignore the extra landmasses.
		local iNumRelevantLandAreas = math.min(iNumLandAreas, self.iNumCivs);
		-- Now re-match the AreaID numbers with their corresponding fertility values
		-- by comparing the original fertility table with the sorted interim table.
		-- During this comparison, best_areas will be constructed from sorted AreaIDs, richest stored first.
		local best_areas = {};
		-- Currently, the best yields are at the end of the interim table. We need to step backward from there.
		local end_of_interim_table = table.maxn(interim_table);
		-- We may not need all entries in the table. Process only iNumRelevantLandAreas worth of table entries.
		local fertility_value_list = {};
		local fertility_value_tie = false;
		for tableConstructionLoop = end_of_interim_table, (end_of_interim_table - iNumRelevantLandAreas + 1), -1 do
			if TestMembership(fertility_value_list, interim_table[tableConstructionLoop]) == true then
				fertility_value_tie = true;
				print("*** WARNING: Fertility Value Tie exists! ***");
			else
				table.insert(fertility_value_list, interim_table[tableConstructionLoop]);
			end
		end

		if fertility_value_tie == false then -- No ties, so no need of special handling for ties.
			for areaTestLoop = end_of_interim_table, (end_of_interim_table - iNumRelevantLandAreas + 1), -1 do
				for loop_index, AreaID in ipairs(land_area_IDs) do
					if interim_table[areaTestLoop] == land_area_fert[land_area_IDs[loop_index]] then
						table.insert(best_areas, AreaID);
						break
					end
				end
			end
		else -- Ties exist! Special handling required to protect against a shortfall in the number of defined regions.
			local iNumUniqueFertValues = table.maxn(fertility_value_list);
			for fertLoop = 1, iNumUniqueFertValues do
				for AreaID, fert in pairs(land_area_fert) do
					if fert == fertility_value_list[fertLoop] then
						-- Add ties only if there is room!
						local best_areas_length = table.maxn(best_areas);
						if best_areas_length < iNumRelevantLandAreas then
							table.insert(best_areas, AreaID);
						else
							break
						end
					end
				end
			end
		end
				
		-- Debug printout
		print("-"); print("--- Continental Division, Initial Readout ---"); print("-");
		print("- Global Fertility:", iGlobalFertilityOfLands);
		print("- Total Land Plots:", iNumLandPlots);
		print("- Total Areas:", iNumLandAreas);
		print("- Relevant Areas:", iNumRelevantLandAreas); print("-");
		--

		-- Debug printout
		print("* * * * * * * * * *");
		for area_loop, AreaID in ipairs(best_areas) do
			print("Area ID " .. AreaID .. " has fertility of " .. land_area_fert[AreaID]);
		end
		print("* * * * * * * * * *");
		--

		-- Assign continents to receive start plots. Record number of civs assigned to each landmass.
		local inhabitedAreaIDs = {};
		local numberOfCivsPerArea = table.fill(0, iNumRelevantLandAreas); -- Indexed in synch with best_areas. Use same index to match values from each table.
		for civToAssign = 1, self.iNumCivs do
			local bestRemainingArea;
			local bestRemainingFertility = 0;
			local bestAreaTableIndex;
			-- Loop through areas, find the one with the best remaining fertility (civs added 
			-- to a landmass reduces its fertility rating for subsequent civs).
			--
			print("- - Searching landmasses in order to place Civ #", civToAssign); print("-");
			for area_loop, AreaID in ipairs(best_areas) do
				local thisLandmassCurrentFertility = land_area_fert[AreaID] / (1 + numberOfCivsPerArea[area_loop]);
				if thisLandmassCurrentFertility > bestRemainingFertility then
					bestRemainingArea = AreaID;
					bestRemainingFertility = thisLandmassCurrentFertility;
					bestAreaTableIndex = area_loop;
					--
					print("- Found new candidate landmass with Area ID#:", bestRemainingArea, " with fertility of ", bestRemainingFertility);
				end
			end
			-- Record results for this pass. (A landmass has been assigned to receive one more start point than it previously had).
			numberOfCivsPerArea[bestAreaTableIndex] = numberOfCivsPerArea[bestAreaTableIndex] + 1;
			if TestMembership(inhabitedAreaIDs, bestRemainingArea) == false then
				table.insert(inhabitedAreaIDs, bestRemainingArea);
			end
			print("Civ #", civToAssign, "has been assigned to Area#", bestRemainingArea); print("-");
		end
		print("-"); print("--- End of Initial Readout ---"); print("-");
		
		print("*** Number of Civs per Landmass - Table Readout ***");
		PrintContentsOfTable(numberOfCivsPerArea)
		print("--- End of Civs per Landmass readout ***"); print("-"); print("-");
				
		-- Loop through the list of inhabited landmasses, dividing each landmass in to regions.
		-- Note that it is OK to divide a continent with one civ on it: this will assign the whole
		-- of the landmass to a single region, and is the easiest method of recording such a region.
		local iNumInhabitedLandmasses = table.maxn(inhabitedAreaIDs);
		for loop, currentLandmassID in ipairs(inhabitedAreaIDs) do
			-- Obtain the boundaries of and data for this landmass.
			local landmass_data = ObtainLandmassBoundaries(currentLandmassID);
			local iWestX = landmass_data[1];
			local iSouthY = landmass_data[2];
			local iEastX = landmass_data[3];
			local iNorthY = landmass_data[4];
			local iWidth = landmass_data[5];
			local iHeight = landmass_data[6];
			local wrapsX = landmass_data[7];
			local wrapsY = landmass_data[8];
			-- Obtain "Start Placement Fertility" of the current landmass. (Necessary to do this
			-- again because the fert_table can't be built prior to finding boundaries, and we had
			-- to ID the proper landmasses via fertility to be able to figure out their boundaries.
			local fert_table, fertCount, plotCount = self:MeasureStartPlacementFertilityOfLandmass(currentLandmassID, 
		  	                                         iWestX, iEastX, iSouthY, iNorthY, wrapsX, wrapsY);
			-- Assemble the rectangle data for this landmass.
			local rect_table = {iWestX, iSouthY, iWidth, iHeight, currentLandmassID, fertCount, plotCount};
			-- Divide this landmass in to number of regions equal to civs assigned here.
			iNumCivsOnThisLandmass = numberOfCivsPerArea[loop];
			if iNumCivsOnThisLandmass > 0 and iNumCivsOnThisLandmass <= 22 then -- valid number of civs.
			
				-- Debug printout for regional division inputs.
				print("-"); print("- Region #: ", loop);
				print("- Civs on this landmass: ", iNumCivsOnThisLandmass);
				print("- Area ID#: ", currentLandmassID);
				print("- Fertility: ", fertCount);
				print("- Plot Count: ", plotCount); print("-");
				--
			
				self:DivideIntoRegions(iNumCivsOnThisLandmass, fert_table, rect_table)
			else
				print("Invalid number of civs assigned to a landmass: ", iNumCivsOnThisLandmass);
			end
		end
		--
		-- The regions have been defined.
	end
	
	-- Entry point for easier overrides.
	self:CustomOverride()
	
	-- Printout is for debugging only. Deactivate otherwise.
	local tempRegionData = self.regionData;
	for i, data in ipairs(tempRegionData) do
		print("-");
		print("Data for Start Region #", i);
		print("WestX:  ", data[1]);
		print("SouthY: ", data[2]);
		print("Width:  ", data[3]);
		print("Height: ", data[4]);
		print("AreaID: ", data[5]);
		print("Fertility:", data[6]);
		print("Plots:  ", data[7]);
		print("Fert/Plot:", data[8]);
		print("-");
	end
	--
end
------------------------------------------------------------------------------
-- Start of functions tied to ChooseLocations()
------------------------------------------------------------------------------
function AssignStartingPlots:IdentifyWildAreas()
	-- NOTE: Any value above zero will flag a plot as Wild Area for this function, causing it to be
	-- avoided by start locations. Any Wild Area types that are not intended to be avoided by start
	-- areas should wait until after start locations have been set to be added.
	local iW, iH = Map.GetGridSize();
	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local plot = Map.GetPlot(x, y)
				local wild_value = plot:GetWildness()
				if wild_value > 0 then -- Plot is Wild Area.
					local i = y * iW + x + 1;
					self.wild_area_plots[i] = true; -- Record the plot as a Wild Area plot.
				end
		end
	end
end
------------------------------------------------------------------------------
-- Table of Wildness Values assigned during Map Generation
-- Last Updated - 5/9/2014 - by Bob Thomas
-- 
-- 10: Forest Core Plot
-- 11: Forest Periphery Plot
-- 
-- 20: Desert Core Plot
-- 21: Desert Periphery Plot
-- 
-- 30: Tundra Core Plot
-- 31: Tundra Periphery Plot
-- 
-- 40: Ocean Core Plot
-- 41: Ocean Periphery Plot
-- 
-- NOTE: These values carry meaning only in so far as they communicate details
-- about the map to the main game core and the AI. Only values understood by
-- the game core and the AI will actually create any results. To modify or add
-- to this list, changes must be made in both the game core and map generation.
------------------------------------------------------------------------------
function AssignStartingPlots:WildAreasImpactLayer()
	-- This function generates an "impact and ripple" data overlay for Wild
	-- Areas. We want start locations to avoid Wild Areas, but not at all costs,
	-- so an impact layer is being set up.
	--
	-- Choosing which Wildness values count toward this process is done in
	-- self:IdentifyWildAreas(). By default, it counts all Wildness values in
	-- place at the time. While this could be overridden, doing it this way 
	-- allows map scripts to identify which Wildness values that start locations
	-- should avoid by setting up specific Wildness values before or after start
	-- locations are selected. This is the recommended procedure.
	--
	local iW, iH = Map.GetGridSize();
	local wrapX = Map:IsWrapX();
	local wrapY = Map:IsWrapY();
	local core_impact_value = 105;
	local core_ripple_values = {12, 8, 5, 4, 3, 2};
	local periphery_impact_value = 35;
	local periphery_ripple_values = {5, 4, 3, 2};
	local odd = self.firstRingYIsOdd;
	local even = self.firstRingYIsEven;
	local nextX, nextY, plot_adjustments;
	
	-- Iterate through all plots and place impacts for any Wild Areas plots found.
	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local i = y * iW + x + 1;
			local plot = Map.GetPlot(x, y)
			local wild_value = plot:GetWildness()
			if wild_value == 10 or wild_value == 20 or wild_value == 30 then -- Core plot of land-based wild area.
				local previous_value = self.wildData[i];
				self.wildData[i] = math.min(core_impact_value + previous_value, 199);
				for ripple_radius, ripple_value in ipairs(core_ripple_values) do
					-- Moving clockwise around the ring, the first direction to travel will be Northeast.
					-- This matches the direction-based data in the odd and even tables. Each
					-- subsequent change in direction will correctly match with these tables, too.
					--
					-- Locate the plot within this ripple ring that is due West of the Impact Plot.
					local currentX = x - ripple_radius;
					local currentY = y;
					-- Now loop through the six directions, moving ripple_radius number of times
					-- per direction. At each plot in the ring, add the ripple_value for that ring 
					-- to the plot's entry in the distance data table.
					for direction_index = 1, 6 do
						for plot_to_handle = 1, ripple_radius do
							-- Must account for hex factor.
							if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
								plot_adjustments = odd[direction_index];
							else -- Current Y is even. Use plot adjustments from even table.
								plot_adjustments = even[direction_index];
							end
							-- Identify the next plot in the ring.
							nextX = currentX + plot_adjustments[1];
							nextY = currentY + plot_adjustments[2];
							-- Make sure the plot exists
							if wrapX == false and (nextX < 0 or nextX >= iW) then -- X is out of bounds.
								-- Do not add ripple data to this plot.
							elseif wrapY == false and (nextY < 0 or nextY >= iH) then -- Y is out of bounds.
								-- Do not add ripple data to this plot.
							else -- Plot is in bounds, process it.
								-- Handle any world wrap.
								local realX = nextX;
								local realY = nextY;
								if wrapX then
									realX = realX % iW;
								end
								if wrapY then
									realY = realY % iH;
								end
								-- Record ripple data for this plot.
								local ringPlotIndex = realY * iW + realX + 1;
								local ring_previous = self.wildData[ringPlotIndex];
								self.wildData[ringPlotIndex] = math.min(ripple_value + ring_previous, 199);
							end
							currentX, currentY = nextX, nextY;
						end
					end
				end
			elseif wild_value == 11 or wild_value == 21 or wild_value == 31 then -- Periphery plot of land-based wild area.
				local previous_value = self.wildData[i];
				self.wildData[i] = math.min(periphery_impact_value + previous_value, 199);
				for ripple_radius, ripple_value in ipairs(periphery_ripple_values) do
					-- Moving clockwise around the ring, the first direction to travel will be Northeast.
					-- This matches the direction-based data in the odd and even tables. Each
					-- subsequent change in direction will correctly match with these tables, too.
					--
					-- Locate the plot within this ripple ring that is due West of the Impact Plot.
					local currentX = x - ripple_radius;
					local currentY = y;
					-- Now loop through the six directions, moving ripple_radius number of times
					-- per direction. At each plot in the ring, add the ripple_value for that ring 
					-- to the plot's entry in the distance data table.
					for direction_index = 1, 6 do
						for plot_to_handle = 1, ripple_radius do
							-- Must account for hex factor.
							if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
								plot_adjustments = odd[direction_index];
							else -- Current Y is even. Use plot adjustments from even table.
								plot_adjustments = even[direction_index];
							end
							-- Identify the next plot in the ring.
							nextX = currentX + plot_adjustments[1];
							nextY = currentY + plot_adjustments[2];
							-- Make sure the plot exists
							if wrapX == false and (nextX < 0 or nextX >= iW) then -- X is out of bounds.
								-- Do not add ripple data to this plot.
							elseif wrapY == false and (nextY < 0 or nextY >= iH) then -- Y is out of bounds.
								-- Do not add ripple data to this plot.
							else -- Plot is in bounds, process it.
								-- Handle any world wrap.
								local realX = nextX;
								local realY = nextY;
								if wrapX then
									realX = realX % iW;
								end
								if wrapY then
									realY = realY % iH;
								end
								-- Record ripple data for this plot.
								local ringPlotIndex = realY * iW + realX + 1;
								local ring_previous = self.wildData[ringPlotIndex];
								self.wildData[ringPlotIndex] = math.min(ripple_value + ring_previous, 199);
							end
							currentX, currentY = nextX, nextY;
						end
					end
				end
			end
		end
	end

	-- Debug Printout
	print("-"); print("----------------------------------- TABLE START --------------------------------------------"); 
	for y = iH - 1, 0, -1 do
		local print_string = "- New Row: Y = " .. y .. ": - ";
		for x = 0, iW - 1 do
			local i = y * iW + x + 1;
			print_string = print_string .. self.wildData[i] .. " ";
		end
		print(print_string); print("-");
	end
	print("----------------------------------- TABLE  END  --------------------------------------------"); print("-");
	--
  
end
------------------------------------------------------------------------------
function AssignStartingPlots:MeasureTerrainInRegions()
	local iW, iH = Map.GetGridSize();
	-- This function stores its data in the instance (self) data table.
	for region_loop, region_data_table in ipairs(self.regionData) do
		local iWestX = region_data_table[1];
		local iSouthY = region_data_table[2];
		local iWidth = region_data_table[3];
		local iHeight = region_data_table[4];
		local iAreaID = region_data_table[5];
		
		local totalPlots, areaPlots = 0, 0;
		local waterCount, flatlandsCount, hillsCount, peaksCount, canyonCount = 0, 0, 0, 0, 0;
		local lakeCount, coastCount, oceanCount, iceCount = 0, 0, 0, 0;
		local grassCount, plainsCount, desertCount, tundraCount, snowCount = 0, 0, 0, 0, 0; -- counts flatlands only!
		local forestCount, jungleCount, marshCount, riverCount, floodplainCount, oasisCount = 0, 0, 0, 0, 0, 0;
		local coastalLandCount, nextToCoastCount = 0, 0;
		local trenchCount = 0;

		-- Iterate through the region's plots, getting plotType, terrainType, featureType and river status.
		for region_loop_y = 0, iHeight - 1 do
			for region_loop_x = 0, iWidth - 1 do
				totalPlots = totalPlots + 1;
				local x = (region_loop_x + iWestX) % iW;
				local y = (region_loop_y + iSouthY) % iH;
				local plot = Map.GetPlot(x, y);
				local area_of_plot = plot:GetArea();
				-- get plot info
				local plotType = plot:GetPlotType()
				local terrainType = plot:GetTerrainType()
				local featureType = plot:GetFeatureType()
				
				-- Mountain and Ocean plot types get their own AreaIDs, but we are going to measure them anyway.
				if plotType == PlotTypes.PLOT_MOUNTAIN then
					peaksCount = peaksCount + 1; -- and that's it for Mountain plots. No other stats.
				elseif plotType == PlotTypes.PLOT_OCEAN then
					waterCount = waterCount + 1;
					if terrainType == TerrainTypes.TERRAIN_COAST then
						if plot:IsLake() then
							lakeCount = lakeCount + 1;
						else
							coastCount = coastCount + 1;
						end
					elseif terrainType == TerrainTypes.TERRAIN_TRENCH then
						trenchCount = trenchCount + 1;
					else
						oceanCount = oceanCount + 1;
					end
					if featureType == FeatureTypes.FEATURE_ICE then
						iceCount = iceCount + 1;
					end

				elseif plotType == PlotTypes.PLOT_CANYON then
					canyonCount = canyonCount + 1;

				else
					-- Hills and Flatlands, check plot for region membership. Only process this plot if it is a member.
					if (area_of_plot == iAreaID) or (iAreaID == -1) then
						areaPlots = areaPlots + 1;

						-- set up coastalLand and nextToCoast index
						local i = iW * y + x + 1;
			
						-- Record plot data
						if plotType == PlotTypes.PLOT_HILLS then
							hillsCount = hillsCount + 1;

							if self.plotDataIsCoastal[i] then
								coastalLandCount = coastalLandCount + 1;
							elseif self.plotDataIsNextToCoast[i] then
								nextToCoastCount = nextToCoastCount + 1;
							end

							if plot:IsRiverSide() then
								riverCount = riverCount + 1;
							end

							-- Feature check checking for all types, in case features are not obeying standard allowances.
							if featureType == FeatureTypes.FEATURE_FOREST then
								forestCount = forestCount + 1;
							elseif featureType == FeatureTypes.FEATURE_JUNGLE then
								jungleCount = jungleCount + 1;
							elseif featureType == FeatureTypes.FEATURE_MARSH then
								marshCount = marshCount + 1;
							elseif featureType == FeatureTypes.FEATURE_FLOODPLAIN then
								floodplainCount = floodplainCount + 1;
							--elseif featureType == FeatureTypes.FEATURE_OASIS then
								--oasisCount = oasisCount + 1;
							end
								
						else -- Flatlands plot
							flatlandsCount = flatlandsCount + 1;
	
							if self.plotDataIsCoastal[i] then
								coastalLandCount = coastalLandCount + 1;
							elseif self.plotDataIsNextToCoast[i] then
								nextToCoastCount = nextToCoastCount + 1;
							end

							if plot:IsRiverSide() then
								riverCount = riverCount + 1;
							end
				
							if terrainType == TerrainTypes.TERRAIN_GRASS then
								grassCount = grassCount + 1;
							elseif terrainType == TerrainTypes.TERRAIN_PLAINS then
								plainsCount = plainsCount + 1;
							elseif terrainType == TerrainTypes.TERRAIN_DESERT then
								desertCount = desertCount + 1;
							elseif terrainType == TerrainTypes.TERRAIN_TUNDRA then
								tundraCount = tundraCount + 1;
							elseif terrainType == TerrainTypes.TERRAIN_SNOW then
								snowCount = snowCount + 1;
							end
				
							-- Feature check checking for all types, in case features are not obeying standard allowances.
							if featureType == FeatureTypes.FEATURE_FOREST then
								forestCount = forestCount + 1;
							elseif featureType == FeatureTypes.FEATURE_JUNGLE then
								jungleCount = jungleCount + 1;
							elseif featureType == FeatureTypes.FEATURE_MARSH then
								marshCount = marshCount + 1;
							elseif featureType == FeatureTypes.FEATURE_FLOODPLAIN then
								floodplainCount = floodplainCount + 1;
							--elseif featureType == FeatureTypes.FEATURE_OASIS then
								--oasisCount = oasisCount + 1;
							end
						end
					end
				end
			end
		end
			
		-- Assemble in to an array the recorded data for this region: 24 variables.
		local regionCounts = {
			totalPlots, areaPlots,
			waterCount, flatlandsCount, hillsCount, peaksCount,
			lakeCount, coastCount, oceanCount, iceCount,
			grassCount, plainsCount, desertCount, tundraCount, snowCount,
			forestCount, jungleCount, marshCount, riverCount, floodplainCount, oasisCount,
			coastalLandCount, nextToCoastCount, canyonCount, trenchCount
			}
		--[[ Table Key:
		
		1) totalPlots
		2) areaPlots                 13) desertCount
		3) waterCount                14) tundraCount
		4) flatlandsCount            15) snowCount
		5) hillsCount                16) forestCount
		6) peaksCount                17) jungleCount
		7) lakeCount                 18) marshCount
		8) coastCount                19) riverCount
		9) oceanCount                20) floodplainCount
		10) iceCount                 21) oasisCount
		11) grassCount               22) coastalLandCount
		12) plainsCount              23) nextToCoastCount
		
		24) canyonCount   ]]--
			
		-- Add array to the data table.
		table.insert(self.regionTerrainCounts, regionCounts);
		
		--[[ Activate printout only for debugging.
		print("-");
		print("--- Region Terrain Measurements for Region #", region_loop, "---");
		print("Total Plots: ", totalPlots);
		print("Area Plots: ", areaPlots);
		print("-");
		print("Mountains: ", peaksCount, " - Cannot belong to a landmass AreaID.");
		print("Total Water Plots: ", waterCount, " - Cannot belong to a landmass AreaID.");
		print("-");
		print("Lake Plots: ", lakeCount);
		print("Coast Plots: ", coastCount, " - Does not include Lakes.");
		print("Ocean Plots: ", oceanCount);
		print("Icebergs: ", iceCount);
		print("-");
		print("Flatlands: ", flatlandsCount);
		print("Hills: ", hillsCount);
		print("-");
		print("Grass Plots: ", grassCount);
		print("Plains Plots: ", plainsCount);
		print("Desert Plots: ", desertCount);
		print("Tundra Plots: ", tundraCount);
		print("Snow Plots: ", snowCount);
		print("-");
		print("Forest Plots: ", forestCount);
		print("Jungle Plots: ", jungleCount);
		print("Marsh Plots: ", marshCount);
		print("Flood Plains: ", floodplainCount);
		print("Oases: ", oasisCount);
		print("-");
		print("Plots Along Rivers: ", riverCount);
		print("Plots Along Oceans: ", coastalLandCount);
		print("Plots Next To Plots Along Oceans: ", nextToCoastCount);
		print("-");
		print("Canyons: ", canyonCount);
		
		print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
		]]--
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:DetermineRegionTypes()
	-- Determine region type and conditions. Use self.regionTypes to store the results
	--
	-- REGION TYPES
	-- 0. Undefined
	-- 1. Tundra
	-- 2. Marsh			-- Civ:BE has no Jungles, but has more Marsh.
	-- 3. Forest
	-- 4. Desert
	-- 5. Hills
	-- 6. Plains
	-- 7. Grassland
	-- 8. Water
	-- 9. Hybrid

	local waterPlayers = 0;
	local waterPlayerList = {};
	for loop = 1, self.iNumCivs do
		local player_ID = self.player_ID_list[loop];
		local player = Players[player_ID];
		local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type;
		local bCivNeedsWaterStart = PlayerShouldStartWater(player_ID);
		if bCivNeedsWaterStart then
			table.insert(waterPlayerList , player_ID);
			print("Water Start is needed for Player", player_ID, "of Civ Type", civType);
			waterPlayers = waterPlayers + 1;
		end
	end

	-- Main loop
	for this_region, terrainCounts in ipairs(self.regionTerrainCounts) do
		-- Set each region to "Undefined Type" as default.
		-- If all efforts fail at determining what type of region this should be, region type will remain Undefined.
		--local totalPlots = terrainCounts[1];
		local areaPlots = terrainCounts[2];
		--local waterCount = terrainCounts[3];
		local flatlandsCount = terrainCounts[4];
		local hillsCount = terrainCounts[5];
		local peaksCount = terrainCounts[6];
		--local lakeCount = terrainCounts[7];
		local coastCount = terrainCounts[8];
		local oceanCount = terrainCounts[9];
		local iceCount = terrainCounts[10];
		local grassCount = terrainCounts[11];
		local plainsCount = terrainCounts[12];
		local desertCount = terrainCounts[13];
		local tundraCount = terrainCounts[14];
		local snowCount = terrainCounts[15];
		local forestCount = terrainCounts[16];
		--local jungleCount = terrainCounts[17];
		local marshCount = terrainCounts[18];
		local riverCount = terrainCounts[19];
		--local floodplainCount = terrainCounts[20];
		--local oasisCount = terrainCounts[21];
		--local coastalLandCount = terrainCounts[22];
		--local nextToCoastCount = terrainCounts[23];
		--local canyonCount = terrainCounts[24];

		-- If Rectangular regional division, then water plots would be included in area plots.
		-- Let's recalculate area plots based only on flatland and hills plots.
		if self.method == 3 or self.method == 4 then
			areaPlots = flatlandsCount + hillsCount;
		end

		-- Water check.
		if (self.method == 5 and waterPlayers >= self.water_civ_starts) then
			table.insert(self.regionTypes, 8);
			--print("-");
			--print("Region #", this_region, " has been defined as a Water Region.");
			self.water_civ_starts = self.water_civ_starts + 1;
		-- Tundra check first.
		elseif (tundraCount + snowCount) >= areaPlots * 0.4 then
			table.insert(self.regionTypes, 1);
			--print("-");
			--print("Region #", this_region, " has been defined as a Tundra Region.");
		
		-- Jungle check.
		elseif (marshCount >= areaPlots * 0.35) then
			table.insert(self.regionTypes, 2);
			--print("-");
			--print("Region #", this_region, " has been defined as a Marsh Region.");
		elseif (marshCount >= areaPlots * 0.3) and (marshCount + forestCount >= areaPlots * 0.4) then
			table.insert(self.regionTypes, 2);
			--print("-");
			--print("Region #", this_region, " has been defined as a Marsh Region.");
		
		-- Forest check.
		elseif (forestCount >= areaPlots * 0.40) then
			table.insert(self.regionTypes, 3);
			--print("-");
			--print("Region #", this_region, " has been defined as a Forest Region.");
		elseif (forestCount >= areaPlots * 0.35) and (marshCount + forestCount >= areaPlots * 0.45) then
			table.insert(self.regionTypes, 3);
			--print("-");
			--print("Region #", this_region, " has been defined as a Forest Region.");
		
		-- Desert check.
		elseif (desertCount >= areaPlots * 0.35) then
			table.insert(self.regionTypes, 4);
			--print("-");
			--print("Region #", this_region, " has been defined as a Desert Region.");

		-- Hills check.
		elseif (hillsCount >= areaPlots * 0.515) then
			table.insert(self.regionTypes, 5);
			--print("-");
			--print("Region #", this_region, " has been defined as a Hills Region.");
		
		-- Plains check.
		elseif (plainsCount >= areaPlots * 0.4) and (plainsCount * 0.8 > grassCount) then
			table.insert(self.regionTypes, 6);
			--print("-");
			--print("Region #", this_region, " has been defined as a Plains Region.");
		
		-- Grass check.
		elseif (grassCount >= areaPlots * 0.4) and (grassCount * 0.8 > plainsCount) then
			table.insert(self.regionTypes, 7);
			--print("-");
			--print("Region #", this_region, " has been defined as a Grassland Region.");

		-- Hybrid check.
		elseif ((grassCount + plainsCount + desertCount + tundraCount + snowCount + hillsCount + peaksCount) > areaPlots * 0.9) then
			table.insert(self.regionTypes, 9);
			--print("-");
			--print("Region #", this_region, " has been defined as a Hybrid Region.");
		-- Hybrid check.
		
		else -- Undefined Region (most likely due to operating on a mod that adds new terrain types.)
			table.insert(self.regionTypes, 0);
			--print("-");
			--print("Region #", this_region, " has been defined as an Undefined Region.");
		
		end
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceImpactAndRipples(x, y)
	-- This function operates upon the "impact and ripple" data overlays. This
	-- is the core version, which operates on start points. Resources and city 
	-- states have their own data layers, using this same design principle.
	-- Execution of this function handles a single start point (x, y).
	--[[ The purpose of the overlay is to strongly discourage placement of new
	     start points near already-placed start points. Each start placed makes
	     an "impact" on the map, and this impact "ripples" outward in rings, each
	     ring weaker in bias than the previous ring. ... Civ4 attempted to adjust
	     the minimum distance between civs according to a formula that factored
	     map size and number of civs in the game, but the formula was chock full 
	     of faulty assumptions, resulting in an accurate calibration rate of less
	     than ten percent. The failure of this approach is the primary reason 
	     that an all-new positioner was written for Civ5. ... Rather than repeat
	     the mistakes of the old system, in part or in whole, I have opted to go 
	     with a flat 9-tile impact crater for all map sizes and number of civs.
	     The new system will place civs at least 9 tiles away from other civs
	     whenever and wherever a reasonable candidate plot exists at this range. 
	     If a start must be found within that range, it will attempt to balance
	     quality of the location against proximity to another civ, with the bias
	     becoming very heavy inside 7 plots, and all but prohibitive inside 5.
	     The only starts that should see any Civs crowding together are those 
	     with impossible conditions such as cramming more than a dozen civs on 
	     to Tiny or Duel sized maps. ... The Impact and Ripple is aimed mostly
	     at assisting with Rectangular Method regional division on islands maps,
	     as the primary method of spacing civs is the Center Bias factor. The 
	     Impact and Ripple is a second layer of protection, for those rare cases
	     when regional shapes are severely distorted, with little to no land in
	     the region center, and the start having to be placed near the edge, and
	     for cases of extremely thin regional dimension.   ]]--
	-- To establish a bias of 9, we Impact the overlay and Ripple outward 8 times.
	-- Value of 0 in a plot means no influence from existing Impacts in that plot.
	-- Value of 99 means an Impact occurred in that plot and it IS a start point.
	-- Values > 0 and < 99 are "ripples", meaning that plot is near a start point.
	local iW, iH = Map.GetGridSize();
	local wrapX = Map:IsWrapX();
	local wrapY = Map:IsWrapY();
	local impact_value = 99;
	local ripple_values = {97, 95, 92, 89, 69, 57, 24, 15};
	local odd = self.firstRingYIsOdd;
	local even = self.firstRingYIsEven;
	local nextX, nextY, plot_adjustments;
	-- Start points need to impact the resource layers, so let's handle that first.
	self:PlaceResourceImpact(x, y, 1, 3) -- Strategic layer, at impact site only. -- BE Update: now preventing strategics from being placed randomly near starts.
	self:PlaceResourceImpact(x, y, 2, 3) -- Luxury layer, set all plots within this civ start as off limits.
	self:PlaceResourceImpact(x, y, 3, 3) -- Bonus layer
	self:PlaceResourceImpact(x, y, 4, 3) -- Fish layer
	self:PlaceResourceImpact(x, y, 6, 4) -- Natural Wonders layer, set a minimum distance of 5 plots (4 ripples) away.
	-- Now the main data layer, for start points themselves, and the City State data layer.
	-- Place Impact!
	local impactPlotIndex = y * iW + x + 1;
	self.distanceData[impactPlotIndex] = impact_value;
	self.playerCollisionData[impactPlotIndex] = true;
	self.cityStateData[impactPlotIndex] = 1;
	-- Place Ripples
	for ripple_radius, ripple_value in ipairs(ripple_values) do
		-- Moving clockwise around the ring, the first direction to travel will be Northeast.
		-- This matches the direction-based data in the odd and even tables. Each
		-- subsequent change in direction will correctly match with these tables, too.
		--
		-- Locate the plot within this ripple ring that is due West of the Impact Plot.
		local currentX = x - ripple_radius;
		local currentY = y;
		-- Now loop through the six directions, moving ripple_radius number of times
		-- per direction. At each plot in the ring, add the ripple_value for that ring 
		-- to the plot's entry in the distance data table.
		for direction_index = 1, 6 do
			for plot_to_handle = 1, ripple_radius do
				-- Must account for hex factor.
			 	if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
					plot_adjustments = odd[direction_index];
				else -- Current Y is even. Use plot adjustments from even table.
					plot_adjustments = even[direction_index];
				end
				-- Identify the next plot in the ring.
				nextX = currentX + plot_adjustments[1];
				nextY = currentY + plot_adjustments[2];
				-- Make sure the plot exists
				if wrapX == false and (nextX < 0 or nextX >= iW) then -- X is out of bounds.
					-- Do not add ripple data to this plot.
				elseif wrapY == false and (nextY < 0 or nextY >= iH) then -- Y is out of bounds.
					-- Do not add ripple data to this plot.
				else -- Plot is in bounds, process it.
					-- Handle any world wrap.
					local realX = nextX;
					local realY = nextY;
					if wrapX then
						realX = realX % iW;
					end
					if wrapY then
						realY = realY % iH;
					end
					-- Record ripple data for this plot.
					local ringPlotIndex = realY * iW + realX + 1;
					if self.distanceData[ringPlotIndex] > 0 then -- This plot is already in range of at least one other civ!
						-- First choose the greater of the two, existing value or current ripple.
						local stronger_value = math.max(self.distanceData[ringPlotIndex], ripple_value);
						-- Now increase it by 1.2x to reflect that multiple civs are in range of this plot.
						local overlap_value = math.min(97, math.floor(stronger_value * 1.2));
						self.distanceData[ringPlotIndex] = overlap_value;
					else
						self.distanceData[ringPlotIndex] = ripple_value;
					end
					-- Now impact the City State layer if appropriate.
					if ripple_radius <= 6 then
						self.cityStateData[ringPlotIndex] = 1;
					end
				end
				currentX, currentY = nextX, nextY;
			end
		end
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:MeasureSinglePlot(x, y, region_type)
	local data = table.fill(false, 4);
	-- Note that "Food" is not strictly about tile yield.
	-- Different regions get their food in different ways.
	-- Tundra, Jungle, Forest, Desert, Plains regions will 
	-- get Bonus resource support to cover food shortages.
	--
	-- Data table entries hold results; all begin as false:
	-- [1] "Food"
	-- [2] "Prod"
	-- [3] "Good"
	-- [4] "Junk"
	local iW, iH = Map.GetGridSize();
	local plot = Map.GetPlot(x, y);
	local plotType = plot:GetPlotType()
	local terrainType = plot:GetTerrainType()
	local featureType = plot:GetFeatureType()
	
	if plotType == PlotTypes.PLOT_MOUNTAIN or featureType == FeatureTypes.FEATURE_ICE or terrainType == TerrainTypes.TERRAIN_TRENCH then 
	--  Junk.
		data[4] = true;
		return data
	elseif plotType == PlotTypes.PLOT_OCEAN then
		data[1] = true;

		if plot:IsLake() then -- Lakes are Food
			data[3] = true;
			return data
		elseif region_type == 8 or self.mustBeInWater == false then
			if terrainType == TerrainTypes.TERRAIN_OCEAN or terrainType == TerrainTypes.TERRAIN_COAST then -- coast and ocean are good for coast starts.
				data[3] = true;
				return data
			end
		end
		-- Other water plots are ignored.
		return data
	end

	if featureType == FeatureTypes.FEATURE_JUNGLE then -- Jungles are Food, Good, except in Grass regions.
		if region_type ~= 7 then -- Region type is not grass.
			data[1] = true;
			data[3] = true;
		elseif plotType == PlotTypes.PLOT_HILLS then -- Jungle hill, in grass region, count as Prod but not Good.
			data[2] = true;
		end
		return data
	elseif featureType == FeatureTypes.FEATURE_FOREST then -- Forests are Prod, Good.
		data[2] = true;
		data[3] = true;
		if region_type == 3 or region_type == 1 then -- In Forest or Tundra Regions, Forests are also Food.
			data[1] = true;
		end
		return data
	--elseif featureType == FeatureTypes.FEATURE_OASIS then -- Oases are Food, Good.
		--data[1] = true;
		--data[3] = true;
		--return data
	elseif featureType == FeatureTypes.FEATURE_FLOOD_PLAINS then -- Flood Plains are Food, Good.
		data[1] = true;
		data[3] = true;
		return data
	elseif featureType == FeatureTypes.FEATURE_MARSH then -- Marsh are ignored. -- Except in BE, Marsh partially replace jungle. Marsh are Good in Marsh regions.
		if region_type == 2 then
			data[3] = true;
		end
		return data
	end

	if plotType == PlotTypes.PLOT_HILLS then -- Hills with no features are Prod, Good.
		data[2] = true;
		data[3] = true;
		return data
	end
	
	-- If we have reached this point in the process, the plot is flatlands.
	if terrainType == TerrainTypes.TERRAIN_SNOW then -- Snow are Junk.
		data[4] = true;
		return data
		
	elseif terrainType == TerrainTypes.TERRAIN_DESERT then -- Non-Oasis, non-FloodPlain flat deserts are Junk, except in Desert regions.
		if region_type ~= 4 then
			data[4] = true;
		end
		return data

	elseif terrainType == TerrainTypes.TERRAIN_TUNDRA then -- Tundra are ignored, except in Tundra Regions where they are Food, Good.
		if region_type == 1 then
			data[1] = true;
			data[3] = true;
		end
		return data

	elseif terrainType == TerrainTypes.TERRAIN_PLAINS then -- Plains are Good for all region types, but Food in only about half of them.
		data[3] = true;
		if region_type == 1 or region_type == 4 or region_type == 5 or region_type == 6 or region_type == 9 then
			data[1] = true;
		end
		return data

	elseif terrainType == TerrainTypes.TERRAIN_GRASS then -- Grass is Good for all region types, but Food in only about half of them.
		data[3] = true;
		if region_type == 2 or region_type == 3 or region_type == 5 or region_type == 7 or region_type == 9 then
			data[1] = true;
		end
		return data
	end

	-- If we have arrived here, the plot has non-standard terrain.
	print("Encountered non-standard terrain.");
	return data
end
------------------------------------------------------------------------------
function AssignStartingPlots:EvaluateCandidatePlot(plotIndex, region_type)
	local goodSoFar = true;
	local iW, iH = Map.GetGridSize();
	local x = (plotIndex - 1) % iW;
	local y = (plotIndex - x - 1) / iW;
	local plot = Map.GetPlot(x, y);
	local isEvenY = true;
	if y / 2 > math.floor(y / 2) then
		isEvenY = false;
	end
	local wrapX = Map:IsWrapX();
	local wrapY = Map:IsWrapY();
	local distance_bias = self.distanceData[plotIndex];
	local foodTotal, prodTotal, goodTotal, junkTotal, riverTotal, coastScore = 0, 0, 0, 0, 0, 0;
	local search_table = {};
	
	-- Check candidate plot to see if it's adjacent to saltwater.
	if self.plotDataIsCoastal[plotIndex] == true then
		coastScore = 40;
	end
	
	-- Evaluate First Ring
	if isEvenY then
		search_table = self.firstRingYIsEven;
	else
		search_table = self.firstRingYIsOdd;
	end

	for loop, plot_adjustments in ipairs(search_table) do
		local searchX, searchY;
		if wrapX then
			searchX = (x + plot_adjustments[1]) % iW;
		else
			searchX = x + plot_adjustments[1];
		end
		if wrapY then
			searchY = (y + plot_adjustments[2]) % iH;
		else
			searchY = y + plot_adjustments[2];
		end
		--
		if searchX < 0 or searchX >= iW or searchY < 0 or searchY >= iH then
			-- This plot does not exist. It's off the map edge.
			junkTotal = junkTotal + 1;
		else
			local result = self:MeasureSinglePlot(searchX, searchY, region_type)
			if result[4] then
				junkTotal = junkTotal + 1;
			else
				if result[1] then
					foodTotal = foodTotal + 1;
				end
				if result[2] then
					prodTotal = prodTotal + 1;
				end
				if result[3] then
					goodTotal = goodTotal + 1;
				end
				local searchPlot = Map.GetPlot(searchX, searchY);
				if searchPlot:IsRiverSide() then
					riverTotal = riverTotal + 1;
				end
			end
		end
	end

	-- Now check the results from the first ring against the established targets.
	if foodTotal < self.minFoodInner then
		goodSoFar = false;
	elseif prodTotal < self.minProdInner then
		goodSoFar = false;
	elseif goodTotal < self.minGoodInner then
		goodSoFar = false;
	end

	-- Set up the "score" for this candidate. Inner ring results weigh the heaviest.
	local weightedFoodInner = {0, 8, 14, 19, 22, 24, 25};
	local foodResultInner = weightedFoodInner[foodTotal + 1];
	local weightedProdInner = {0, 10, 16, 20, 20, 12, 0};
	local prodResultInner = weightedProdInner[prodTotal + 1];
	local goodResultInner = goodTotal * 2;
	local innerRingScore = foodResultInner + prodResultInner + goodResultInner + riverTotal - (junkTotal * 3);

	-- Evaluate Second Ring
	if isEvenY then
		search_table = self.secondRingYIsEven;
	else
		search_table = self.secondRingYIsOdd;
	end

	for loop, plot_adjustments in ipairs(search_table) do
		local searchX, searchY;
		if wrapX then
			searchX = (x + plot_adjustments[1]) % iW;
		else
			searchX = x + plot_adjustments[1];
		end
		if wrapY then
			searchY = (y + plot_adjustments[2]) % iH;
		else
			searchY = y + plot_adjustments[2];
		end
		if searchX < 0 or searchX >= iW or searchY < 0 or searchY >= iH then
			-- This plot does not exist. It's off the map edge.
			junkTotal = junkTotal + 1;
		else
			local result = self:MeasureSinglePlot(searchX, searchY, region_type)
			if result[4] then
				junkTotal = junkTotal + 1;
			else
				if result[1] then
					foodTotal = foodTotal + 1;
				end
				if result[2] then
					prodTotal = prodTotal + 1;
				end
				if result[3] then
					goodTotal = goodTotal + 1;
				end
				if plot:IsRiverSide() then
					riverTotal = riverTotal + 1;
				end
			end
		end
	end

	-- Check the results from the second ring against the established targets.
	if foodTotal < self.minFoodMiddle then
		goodSoFar = false;
	elseif prodTotal < self.minProdMiddle then
		goodSoFar = false;
	elseif goodTotal < self.minGoodMiddle then
		goodSoFar = false;
	end
	
	-- Update up the "score" for this candidate. Middle ring results weigh significantly.
	local weightedFoodMiddle = {0, 2, 5, 10, 20, 25, 28, 30, 32, 34, 35}; -- 35 for any further values.
	local foodResultMiddle = 35;
	if foodTotal < 10 then
		foodResultMiddle = weightedFoodMiddle[foodTotal + 1];
	end
	local weightedProdMiddle = {0, 10, 20, 25, 30, 35}; -- 35 for any further values.
	local effectiveProdTotal = prodTotal;
	if foodTotal * 2 < prodTotal then
		effectiveProdTotal = math.ceil(foodTotal / 2);
	end
	local prodResultMiddle = 35;
	if effectiveProdTotal < 5 then
		prodResultMiddle = weightedProdMiddle[effectiveProdTotal + 1];
	end
	local goodResultMiddle = goodTotal * 2;
	local middleRingScore = foodResultMiddle + prodResultMiddle + goodResultMiddle + riverTotal - (junkTotal * 3);
	
	-- Evaluate Third Ring
	if isEvenY then
		search_table = self.thirdRingYIsEven;
	else
		search_table = self.thirdRingYIsOdd;
	end

	for loop, plot_adjustments in ipairs(search_table) do
		local searchX, searchY;
		if wrapX then
			searchX = (x + plot_adjustments[1]) % iW;
		else
			searchX = x + plot_adjustments[1];
		end
		if wrapY then
			searchY = (y + plot_adjustments[2]) % iH;
		else
			searchY = y + plot_adjustments[2];
		end
		if searchX < 0 or searchX >= iW or searchY < 0 or searchY >= iH then
			-- This plot does not exist. It's off the map edge.
			junkTotal = junkTotal + 1;
		else
			local result = self:MeasureSinglePlot(searchX, searchY, region_type)
			if result[4] then
				junkTotal = junkTotal + 1;
			else
				if result[1] then
					foodTotal = foodTotal + 1;
				end
				if result[2] then
					prodTotal = prodTotal + 1;
				end
				if result[3] then
					goodTotal = goodTotal + 1;
				end
				if plot:IsRiverSide() then
					riverTotal = riverTotal + 1;
				end
			end
		end
	end

	-- Check the results from the third ring against the established targets.
	if foodTotal < self.minFoodOuter then
		goodSoFar = false;
	elseif prodTotal < self.minProdOuter then
		goodSoFar = false;
	elseif goodTotal < self.minGoodOuter then
		goodSoFar = false;
	end
	if junkTotal > self.maxJunk then
		goodSoFar = false;
	end

	-- Tally the final "score" for this candidate.
	local outerRingScore = foodTotal + prodTotal + goodTotal + riverTotal - (junkTotal * 2);
	local finalScore = innerRingScore + middleRingScore + outerRingScore + coastScore;

	-- Check Impact and Ripple data to see if candidate is near an already-placed start point.
	if distance_bias > 0 then
		-- This candidate is near an already placed start. This invalidates its 
		-- eligibility for first-pass placement; but it may still qualify as a 
		-- fallback site, so we will reduce its Score according to the bias factor.
		goodSoFar = false;
		finalScore = finalScore - math.floor(finalScore * distance_bias / 100);
	end
	-- 
	-- BE: Also check for proximity to Wild Areas. Tolerable score does not need to be zero. It
	-- is OK to be near a couple of Wild plots, but we want to avoid being near large areas.
	local wild_area_score = self.wildData[plotIndex];
	if wild_area_score > self.wild_score_forgiveness_factor then -- Default value of forgiveness set to 50.
		-- This candidate is too near a Wild Area to be ideal. This invalidates its
		-- eligibility for first-pass placement; but it may still qualify as a 
		-- fallback site, so we will reduce its Score according to the bias factor.
		goodSoFar = false;
		local adjusted_wild_score = wild_area_score - self.wild_score_forgiveness_factor; -- This will "forgive" an amount of points of the wildness score and reduce the max from 200 to 150.
		local adjusted_wild_cap = 400 - (2 * self.wild_score_forgiveness_factor);
		finalScore = finalScore - math.floor(finalScore * adjusted_wild_score / adjusted_wild_cap); -- Maximum loss of score for Wild Area proximity is 50%.
	end
		
	--[[ Debug
	print(".");
	print("Plot:", x, y, " Food:", foodTotal, "Prod: ", prodTotal, "Good:", goodTotal, "Junk:", 
	       junkTotal, "River:", riverTotal, "Score:", finalScore);
	print("Plot:", x, y, " Coastal:", self.plotDataIsCoastal[plotIndex], "Distance Bias:", distance_bias);
	]]--
	
	return finalScore, goodSoFar
end
------------------------------------------------------------------------------
function AssignStartingPlots:IterateThroughCandidatePlotList(plot_list, region_type)
	-- Iterates through a list of candidate plots.
	-- Each plot is identified by its global plot index.
	-- This function assumes all candidate plots can have a city built on them.
	-- Any plots not allowed to have a city should be weeded out when building the candidate list.
	local found_eligible = false;
	local bestPlotScore = -5000;
	local bestPlotIndex;
	local found_fallback = false;
	local bestFallbackScore = -5000;
	local bestFallbackIndex;
	-- Process list of candidate plots.
	for loop, plotIndex in ipairs(plot_list) do
		local score, meets_minimums = self:EvaluateCandidatePlot(plotIndex, region_type)
		-- Test current plot against best known plot.
		if meets_minimums == true then
			found_eligible = true;
			if score > bestPlotScore then
				bestPlotScore = score;
				bestPlotIndex = plotIndex;
			end
		else
			if score > bestFallbackScore then
				found_fallback = true;
				bestFallbackScore = score;
				bestFallbackIndex = plotIndex;
			end
		end
	end
	-- returns table containing six variables: boolean, integer, integer, boolean, integer, integer
	local election_results = {found_eligible, bestPlotScore, bestPlotIndex, found_fallback, bestFallbackScore, bestFallbackIndex};
	return election_results
end
------------------------------------------------------------------------------
function AssignStartingPlots:FindStart(region_number)
	-- This function attempts to choose a start position for a single region.
	-- This function returns two boolean flags, indicating the success level of the operation.
	local bSuccessFlag = false; -- Returns true when a start is placed, false when process fails.
	local bForcedPlacementFlag = false; -- Returns true if this region had no eligible starts and one was forced to occur.
	
	-- Obtain data needed to process this region.
	local iW, iH = Map.GetGridSize();
	local region_data_table = self.regionData[region_number];
	local iWestX = region_data_table[1];
	local iSouthY = region_data_table[2];
	local iWidth = region_data_table[3];
	local iHeight = region_data_table[4];
	local iAreaID = region_data_table[5];
	local iMembershipEastX = iWestX + iWidth - 1;
	local iMembershipNorthY = iSouthY + iHeight - 1;
	--
	local terrainCounts = self.regionTerrainCounts[region_number];
	--
	local region_type = self.regionTypes[region_number];
	-- Done setting up region data.
	-- Set up contingency.
	local fallback_plots = {};
	
	-- Establish scope of center bias.
	local fCenterWidth = (self.centerBias / 100) * iWidth;
	local iNonCenterWidth = math.floor((iWidth - fCenterWidth) / 2)
	local iCenterWidth = iWidth - (iNonCenterWidth * 2);
	local iCenterWestX = (iWestX + iNonCenterWidth) % iW; -- Modulo math to synch coordinate to actual map in case of world wrap.
	local iCenterTestWestX = (iWestX + iNonCenterWidth); -- "Test" values ignore world wrap for easier membership testing.
	local iCenterTestEastX = (iCenterWestX + iCenterWidth - 1);

	local fCenterHeight = (self.centerBias / 100) * iHeight;
	local iNonCenterHeight = math.floor((iHeight - fCenterHeight) / 2)
	local iCenterHeight = iHeight - (iNonCenterHeight * 2);
	local iCenterSouthY = (iSouthY + iNonCenterHeight) % iH;
	local iCenterTestSouthY = (iSouthY + iNonCenterHeight);
	local iCenterTestNorthY = (iCenterTestSouthY + iCenterHeight - 1);

	-- Establish scope of "middle donut", outside the center but inside the outer.
	local fMiddleWidth = (self.middleBias / 100) * iWidth;
	local iOuterWidth = math.floor((iWidth - fMiddleWidth) / 2)
	local iMiddleWidth = iWidth - (iOuterWidth * 2);
	local iMiddleWestX = (iWestX + iOuterWidth) % iW;
	local iMiddleTestWestX = (iWestX + iOuterWidth);
	local iMiddleTestEastX = (iMiddleTestWestX + iMiddleWidth - 1);

	local fMiddleHeight = (self.middleBias / 100) * iHeight;
	local iOuterHeight = math.floor((iHeight - fMiddleHeight) / 2)
	local iMiddleHeight = iHeight - (iOuterHeight * 2);
	local iMiddleSouthY = (iSouthY + iOuterHeight) % iH;
	local iMiddleTestSouthY = (iSouthY + iOuterHeight);
	local iMiddleTestNorthY = (iMiddleTestSouthY + iMiddleHeight - 1); 

	-- Assemble candidates lists.
	local two_plots_from_ocean = {};
	local center_candidates = {};
	local center_river = {};
	local center_coastal = {};
	local center_inland_dry = {};
	local middle_candidates = {};
	local middle_river = {};
	local middle_coastal = {};
	local middle_inland_dry = {};
	local outer_plots = {};
	
	-- Identify candidate plots.
	for region_y = 0, iHeight - 1 do -- When handling global plot indices, process Y first.
		for region_x = 0, iWidth - 1 do
			local x = (region_x + iWestX) % iW; -- Actual coords, adjusted for world wrap, if any.
			local y = (region_y + iSouthY) % iH; --
			local plotIndex = y * iW + x + 1;
			local plot = Map.GetPlot(x, y);
			local plotType = plot:GetPlotType()
			if plotType == PlotTypes.PLOT_HILLS or plotType == PlotTypes.PLOT_LAND then -- Could host a city.
				-- Check if plot is two away from salt water.
				if self.plotDataIsNextToCoast[plotIndex] == true then
					table.insert(two_plots_from_ocean, plotIndex);
				else
					local area_of_plot = plot:GetArea();
					if area_of_plot == iAreaID or iAreaID == -1 then -- This plot is a member, so it goes on at least one candidate list.
						--
						-- Test whether plot is in center bias, middle donut, or outer donut.
						--
						local test_x = region_x + iWestX; -- "Test" coords, ignoring any world wrap and
						local test_y = region_y + iSouthY; -- reaching in to virtual space if necessary.
						if (test_x >= iCenterTestWestX and test_x <= iCenterTestEastX) and 
						   (test_y >= iCenterTestSouthY and test_y <= iCenterTestNorthY) then -- Center Bias.
							table.insert(center_candidates, plotIndex);
							if plot:IsRiverSide() then
								table.insert(center_river, plotIndex);
							elseif plot:IsFreshWater() or self.plotDataIsCoastal[plotIndex] == true then
								table.insert(center_coastal, plotIndex);
							else
								table.insert(center_inland_dry, plotIndex);
							end
						elseif (test_x >= iMiddleTestWestX and test_x <= iMiddleTestEastX) and 
						       (test_y >= iMiddleTestSouthY and test_y <= iMiddleTestNorthY) then
							table.insert(middle_candidates, plotIndex);
							if plot:IsRiverSide() then
								table.insert(middle_river, plotIndex);
							elseif plot:IsFreshWater() or self.plotDataIsCoastal[plotIndex] == true then
								table.insert(middle_coastal, plotIndex);
							else
								table.insert(middle_inland_dry, plotIndex);
							end
						else
							table.insert(outer_plots, plotIndex);
						end
					end
				end
			end
		end
	end

	-- Check how many plots landed on each list.
	local iNumDisqualified = table.maxn(two_plots_from_ocean);
	local iNumCenter = table.maxn(center_candidates);
	local iNumCenterRiver = table.maxn(center_river);
	local iNumCenterCoastLake = table.maxn(center_coastal);
	local iNumCenterInlandDry = table.maxn(center_inland_dry);
	local iNumMiddle = table.maxn(middle_candidates);
	local iNumMiddleRiver = table.maxn(middle_river);
	local iNumMiddleCoastLake = table.maxn(middle_coastal);
	local iNumMiddleInlandDry = table.maxn(middle_inland_dry);
	local iNumOuter = table.maxn(outer_plots);
	
	-- Debug printout.
	print("-");
	print("--- Number of Candidate Plots in Region #", region_number, " - Region Type:", region_type, " ---");
	print("-");
	print("Candidates in Center Bias area: ", iNumCenter);
	print("Which are next to river: ", iNumCenterRiver);
	print("Which are next to lake or sea: ", iNumCenterCoastLake);
	print("Which are inland and dry: ", iNumCenterInlandDry);
	print("-");
	print("Candidates in Middle Donut area: ", iNumMiddle);
	print("Which are next to river: ", iNumMiddleRiver);
	print("Which are next to lake or sea: ", iNumMiddleCoastLake);
	print("Which are inland and dry: ", iNumMiddleInlandDry);
	print("-");
	print("Candidate Plots in Outer area: ", iNumOuter);
	print("-");
	print("Disqualified, two plots away from salt water: ", iNumDisqualified);
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	--
	
	-- Process lists of candidate plots.
	if iNumCenter + iNumMiddle > 0 then
		local candidate_lists = {};
		if iNumCenterRiver > 0 then -- Process center bias river plots.
			table.insert(candidate_lists, center_river);
		end
		if iNumCenterCoastLake > 0 then -- Process center bias lake or coastal plots.
			table.insert(candidate_lists, center_coastal);
		end
		if iNumCenterInlandDry > 0 then -- Process center bias inland dry plots.
			table.insert(candidate_lists, center_inland_dry);
		end
		if iNumMiddleRiver > 0 then -- Process middle donut river plots.
			table.insert(candidate_lists, middle_river);
		end
		if iNumMiddleCoastLake > 0 then -- Process middle donut lake or coastal plots.
			table.insert(candidate_lists, middle_coastal);
		end
		if iNumMiddleInlandDry > 0 then -- Process middle donut inland dry plots.
			table.insert(candidate_lists, middle_inland_dry);
		end
		--
		for loop, plot_list in ipairs(candidate_lists) do -- Up to six plot lists, processed by priority.
			local election_returns = self:IterateThroughCandidatePlotList(plot_list, region_type)
			-- If any candidates are eligible, choose one.
			local found_eligible = election_returns[1];
			if found_eligible then
				local bestPlotScore = election_returns[2]; 
				local bestPlotIndex = election_returns[3];
				local x = (bestPlotIndex - 1) % iW;
				local y = (bestPlotIndex - x - 1) / iW;
				self.startingPlots[region_number] = {x, y, bestPlotScore};
				self:PlaceImpactAndRipples(x, y)
				return true, false
			end
			-- If none eligible, check for fallback plot.
			local found_fallback = election_returns[4];
			if found_fallback then
				local bestFallbackScore = election_returns[5];
				local bestFallbackIndex = election_returns[6];
				local x = (bestFallbackIndex - 1) % iW;
				local y = (bestFallbackIndex - x - 1) / iW;
				table.insert(fallback_plots, {x, y, bestFallbackScore});
			end
		end
	end
	-- Reaching this point means no eligible sites in center bias or middle donut subregions!
	
	-- Process candidates from Outer subregion, if any.
	if iNumOuter > 0 then
		local outer_eligible_list = {};
		local found_eligible = false;
		local found_fallback = false;
		local bestFallbackScore = -50;
		local bestFallbackIndex;
		-- Process list of candidate plots.
		for loop, plotIndex in ipairs(outer_plots) do
			local score, meets_minimums = self:EvaluateCandidatePlot(plotIndex, region_type)
			-- Test current plot against best known plot.
			if meets_minimums == true then
				found_eligible = true;
				table.insert(outer_eligible_list, plotIndex);
			else
				if score > bestFallbackScore then
					found_fallback = true;
					bestFallbackScore = score;
					bestFallbackIndex = plotIndex;
				end
			end
		end
		if found_eligible then -- Iterate through eligible plots and choose the one closest to the center of the region.
			local closestPlot;
			local closestDistance = math.max(iW, iH);
			local bullseyeX = iWestX + (iWidth / 2);
			if bullseyeX < iWestX then -- wrapped around: un-wrap it for test purposes.
				bullseyeX = bullseyeX + iW;
			end
			local bullseyeY = iSouthY + (iHeight / 2);
			if bullseyeY < iSouthY then -- wrapped around: un-wrap it for test purposes.
				bullseyeY = bullseyeY + iH;
			end
			if bullseyeY / 2 ~= math.floor(bullseyeY / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
				bullseyeX = bullseyeX + 0.5;
			end
			
			for loop, plotIndex in ipairs(outer_eligible_list) do
				local x = (plotIndex - 1) % iW;
				local y = (plotIndex - x - 1) / iW;
				local adjusted_x = x;
				local adjusted_y = y;
				if y / 2 ~= math.floor(y / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
					adjusted_x = x + 0.5;
				end
				
				if x < iWestX then -- wrapped around: un-wrap it for test purposes.
					adjusted_x = adjusted_x + iW;
				end
				if y < iSouthY then -- wrapped around: un-wrap it for test purposes.
					adjusted_y = y + iH;
				end
				local fDistance = math.sqrt( (adjusted_x - bullseyeX)^2 + (adjusted_y - bullseyeY)^2 );
				if fDistance < closestDistance then -- Found new "closer" plot.
					closestPlot = plotIndex;
					closestDistance = fDistance;
				end
			end
			-- Assign the closest eligible plot as the start point.
			local x = (closestPlot - 1) % iW;
			local y = (closestPlot - x - 1) / iW;
			-- Re-get plot score for inclusion in start plot data.
			local score, meets_minimums = self:EvaluateCandidatePlot(closestPlot, region_type)
			-- Assign this plot as the start for this region.
			self.startingPlots[region_number] = {x, y, score};
			self:PlaceImpactAndRipples(x, y)
			return true, false
		end
		-- Add the fallback plot (best scored plot) from the Outer region to the fallback list.
		if found_fallback then
			local x = (bestFallbackIndex - 1) % iW;
			local y = (bestFallbackIndex - x - 1) / iW;
			table.insert(fallback_plots, {x, y, bestFallbackScore});
		end
	end
	-- Reaching here means no plot in the entire region met the minimum standards for selection.
	
	-- The fallback plot contains the best-scored plots from each test area in this region.
	-- We will compare all the fallback plots and choose the best to be the start plot.
	local iNumFallbacks = table.maxn(fallback_plots);
	if iNumFallbacks > 0 then
		local best_fallback_score = -50
		local best_fallback_x;
		local best_fallback_y;
		for loop, plotData in ipairs(fallback_plots) do
			local score = plotData[3];
			if score > best_fallback_score then
				best_fallback_score = score;
				best_fallback_x = plotData[1];
				best_fallback_y = plotData[2];
			end
		end
		-- Assign the start for this region.
		self.startingPlots[region_number] = {best_fallback_x, best_fallback_y, best_fallback_score};
		self:PlaceImpactAndRipples(best_fallback_x, best_fallback_y)
		bSuccessFlag = true;
	else
		-- This region cannot have a start and something has gone way wrong.
		-- We'll force a one tile grass island in the SW corner of the region and put the start there.
		local forcePlot = Map.GetPlot(iWestX, iSouthY);
		bSuccessFlag = true;
		bForcedPlacementFlag = true;
		forcePlot:SetPlotType(PlotTypes.PLOT_LAND, false, true);
		forcePlot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, true);
		forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
		self.startingPlots[region_number] = {iWestX, iSouthY, 0};
		self:PlaceImpactAndRipples(iWestX, iSouthY)
	end

	return bSuccessFlag, bForcedPlacementFlag
end
------------------------------------------------------------------------------
function AssignStartingPlots:FindCoastalStart(region_number)
	-- This function attempts to choose a start position (which is along an ocean) for a single region.
	-- This function returns two boolean flags, indicating the success level of the operation.
	local bSuccessFlag = false; -- Returns true when a start is placed, false when process fails.
	local bForcedPlacementFlag = false; -- Returns true if this region had no eligible starts and one was forced to occur.
	
	-- Obtain data needed to process this region.
	local iW, iH = Map.GetGridSize();
	local region_data_table = self.regionData[region_number];
	local iWestX = region_data_table[1];
	local iSouthY = region_data_table[2];
	local iWidth = region_data_table[3];
	local iHeight = region_data_table[4];
	local iAreaID = region_data_table[5];
	local iMembershipEastX = iWestX + iWidth - 1;
	local iMembershipNorthY = iSouthY + iHeight - 1;
	--
	local terrainCounts = self.regionTerrainCounts[region_number];
	local coastalLandCount = terrainCounts[22];
	--
	local region_type = self.regionTypes[region_number];
	-- Done setting up region data.
	-- Set up contingency.
	local fallback_plots = {};
	
	-- Check region for AlongOcean eligibility.
	if coastalLandCount < 3 then
		-- This region cannot support an Along Ocean start. Try instead to find an inland start for it.
		bSuccessFlag, bForcedPlacementFlag = self:FindStart(region_number)
		if bSuccessFlag == false then
			-- This region cannot have a start and something has gone way wrong.
			-- We'll force a one tile grass island in the SW corner of the region and put the start there.
			local forcePlot = Map.GetPlot(iWestX, iSouthY);
			bForcedPlacementFlag = true;
			forcePlot:SetPlotType(PlotTypes.PLOT_LAND, false, true);
			forcePlot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, true);
			forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
			self.startingPlots[region_number] = {iWestX, iSouthY, 0};
			self:PlaceImpactAndRipples(iWestX, iSouthY)
		end
		return bSuccessFlag, bForcedPlacementFlag
	end

	-- Establish scope of center bias.
	local fCenterWidth = (self.centerBias / 100) * iWidth;
	local iNonCenterWidth = math.floor((iWidth - fCenterWidth) / 2)
	local iCenterWidth = iWidth - (iNonCenterWidth * 2);
	local iCenterWestX = (iWestX + iNonCenterWidth) % iW; -- Modulo math to synch coordinate to actual map in case of world wrap.
	local iCenterTestWestX = (iWestX + iNonCenterWidth); -- "Test" values ignore world wrap for easier membership testing.
	local iCenterTestEastX = (iCenterWestX + iCenterWidth - 1);

	local fCenterHeight = (self.centerBias / 100) * iHeight;
	local iNonCenterHeight = math.floor((iHeight - fCenterHeight) / 2)
	local iCenterHeight = iHeight - (iNonCenterHeight * 2);
	local iCenterSouthY = (iSouthY + iNonCenterHeight) % iH;
	local iCenterTestSouthY = (iSouthY + iNonCenterHeight);
	local iCenterTestNorthY = (iCenterTestSouthY + iCenterHeight - 1);

	-- Establish scope of "middle donut", outside the center but inside the outer.
	local fMiddleWidth = (self.middleBias / 100) * iWidth;
	local iOuterWidth = math.floor((iWidth - fMiddleWidth) / 2)
	local iMiddleWidth = iWidth - (iOuterWidth * 2);
	--local iMiddleDiameterX = (iMiddleWidth - iCenterWidth) / 2;
	local iMiddleWestX = (iWestX + iOuterWidth) % iW;
	local iMiddleTestWestX = (iWestX + iOuterWidth);
	local iMiddleTestEastX = (iMiddleTestWestX + iMiddleWidth - 1);

	local fMiddleHeight = (self.middleBias / 100) * iHeight;
	local iOuterHeight = math.floor((iHeight - fMiddleHeight) / 2)
	local iMiddleHeight = iHeight - (iOuterHeight * 2);
	--local iMiddleDiameterY = (iMiddleHeight - iCenterHeight) / 2;
	local iMiddleSouthY = (iSouthY + iOuterHeight) % iH;
	local iMiddleTestSouthY = (iSouthY + iOuterHeight);
	local iMiddleTestNorthY = (iMiddleTestSouthY + iMiddleHeight - 1); 

	-- Assemble candidates lists.
	local center_coastal_plots = {};
	local center_plots_on_river = {};
	local center_fresh_plots = {};
	local center_dry_plots = {};
	local middle_coastal_plots = {};
	local middle_plots_on_river = {};
	local middle_fresh_plots = {};
	local middle_dry_plots = {};
	local outer_coastal_plots = {};
	
	-- Identify candidate plots.
	for region_y = 0, iHeight - 1 do -- When handling global plot indices, process Y first.
		for region_x = 0, iWidth - 1 do
			local x = (region_x + iWestX) % iW; -- Actual coords, adjusted for world wrap, if any.
			local y = (region_y + iSouthY) % iH; --
			local plotIndex = y * iW + x + 1;
			if self.plotDataIsCoastal[plotIndex] == true then -- This plot is a land plot next to an ocean.
				local plot = Map.GetPlot(x, y);
				local plotType = plot:GetPlotType()
				if plotType ~= PlotTypes.PLOT_MOUNTAIN then -- Not a mountain plot.
					local area_of_plot = plot:GetArea();
					if area_of_plot == iAreaID or iAreaID == -1 then -- This plot is a member, so it goes on at least one candidate list.
						--
						-- Test whether plot is in center bias, middle donut, or outer donut.
						--
						local test_x = region_x + iWestX; -- "Test" coords, ignoring any world wrap and
						local test_y = region_y + iSouthY; -- reaching in to virtual space if necessary.
						if (test_x >= iCenterTestWestX and test_x <= iCenterTestEastX) and 
						   (test_y >= iCenterTestSouthY and test_y <= iCenterTestNorthY) then
							table.insert(center_coastal_plots, plotIndex);
							if plot:IsRiverSide() then
								table.insert(center_plots_on_river, plotIndex);
							elseif plot:IsFreshWater() then
								table.insert(center_fresh_plots, plotIndex);
							else
								table.insert(center_dry_plots, plotIndex);
							end
						elseif (test_x >= iMiddleTestWestX and test_x <= iMiddleTestEastX) and 
						       (test_y >= iMiddleTestSouthY and test_y <= iMiddleTestNorthY) then
							table.insert(middle_coastal_plots, plotIndex);
							if plot:IsRiverSide() then
								table.insert(middle_plots_on_river, plotIndex);
							elseif plot:IsFreshWater() then
								table.insert(middle_fresh_plots, plotIndex);
							else
								table.insert(middle_dry_plots, plotIndex);
							end
						else
							table.insert(outer_coastal_plots, plotIndex);
						end
					end
				end
			end
		end
	end
	-- Check how many plots landed on each list.
	local iNumCenterCoastal = table.maxn(center_coastal_plots);
	local iNumCenterRiver = table.maxn(center_plots_on_river);
	local iNumCenterFresh = table.maxn(center_fresh_plots);
	local iNumCenterDry = table.maxn(center_dry_plots);
	local iNumMiddleCoastal = table.maxn(middle_coastal_plots);
	local iNumMiddleRiver = table.maxn(middle_plots_on_river);
	local iNumMiddleFresh = table.maxn(middle_fresh_plots);
	local iNumMiddleDry = table.maxn(middle_dry_plots);
	local iNumOuterCoastal = table.maxn(outer_coastal_plots);
	
	-- Debug printout.
	print("-");
	print("--- Number of Candidate Plots next to an ocean in Region #", region_number, " - Region Type:", region_type, " ---");
	print("-");
	print("Coastal Plots in Center Bias area: ", iNumCenterCoastal);
	print("Which are along rivers: ", iNumCenterRiver);
	print("Which are fresh water: ", iNumCenterFresh);
	print("Which are dry: ", iNumCenterDry);
	print("-");
	print("Coastal Plots in Middle Donut area: ", iNumMiddleCoastal);
	print("Which are along rivers: ", iNumMiddleRiver);
	print("Which are fresh water: ", iNumMiddleFresh);
	print("Which are dry: ", iNumMiddleDry);
	print("-");
	print("Coastal Plots in Outer area: ", iNumOuterCoastal);
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	--
	
	-- Process lists of candidate plots.
	if iNumCenterCoastal + iNumMiddleCoastal > 0 then
		local candidate_lists = {};
		if iNumCenterRiver > 0 then -- Process center bias river plots.
			table.insert(candidate_lists, center_plots_on_river);
		end
		if iNumCenterFresh > 0 then -- Process center bias fresh water plots that are not rivers.
			table.insert(candidate_lists, center_fresh_plots);
		end
		if iNumCenterDry > 0 then -- Process center bias dry plots.
			table.insert(candidate_lists, center_dry_plots);
		end
		if iNumMiddleRiver > 0 then -- Process middle bias river plots.
			table.insert(candidate_lists, middle_plots_on_river);
		end
		if iNumMiddleFresh > 0 then -- Process middle bias fresh water plots that are not rivers.
			table.insert(candidate_lists, middle_fresh_plots);
		end
		if iNumMiddleDry > 0 then -- Process middle bias dry plots.
			table.insert(candidate_lists, middle_dry_plots);
		end
		--
		for loop, plot_list in ipairs(candidate_lists) do -- Up to six plot lists, processed by priority.
			local election_returns = self:IterateThroughCandidatePlotList(plot_list, region_type)
			-- If any riverside candidates are eligible, choose one.
			local found_eligible = election_returns[1];
			if found_eligible then
				local bestPlotScore = election_returns[2]; 
				local bestPlotIndex = election_returns[3];
				local x = (bestPlotIndex - 1) % iW;
				local y = (bestPlotIndex - x - 1) / iW;
				self.startingPlots[region_number] = {x, y, bestPlotScore};
				self:PlaceImpactAndRipples(x, y)
				return true, false
			end
			-- If none eligible, check for fallback plot.
			local found_fallback = election_returns[4];
			if found_fallback then
				local bestFallbackScore = election_returns[5];
				local bestFallbackIndex = election_returns[6];
				local x = (bestFallbackIndex - 1) % iW;
				local y = (bestFallbackIndex - x - 1) / iW;
				table.insert(fallback_plots, {x, y, bestFallbackScore});
			end
		end
	end
	-- Reaching this point means no strong coastal sites in center bias or middle donut subregions!
	
	-- Process candidates from Outer subregion, if any.
	if iNumOuterCoastal > 0 then
		local outer_eligible_list = {};
		local found_eligible = false;
		local found_fallback = false;
		local bestFallbackScore = -50;
		local bestFallbackIndex;
		-- Process list of candidate plots.
		for loop, plotIndex in ipairs(outer_coastal_plots) do
			local score, meets_minimums = self:EvaluateCandidatePlot(plotIndex, region_type)
			-- Test current plot against best known plot.
			if meets_minimums == true then
				found_eligible = true;
				table.insert(outer_eligible_list, plotIndex);
			else
				if score > bestFallbackScore then
					found_fallback = true;
					bestFallbackScore = score;
					bestFallbackIndex = plotIndex;
				end
			end
		end
		if found_eligible then -- Iterate through eligible plots and choose the one closest to the center of the region.
			local closestPlot;
			local closestDistance = math.max(iW, iH);
			local bullseyeX = iWestX + (iWidth / 2);
			if bullseyeX < iWestX then -- wrapped around: un-wrap it for test purposes.
				bullseyeX = bullseyeX + iW;
			end
			local bullseyeY = iSouthY + (iHeight / 2);
			if bullseyeY < iSouthY then -- wrapped around: un-wrap it for test purposes.
				bullseyeY = bullseyeY + iH;
			end
			if bullseyeY / 2 ~= math.floor(bullseyeY / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
				bullseyeX = bullseyeX + 0.5;
			end
			
			for loop, plotIndex in ipairs(outer_eligible_list) do
				local x = (plotIndex - 1) % iW;
				local y = (plotIndex - x - 1) / iW;
				local adjusted_x = x;
				local adjusted_y = y;
				if y / 2 ~= math.floor(y / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
					adjusted_x = x + 0.5;
				end
				
				if x < iWestX then -- wrapped around: un-wrap it for test purposes.
					adjusted_x = adjusted_x + iW;
				end
				if y < iSouthY then -- wrapped around: un-wrap it for test purposes.
					adjusted_y = y + iH;
				end
				local fDistance = math.sqrt( (adjusted_x - bullseyeX)^2 + (adjusted_y - bullseyeY)^2 );
				if fDistance < closestDistance then -- Found new "closer" plot.
					closestPlot = plotIndex;
					closestDistance = fDistance;
				end
			end
			-- Assign the closest eligible plot as the start point.
			local x = (closestPlot - 1) % iW;
			local y = (closestPlot - x - 1) / iW;
			-- Re-get plot score for inclusion in start plot data.
			local score, meets_minimums = self:EvaluateCandidatePlot(closestPlot, region_type)
			-- Assign this plot as the start for this region.
			self.startingPlots[region_number] = {x, y, score};
			self:PlaceImpactAndRipples(x, y)
			return true, false
		end
		-- Add the fallback plot (best scored plot) from the Outer region to the fallback list.
		if found_fallback then
			local x = (bestFallbackIndex - 1) % iW;
			local y = (bestFallbackIndex - x - 1) / iW;
			table.insert(fallback_plots, {x, y, bestFallbackScore});
		end
	end
	-- Reaching here means no plot in the entire region met the minimum standards for selection.
	
	-- The fallback plot contains the best-scored plots from each test area in this region.
	-- This region must be something awful on food, or had too few coastal plots with none being decent.
	-- We will compare all the fallback plots and choose the best to be the start plot.
	local iNumFallbacks = table.maxn(fallback_plots);
	if iNumFallbacks > 0 then
		local best_fallback_score = -50
		local best_fallback_x;
		local best_fallback_y;
		for loop, plotData in ipairs(fallback_plots) do
			local score = plotData[3];
			if score > best_fallback_score then
				best_fallback_score = score;
				best_fallback_x = plotData[1];
				best_fallback_y = plotData[2];
			end
		end
		-- Assign the start for this region.
		self.startingPlots[region_number] = {best_fallback_x, best_fallback_y, best_fallback_score};
		self:PlaceImpactAndRipples(best_fallback_x, best_fallback_y)
		bSuccessFlag = true;
	else
		-- This region cannot support an Along Ocean start. Try instead to find an Inland start for it.
		bSuccessFlag, bForcedPlacementFlag = self:FindStart(region_number)
		if bSuccessFlag == false then
			-- This region cannot have a start and something has gone way wrong.
			-- We'll force a one tile grass island in the SW corner of the region and put the start there.
			local forcePlot = Map.GetPlot(iWestX, iSouthY);
			bSuccessFlag = false;
			bForcedPlacementFlag = true;
			forcePlot:SetPlotType(PlotTypes.PLOT_LAND, false, true);
			forcePlot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, true);
			forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
			self.startingPlots[region_number] = {iWestX, iSouthY, 0};
			self:PlaceImpactAndRipples(iWestX, iSouthY)
		end
	end

	return bSuccessFlag, bForcedPlacementFlag
end
------------------------------------------------------------------------------
function AssignStartingPlots:FindStartWithoutRegardToAreaID(region_number)
	-- This function attempts to choose a start position on the best AreaID section within the Region's rectangle.
	-- This function returns two boolean flags, indicating the success level of the operation.
	local bSuccessFlag = false; -- Returns true when a start is placed, false when process fails.
	local bForcedPlacementFlag = false; -- Returns true if this region had no eligible starts and one was forced to occur.
	
	-- Obtain data needed to process this region.
	local iW, iH = Map.GetGridSize();
	local region_data_table = self.regionData[region_number];
	local iWestX = region_data_table[1];
	local iSouthY = region_data_table[2];
	local iWidth = region_data_table[3];
	local iHeight = region_data_table[4];
	local wrapX = Map:IsWrapX();
	local wrapY = Map:IsWrapY();
	local iMembershipEastX = iWestX + iWidth - 1;
	local iMembershipNorthY = iSouthY + iHeight - 1;
	--
	local region_type = self.regionTypes[region_number];
	local fallback_plots = {};
	-- Done setting up region data.

	-- Obtain info on all landmasses wholly or partially within this region, for comparision purposes.
	local regionalFertilityOfLands = {};
	local iRegionalFertilityOfLands = 0;
	local iNumLandPlots = 0;
	local iNumLandAreas = 0;
	local land_area_IDs = {};
	local land_area_plots = {};
	local land_area_fert = {};
	local land_area_plot_lists = {};
	-- Cycle through all plots in the region, checking their Start Placement Fertility and AreaID.
	for region_y = 0, iHeight - 1 do
		for region_x = 0, iWidth - 1 do
			local x = region_x + iWestX;
			local y = region_y + iSouthY;
			local plot = Map.GetPlot(x, y);
			local plotType = plot:GetPlotType()
			if plotType == PlotTypes.PLOT_HILLS or plotType == PlotTypes.PLOT_LAND then -- Land plot, process it.
				iNumLandPlots = iNumLandPlots + 1;
				local iArea = plot:GetArea();
				local plotFertility = self:MeasureStartPlacementFertilityOfPlot(x, y); -- Check for coastal land is disabled.
				iRegionalFertilityOfLands = iRegionalFertilityOfLands + plotFertility;
				if TestMembership(land_area_IDs, iArea) == false then -- This plot is the first detected in its AreaID.
					iNumLandAreas = iNumLandAreas + 1;
					table.insert(land_area_IDs, iArea);
					land_area_plots[iArea] = 1;
					land_area_fert[iArea] = plotFertility;
				else -- This AreaID already known.
					land_area_plots[iArea] = land_area_plots[iArea] + 1;
					land_area_fert[iArea] = land_area_fert[iArea] + plotFertility;
				end
			end
		end
	end

	-- Generate empty (non-nil) tables for each Area ID in the plot lists matrix.
	for loop, areaID in ipairs(land_area_IDs) do
		land_area_plot_lists[areaID] = {};
	end
	-- Cycle through all plots in the region again, adding candidates to the applicable AreaID plot list.
	for region_y = 0, iHeight - 1 do
		for region_x = 0, iWidth - 1 do
			local x = region_x + iWestX;
			local y = region_y + iSouthY;
			local i = y * iW + x + 1;
			local plot = Map.GetPlot(x, y);
			local plotType = plot:GetPlotType()
			if plotType == PlotTypes.PLOT_HILLS or plotType == PlotTypes.PLOT_LAND then -- Land plot, process it.
				local iArea = plot:GetArea();
				if self.mustBeInOrAdjacentToWater == true and self.plotDataIsCoastal[i] == true then
					table.insert(land_area_plot_lists[iArea], i);
				elseif self.plotDataIsNextToCoast[i] == false then
					table.insert(land_area_plot_lists[iArea], i);
				end
			end
		end
	end
	
	local best_areas = {};
	local regionAreaListUnsorted = {};
	local regionAreaListSorted = {}; -- Have to make this a separate table, not merely a pointer to the first table.
	for areaNum, fert in pairs(land_area_fert) do
		table.insert(regionAreaListUnsorted, {areaNum, fert});
		table.insert(regionAreaListSorted, fert);
	end
	table.sort(regionAreaListSorted);
	
	-- Match each sorted fertilty value to the matching unsorted AreaID number and record in sequence.
	local iNumAreas = table.maxn(regionAreaListSorted);
	for area_order = iNumAreas, 1, -1 do -- Best areas are at the end of the list, so run the list backward.
		for loop, data_pair in ipairs(regionAreaListUnsorted) do
			local unsorted_fert = data_pair[2];
			if regionAreaListSorted[area_order] == unsorted_fert then
				local unsorted_area_num = data_pair[1];
				table.insert(best_areas, unsorted_area_num);
				-- HAVE TO remove the entry from the table in case of ties on fert value.
				table.remove(regionAreaListUnsorted, loop);
				break
			end
		end
	end

	-- Debug printout.
	print("-");
	print("--- Number of Candidate Plots in each landmass in Region #", region_number, " - Region Type:", region_type, " ---");
	print("-");
	for loop, iAreaID in ipairs(best_areas) do
		local fert_rating = land_area_fert[iAreaID];
		local plotCount = table.maxn(land_area_plot_lists[iAreaID]);
		print("* Area ID#", iAreaID, "has fertility rating of", fert_rating, "and candidate plot count of", plotCount); print("-");
	end
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	--

	-- Now iterate through areas, from best fertility downward, looking for a site good enough to choose.
	for loop, iAreaID in ipairs(best_areas) do
		local plot_list = land_area_plot_lists[iAreaID];
		local election_returns = self:IterateThroughCandidatePlotList(plot_list, region_type)
		-- If any plots in this area are eligible, choose one.
		local found_eligible = election_returns[1];
		if found_eligible then
			local bestPlotScore = election_returns[2]; 
			local bestPlotIndex = election_returns[3];
			local x = (bestPlotIndex - 1) % iW;
			local y = (bestPlotIndex - x - 1) / iW;
			self.startingPlots[region_number] = {x, y, bestPlotScore};
			self:PlaceImpactAndRipples(x, y)
			return true, false
		end
		-- If none eligible, check for fallback plot.
		local found_fallback = election_returns[4];
		if found_fallback then
			local bestFallbackScore = election_returns[5];
			local bestFallbackIndex = election_returns[6];
			local x = (bestFallbackIndex - 1) % iW;
			local y = (bestFallbackIndex - x - 1) / iW;
			table.insert(fallback_plots, {x, y, bestFallbackScore});
		end
	end
	-- Reaching this point means no strong sites far enough away from any already-placed start points.

	-- We will compare all the fallback plots and choose the best to be the start plot.
	local iNumFallbacks = table.maxn(fallback_plots);
	if iNumFallbacks > 0 then
		local best_fallback_score = -50
		local best_fallback_x;
		local best_fallback_y;
		for loop, plotData in ipairs(fallback_plots) do
			local score = plotData[3];
			if score > best_fallback_score then
				best_fallback_score = score;
				best_fallback_x = plotData[1];
				best_fallback_y = plotData[2];
			end
		end
		-- Assign the start for this region.
		self.startingPlots[region_number] = {best_fallback_x, best_fallback_y, best_fallback_score};
		self:PlaceImpactAndRipples(best_fallback_x, best_fallback_y)
		bSuccessFlag = true;
	else
		-- Somehow, this region has had no eligible plots of any kind.
		-- We'll force a one tile grass island in the SW corner of the region and put the start there.
		local forcePlot = Map.GetPlot(iWestX, iSouthY);
		bSuccessFlag = false;
		bForcedPlacementFlag = true;
		forcePlot:SetPlotType(PlotTypes.PLOT_LAND, false, true);
		forcePlot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, true);
		forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
		self.startingPlots[region_number] = {iWestX, iSouthY, 0};
		self:PlaceImpactAndRipples(iWestX, iSouthY)
	end

	return bSuccessFlag, bForcedPlacementFlag
end
------------------------------------------------------------------------------
function AssignStartingPlots:FindAllStart(region_number)
	-- This function attempts to choose a start position for a single region.
	-- This function returns two boolean flags, indicating the success level of the operation.
	local bSuccessFlag = false; -- Returns true when a start is placed, false when process fails.
	local bForcedPlacementFlag = false; -- Returns true if this region had no eligible starts and one was forced to occur.
	print("All Start");
	-- Obtain data needed to process this region.
	local iW, iH = Map.GetGridSize();
	local region_data_table = self.regionData[region_number];
	local iWestX = region_data_table[1];
	local iSouthY = region_data_table[2];
	local iWidth = region_data_table[3];
	local iHeight = region_data_table[4];
	local iAreaID = region_data_table[5];
	local iMembershipEastX = iWestX + iWidth - 1;
	local iMembershipNorthY = iSouthY + iHeight - 1;
	--
	local terrainCounts = self.regionTerrainCounts[region_number];
	--
	local region_type = self.regionTypes[region_number];
	-- Done setting up region data.
	-- Set up contingency.
	local fallback_plots = {};
	local fallback_water_plots = {};

	-- Establish scope of center bias.
	local fCenterWidth = (self.centerBias / 100) * iWidth;
	local iNonCenterWidth = math.floor((iWidth - fCenterWidth) / 2)
	local iCenterWidth = iWidth - (iNonCenterWidth * 2);
	local iCenterWestX = (iWestX + iNonCenterWidth) % iW; -- Modulo math to synch coordinate to actual map in case of world wrap.
	local iCenterTestWestX = (iWestX + iNonCenterWidth); -- "Test" values ignore world wrap for easier membership testing.
	local iCenterTestEastX = (iCenterWestX + iCenterWidth - 1);

	local fCenterHeight = (self.centerBias / 100) * iHeight;
	local iNonCenterHeight = math.floor((iHeight - fCenterHeight) / 2)
	local iCenterHeight = iHeight - (iNonCenterHeight * 2);
	local iCenterSouthY = (iSouthY + iNonCenterHeight) % iH;
	local iCenterTestSouthY = (iSouthY + iNonCenterHeight);
	local iCenterTestNorthY = (iCenterTestSouthY + iCenterHeight - 1);

	-- Establish scope of "middle donut", outside the center but inside the outer.
	local fMiddleWidth = (self.middleBias / 100) * iWidth;
	local iOuterWidth = math.floor((iWidth - fMiddleWidth) / 2)
	local iMiddleWidth = iWidth - (iOuterWidth * 2);
	local iMiddleWestX = (iWestX + iOuterWidth) % iW;
	local iMiddleTestWestX = (iWestX + iOuterWidth);
	local iMiddleTestEastX = (iMiddleTestWestX + iMiddleWidth - 1);

	local fMiddleHeight = (self.middleBias / 100) * iHeight;
	local iOuterHeight = math.floor((iHeight - fMiddleHeight) / 2)
	local iMiddleHeight = iHeight - (iOuterHeight * 2);
	local iMiddleSouthY = (iSouthY + iOuterHeight) % iH;
	local iMiddleTestSouthY = (iSouthY + iOuterHeight);
	local iMiddleTestNorthY = (iMiddleTestSouthY + iMiddleHeight - 1); 

	-- Assemble candidates lists.
	local center_candidates = {};
	local center_coast = {};
	local center_river = {};
	local center_coastal = {};
	local center_inland_dry = {};
	local middle_candidates = {};
	local middle_coast = {};
	local middle_river = {};
	local middle_coastal = {};
	local middle_inland_dry = {};
	local outer_coast_plots = {};
	local outer_plots = {};
	local outer_inland_plots = {};
	
	-- Identify candidate plots.
	for region_y = 0, iHeight - 1 do -- When handling global plot indices, process Y first.
		for region_x = 0, iWidth - 1 do
			local x = (region_x + iWestX) % iW; -- Actual coords, adjusted for world wrap, if any.
			local y = (region_y + iSouthY) % iH; --
			local plotIndex = y * iW + x + 1;
			local plot = Map.GetPlot(x, y);
			local plotType = plot:GetPlotType();
			local terrainType = plot:GetTerrainType();
			local featureType = plot:GetFeatureType();
			if ((terrainType == TerrainTypes.TERRAIN_COAST and featureType  ~= FeatureTypes.FEATURE_ICE ) or 
					(plotType == PlotTypes.PLOT_HILLS or plotType == PlotTypes.PLOT_LAND and self.mustBeCoast == false ) ) then -- Could host a city.
						-- Test whether plot is in center bias, middle donut, or outer donut.
						--
						local test_x = region_x + iWestX; -- "Test" coords, ignoring any world wrap and
						local test_y = region_y + iSouthY; -- reaching in to virtual space if necessary.
						if (test_x >= iCenterTestWestX and test_x <= iCenterTestEastX) and 
						   (test_y >= iCenterTestSouthY and test_y <= iCenterTestNorthY) then -- Center Bias.
							table.insert(center_candidates, plotIndex);
							if plot:IsRiverSide() and self.plotDataIsCoastal[plotIndex] == false then
								table.insert(center_river, plotIndex);
							elseif terrainType == TerrainTypes.TERRAIN_COAST and plot:IsLake() == false then
								table.insert(center_coast, plotIndex);
							elseif self.plotDataIsCoastal[plotIndex] == true then
								table.insert(center_coastal, plotIndex);
							else
								table.insert(center_inland_dry, plotIndex);
							end
						elseif (test_x >= iMiddleTestWestX and test_x <= iMiddleTestEastX) and 
						       (test_y >= iMiddleTestSouthY and test_y <= iMiddleTestNorthY) then
							table.insert(middle_candidates, plotIndex);
							if plot:IsRiverSide() and self.plotDataIsCoastal[plotIndex] == false then
								table.insert(middle_river, plotIndex);
							elseif terrainType == TerrainTypes.TERRAIN_COAST and plot:IsLake() == false  then
								table.insert(middle_coast, plotIndex);
							elseif self.plotDataIsCoastal[plotIndex] == true then
								table.insert(middle_coastal, plotIndex);
							else
								table.insert(middle_inland_dry, plotIndex);
							end
						else
							if(terrainType == TerrainTypes.TERRAIN_COAST ) then
								table.insert(outer_coast_plots, plotIndex);
							elseif self.plotDataIsCoastal[plotIndex] then
								table.insert(outer_plots, plotIndex);
							else
								table.insert(outer_inland_plots, plotIndex);
							end
						end
			end
		end
	end
	
	if (self.mustBeInOrAdjacentToWater == false) then
		for i, plotIndex in ipairs(outer_inland_plots) do
			table.insert(outer_plots, plotIndex);
		end
	end

	-- Check how many plots landed on each list.
	local iNumCenter = table.maxn(center_candidates);
	local iNumCenterRiver = table.maxn(center_river);
	local iNumCenterCoast = table.maxn(center_coast);
	local iNumCenterCoastal = table.maxn(center_coastal);
	local iNumCenterInlandDry = table.maxn(center_inland_dry);
	local iNumMiddle = table.maxn(middle_candidates);
	local iNumMiddleCoast = table.maxn(middle_coast);
	local iNumMiddleRiver = table.maxn(middle_river);
	local iNumMiddleCoastal = table.maxn(middle_coastal);
	local iNumMiddleInlandDry = table.maxn(middle_inland_dry);
	local iNumOuter = table.maxn(outer_plots);
	local iNumOuterCoast = table.maxn(outer_coast_plots);

	-- Debug printout.
	print("-");
	print("--- Number of Candidate Plots in Region #", region_number, " - Region Type:", region_type, " ---");
	print("-");
	print("Candidates in Center Bias area: ", iNumCenter);
	print("Which are next to river: ", iNumCenterRiver);
	print("Which are in sea: ", iNumCenterCoast);
	print("Which are next to lake or sea: ", iNumCenterCoastal);
	print("Which are inland and dry: ", iNumCenterInlandDry);
	print("-");
	print("Candidates in Middle Donut area: ", iNumMiddle);
	print("Which are next to river: ", iNumMiddleRiver);
	print("Which are in sea: ", iNumMiddleCoast);
	print("Which are next to lake or sea: ", iNumMiddleCoastal);
	print("Which are inland and dry: ", iNumMiddleInlandDry);
	print("-");
	print("Candidate Plots in Outer area: ", iNumOuter);
	print("-");
	print("Candidate Plots in Outer Coast area: ", iNumOuterCoast);
	print("-");
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	--
	
	-- Process lists of candidate plots.
	local foundLand = false;

	local landPlots = 0 - iNumCenterCoast - iNumMiddleCoast;

	if (not self.mustBeInWater) then
		landPlots = iNumCenter + iNumMiddle + landPlots; 
	end

	if landPlots > 0 then
		local candidate_lists = {};
		if iNumCenterRiver > 0 and self.mustBeInOrAdjacentToWater == false then -- Process center bias river plots.
			table.insert(candidate_lists, center_river);
		end
		if iNumCenterCoastal > 0 then -- Process center bias lake or coastal plots.
			table.insert(candidate_lists, center_coastal);
		end
		if iNumCenterInlandDry > 0 and self.mustBeInOrAdjacentToWater == false then -- Process center bias inland dry plots.
			table.insert(candidate_lists, center_inland_dry);
		end
		if iNumMiddleRiver > 0 and self.mustBeInOrAdjacentToWater == false then -- Process middle donut river plots.
			table.insert(candidate_lists, middle_river);
		end
		if iNumMiddleCoastal > 0 then -- Process middle donut lake or coastal plots.
			table.insert(candidate_lists, middle_coastal);
		end
		if iNumMiddleInlandDry > 0 and self.mustBeInOrAdjacentToWater == false then -- Process middle donut inland dry plots.
			table.insert(candidate_lists, middle_inland_dry);
		end

		--
		for loop, plot_list in ipairs(candidate_lists) do -- Up to six plot lists, processed by priority.
			local election_returns = self:IterateThroughCandidatePlotList(plot_list, region_type)
			-- If any candidates are eligible, choose one.
			local found_eligible = election_returns[1];
			if found_eligible and not foundLand then
				local bestPlotScore = election_returns[2]; 
				local bestPlotIndex = election_returns[3];
				local x = (bestPlotIndex - 1) % iW;
				local y = (bestPlotIndex - x - 1) / iW;
				self.startingPlots[region_number] = {x, y, bestPlotScore};
				self:PlaceImpactAndRipples(x, y)
				foundLand = true;
			end
			-- If none eligible, check for fallback plot.
			local found_fallback = election_returns[4];
			if found_fallback then
				local bestFallbackScore = election_returns[5];
				local bestFallbackIndex = election_returns[6];
				local x = (bestFallbackIndex - 1) % iW;
				local y = (bestFallbackIndex - x - 1) / iW;
				table.insert(fallback_plots, {x, y, bestFallbackScore});
			end
		end
	end

	-- Reaching this point means no eligible sites in center bias or middle donut subregions!
	
	-- Process candidates from Outer subregion, if any.
	if iNumOuter > 0 and not foundLand then
		local outer_eligible_list = {};
		local found_eligible = false;
		local found_fallback = false;
		local bestFallbackScore = -50;
		local bestFallbackIndex;
		-- Process list of candidate plots.
		for loop, plotIndex in ipairs(outer_plots) do
			local score, meets_minimums = self:EvaluateCandidatePlot(plotIndex, region_type)
			-- Test current plot against best known plot.
			if meets_minimums == true then
				found_eligible = true;
				table.insert(outer_eligible_list, plotIndex);
			else
				if score > bestFallbackScore then
					found_fallback = true;
					bestFallbackScore = score;
					bestFallbackIndex = plotIndex;
				end
			end
		end

		if found_eligible and not foundLand then -- Iterate through eligible plots and choose the one closest to the center of the region.
			local closestPlot;
			local closestDistance = math.max(iW, iH);
			local bullseyeX = iWestX + (iWidth / 2);
			if bullseyeX < iWestX then -- wrapped around: un-wrap it for test purposes.
				bullseyeX = bullseyeX + iW;
			end
			local bullseyeY = iSouthY + (iHeight / 2);
			if bullseyeY < iSouthY then -- wrapped around: un-wrap it for test purposes.
				bullseyeY = bullseyeY + iH;
			end
			if bullseyeY / 2 ~= math.floor(bullseyeY / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
				bullseyeX = bullseyeX + 0.5;
			end
			
			for loop, plotIndex in ipairs(outer_eligible_list) do
				local x = (plotIndex - 1) % iW;
				local y = (plotIndex - x - 1) / iW;
				local adjusted_x = x;
				local adjusted_y = y;
				if y / 2 ~= math.floor(y / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
					adjusted_x = x + 0.5;
				end
				
				if x < iWestX then -- wrapped around: un-wrap it for test purposes.
					adjusted_x = adjusted_x + iW;
				end
				if y < iSouthY then -- wrapped around: un-wrap it for test purposes.
					adjusted_y = y + iH;
				end
				local fDistance = math.sqrt( (adjusted_x - bullseyeX)^2 + (adjusted_y - bullseyeY)^2 );
				if fDistance < closestDistance then -- Found new "closer" plot.
					closestPlot = plotIndex;
					closestDistance = fDistance;
				end
			end
			-- Assign the closest eligible plot as the start point.
			local x = (closestPlot - 1) % iW;
			local y = (closestPlot - x - 1) / iW;
			-- Re-get plot score for inclusion in start plot data.
			local score, meets_minimums = self:EvaluateCandidatePlot(closestPlot, region_type)
			-- Assign this plot as the start for this region.
			self.startingPlots[region_number] = {x, y, score};
			self:PlaceImpactAndRipples(x, y)
			foundLand = true;
		end
		-- Add the fallback plot (best scored plot) from the Outer region to the fallback list.
		if found_fallback and not foundLand then
			local x = (bestFallbackIndex - 1) % iW;
			local y = (bestFallbackIndex - x - 1) / iW;
			table.insert(fallback_plots, {x, y, bestFallbackScore});
		end
	end

	-- Reaching here means no plot in the entire region met the minimum standards for selection.
	
	-- The fallback plot contains the best-scored plots from each test area in this region.
	-- We will compare all the fallback plots and choose the best to be the start plot.
	local iNumFallbacks = table.maxn(fallback_plots);
	if iNumFallbacks > 0 and not foundLand then
		local best_fallback_score = -50;
		local best_fallback_x;
		local best_fallback_y;
		for loop, plotData in ipairs(fallback_plots) do
			local score = plotData[3];
			if score > best_fallback_score then
				best_fallback_score = score;
				best_fallback_x = plotData[1];
				best_fallback_y = plotData[2];
			end
		end
		self.startingPlots[region_number] = {best_fallback_x, best_fallback_y, best_fallback_score};
		self:PlaceImpactAndRipples(best_fallback_x, best_fallback_y)
		bSuccessFlag = true;
	elseif not foundLand then
		-- This region cannot have a start and something has gone way wrong.
		-- We'll force a one tile grass island in the SW corner of the region and put the start there.
		local forcePlot = Map.GetPlot(iWestX, iSouthY);
		bSuccessFlag = true;
		bForcedPlacementFlag = true;
		forcePlot:SetPlotType(PlotTypes.PLOT_LAND, false, true);
		forcePlot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, true);
		forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
		self.startingPlots[region_number] = {iWestX, iSouthY, 0};
		self:PlaceImpactAndRipples(iWestX, iSouthY)
	end

	-- Process lists of water candidate plots.

	if iNumCenterCoast + iNumMiddleCoast > 0 then
		local candidate_lists = {};
		if iNumCenterCoast > 0 then -- Process center coast.
			table.insert(candidate_lists, center_coast);
		end
		if iNumMiddleCoast > 0 then -- Process middle coast.
			table.insert(candidate_lists, middle_coast);
		end

		--
		for loop, plot_list in ipairs(candidate_lists) do -- Up to six plot lists, processed by priority.
			local election_returns = self:IterateThroughCandidatePlotList(plot_list, region_type)
			-- If any candidates are eligible, choose one.
			local found_eligible = election_returns[1];
			if found_eligible then
				local bestPlotScore = election_returns[2]; 
				local bestPlotIndex = election_returns[3];
				local x = (bestPlotIndex - 1) % iW;
				local y = (bestPlotIndex - x - 1) / iW;
				self.startingWaterPlots[region_number] = {x, y, bestPlotScore};
				self:PlaceImpactAndRipples(x, y)
				return true, false
			end
			-- If none eligible, check for fallback plot.
			local found_fallback = election_returns[4];
			if found_fallback then
				local bestFallbackScore = election_returns[5];
				local bestFallbackIndex = election_returns[6];
				local x = (bestFallbackIndex - 1) % iW;
				local y = (bestFallbackIndex - x - 1) / iW;
				table.insert(fallback_water_plots, {x, y, bestFallbackScore});
			end
		end
	end
	-- Reaching this point means no eligible sites in center bias or middle donut subregions!
	
	-- Process candidates from Outer subregion, if any.
	if iNumOuterCoast > 0 then
		local outer_eligible_list = {};
		local found_eligible = false;
		local found_fallback = false;
		local bestFallbackScore = -50;
		local bestFallbackIndex;
		-- Process list of candidate plots.
		for loop, plotIndex in ipairs(outer_coast_plots) do
			local score, meets_minimums = self:EvaluateCandidatePlot(plotIndex, region_type)
			-- Test current plot against best known plot.
			if meets_minimums == true then
				found_eligible = true;
				table.insert(outer_eligible_list, plotIndex);
			else
				if score > bestFallbackScore then
					found_fallback = true;
					bestFallbackScore = score;
					bestFallbackIndex = plotIndex;
				end
			end
		end

		if found_eligible then -- Iterate through eligible plots and choose the one closest to the center of the region.
			local closestPlot;
			local closestDistance = math.max(iW, iH);
			local bullseyeX = iWestX + (iWidth / 2);
			if bullseyeX < iWestX then -- wrapped around: un-wrap it for test purposes.
				bullseyeX = bullseyeX + iW;
			end
			local bullseyeY = iSouthY + (iHeight / 2);
			if bullseyeY < iSouthY then -- wrapped around: un-wrap it for test purposes.
				bullseyeY = bullseyeY + iH;
			end
			if bullseyeY / 2 ~= math.floor(bullseyeY / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
				bullseyeX = bullseyeX + 0.5;
			end
			
			for loop, plotIndex in ipairs(outer_eligible_list) do
				local x = (plotIndex - 1) % iW;
				local y = (plotIndex - x - 1) / iW;
				local adjusted_x = x;
				local adjusted_y = y;
				if y / 2 ~= math.floor(y / 2) then -- Y coord is odd, add .5 to X coord for hex-shift.
					adjusted_x = x + 0.5;
				end
				
				if x < iWestX then -- wrapped around: un-wrap it for test purposes.
					adjusted_x = adjusted_x + iW;
				end
				if y < iSouthY then -- wrapped around: un-wrap it for test purposes.
					adjusted_y = y + iH;
				end
				local fDistance = math.sqrt( (adjusted_x - bullseyeX)^2 + (adjusted_y - bullseyeY)^2 );
				if fDistance < closestDistance then -- Found new "closer" plot.
					closestPlot = plotIndex;
					closestDistance = fDistance;
				end
			end
			-- Assign the closest eligible plot as the start point.
			local x = (closestPlot - 1) % iW;
			local y = (closestPlot - x - 1) / iW;
			-- Re-get plot score for inclusion in start plot data.
			local score, meets_minimums = self:EvaluateCandidatePlot(closestPlot, region_type)
			-- Assign this plot as the start for this region.
			self.startingWaterPlots[region_number] = {x, y, score};
			self:PlaceImpactAndRipples(x, y)
			return true, false
		end
		-- Add the fallback plot (best scored plot) from the Outer region to the fallback list.
		if found_fallback and bestFallbackIndex ~= nil  then
			local x = (bestFallbackIndex - 1) % iW;
			local y = (bestFallbackIndex - x - 1) / iW;
			table.insert(fallback_water_plots, {x, y, bestFallbackScore});
		end
	end

	-- Reaching here means no plot in the entire region met the minimum standards for selection.
	
	-- The fallback plot contains the best-scored plots from each test area in this region.
	-- We will compare all the fallback plots and choose the best to be the start plot.
	local iNumFallbacks = table.maxn(fallback_water_plots);
	if iNumFallbacks > 0 then
		local best_fallback_score = -50
		local best_fallback_x;
		local best_fallback_y;
		for loop, plotData in ipairs(fallback_water_plots) do
			local score = plotData[3];
			if score > best_fallback_score then
				best_fallback_score = score;
				best_fallback_x = plotData[1];
				best_fallback_y = plotData[2];
			end
		end
		self.startingWaterPlots[region_number] = {best_fallback_x, best_fallback_y, best_fallback_score};
		self:PlaceImpactAndRipples(best_fallback_x, best_fallback_y)
	else
		-- This region cannot have a start and something has gone way wrong.
		-- We'll force a one tile grass island in the SW corner of the region and put the start there.
		local forcePlot = Map.GetPlot(iWestX, iSouthY);
		forcePlot:SetPlotType(PlotTypes.PLOT_OCEAN, false, true);
		forcePlot:SetTerrainType(TerrainTypes.TERRAIN_COAST, false, true);
		forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
		self.startingWaterPlots[region_number] = {iWestX, iSouthY, 0};
		self:PlaceImpactAndRipples(iWestX, iSouthY)
	end

	return bSuccessFlag, bForcedPlacementFlag
end
------------------------------------------------------------------------------
function AssignStartingPlots:ChooseLocations(args)
	print("Map Generation - Choosing Start Locations for Civilizations");
	local args = args or {};
	local iW, iH = Map.GetGridSize();
	self.mustBeInOrAdjacentToWater = args.mustBeInOrAdjacentToWater or false; -- if true, will force all starts on salt water coast land tiles and water tiles
	self.mustBeInWater = args.mustBeInWater or false; -- if true, will force all starts on salt water coast tiles if possible

	-- Check game option to force in or adjacent to water starts
	if (Game.IsOption("GAMEOPTION_ALL_ADJACENT_OR_WATER_STARTS") == true) then
		self.mustBeInOrAdjacentToWater = true;
	end

	-- Check game option to force water starts
	if (Game.IsOption("GAMEOPTION_ALL_IN_WATER_STARTS") == true) then
		self.mustBeInWater = true;
	end

	-- Defaults for evaluating potential start plots are assigned in .Create but args
	-- passed in here can override. If args value for a field is nil (no arg) then
	-- these assignments will keep the default values in place.
	self.centerBias = args.centerBias or self.centerBias; -- % of radius from region center to examine first
	self.middleBias = args.middleBias or self.middleBias; -- % of radius from region center to check second
	self.minFoodInner = args.minFoodInner or self.minFoodInner;
	self.minProdInner = args.minProdInner or self.minProdInner;
	self.minGoodInner = args.minGoodInner or self.minGoodInner;
	self.minFoodMiddle = args.minFoodMiddle or self.minFoodMiddle;
	self.minProdMiddle = args.minProdMiddle or self.minProdMiddle;
	self.minGoodMiddle = args.minGoodMiddle or self.minGoodMiddle;
	self.minFoodOuter = args.minFoodOuter or self.minFoodOuter;
	self.minProdOuter = args.minProdOuter or self.minProdOuter;
	self.minGoodOuter = args.minGoodOuter or self.minGoodOuter;
	self.maxJunk = args.maxJunk or self.maxJunk;
	-- Create Wild Areas data layer. Starts will attempt to avoid Wild Areas.
	self:WildAreasImpactLayer()

	-- Measure terrain/plot/feature in regions.
	self:MeasureTerrainInRegions()
	
	-- Determine region type.
	self:DetermineRegionTypes()

	-- Set up list of regions (to be processed in this order).
	--
	-- First, make a list of all average fertility values...
	local regionAssignList = {};
	local averageFertilityListUnsorted = {};
	local averageFertilityListSorted = {}; -- Have to make this a separate table, not merely a pointer to the first table.
	for i, region_data in ipairs(self.regionData) do
		local thisRegionAvgFert = region_data[8];
		table.insert(averageFertilityListUnsorted, {i, thisRegionAvgFert});
		table.insert(averageFertilityListSorted, thisRegionAvgFert);
	end
	-- Now sort the copy low to high.
	table.sort(averageFertilityListSorted);
	-- Finally, match each sorted fertilty value to the matching unsorted region number and record in sequence.
	local iNumRegions = table.maxn(averageFertilityListSorted);
	for region_order = 1, iNumRegions do
		for loop, data_pair in ipairs(averageFertilityListUnsorted) do
			local unsorted_fert = data_pair[2];
			if averageFertilityListSorted[region_order] == unsorted_fert then
				local unsorted_reg_num = data_pair[1];
				table.insert(regionAssignList, unsorted_reg_num);
				-- HAVE TO remove the entry from the table in rare case of ties on fert 
				-- value. Or it will just match this value for a second time, then crash 
				-- when the region it was tied with ends up with nil data.
				table.remove(averageFertilityListUnsorted, loop);
				break
			end
		end
	end

	-- main loop
	for assignIndex = 1, iNumRegions do
		local currentRegionNumber = regionAssignList[assignIndex];
		local bSuccessFlag = false;
		local bForcedPlacementFlag = false;
		
		if self.method == 3 or self.method == 4 then
			bSuccessFlag, bForcedPlacementFlag = self:FindStartWithoutRegardToAreaID(currentRegionNumber)
		elseif self.method == 5 then
			bSuccessFlag, bForcedPlacementFlag = self:FindAllStart(currentRegionNumber)
		else
			bSuccessFlag, bForcedPlacementFlag = self:FindStart(currentRegionNumber)
		end
		
		--[[ Printout for debug only.
		print("- - -");
		print("Start Plot for Region #", currentRegionNumber, " was successful: ", bSuccessFlag);
		print("Start Plot for Region #", currentRegionNumber, " was forced: ", bForcedPlacementFlag);
		]]--		
	end
	--

	-- Printout of start plots. Debug use only.
	print("-");
	print("--- Table of results, Start Finder ---");
	for loop, startData in ipairs(self.startingPlots) do
		print("-");
		print("Region#", loop, " has start plot at: ", startData[1], startData[2], "with Fertility Rating of ", startData[3]);
	end
	print("-");
	print("--- Table of results, Start Finder ---");
	print("-");
	--
	
	-- Printout of start plots. Debug use only.
	print("-");
	print("--- Table of results, Start Finder ---");
	for loop, startData in ipairs(self.startingWaterPlots) do
		print("-");
		print("Region#", loop, " has start plot at: ", startData[1], startData[2], "with Fertility Rating of ", startData[3]);
	end
	print("-");
	print("--- Table of results, Start Finder ---");
	print("-");
	--

	--[[ Printout of Impact and Ripple data.
	print("--- Impact and Ripple ---");
	PrintContentsOfTable(self.distanceData)
	print("-");  ]]--
end
------------------------------------------------------------------------------
function AssignStartingPlots:AttemptToPlaceHillsAtPlot(x, y)
	-- This function will add hills at a specified plot, if able.
	--print("-"); print("Attempting to add Hills at: ", x, y);
	local plot = Map.GetPlot(x, y);
	if plot == nil then
		--print("Placement failed, plot was nil.");
		return false
	end
	if plot:GetResourceType(-1) ~= -1 then
		--print("Placement failed, plot had a resource.");
		return false
	end
	local plotType = plot:GetPlotType()
	local featureType = plot:GetFeatureType();
	if plotType == PlotTypes.PLOT_OCEAN then
		--print("Placement failed, plot was water.");
		return false
	elseif plotType == PlotTypes.PLOT_CANYON then
		--print("Placement failed, plot was canyon.");
		return false
	elseif plot:IsRiverSide() then
		--print("Placement failed, plot was next to river.");
		return false
	elseif featureType == FeatureTypes.FEATURE_FOREST then
		--print("Placement failed, plot had a forest already.");
		return false
	end	
	-- Change the plot type from flatlands to hills and clear any features.
	plot:SetPlotType(PlotTypes.PLOT_HILLS, false, true);
	plot:SetFeatureType(FeatureTypes.NO_FEATURE, -1);
	return true
end
------------------------------------------------------------------------------
function AssignStartingPlots:CreateResources(fertilityMap : table)

	print("Creating Resources - Weighted Density method (AssignStartingPlots.Lua)");

	--Initialize quantities
	local k = 0;
	local affinity_Count = 0;
	for resInfo in GameInfo.Resources() do
		self.resourceQuantity[k] = {};
		local j = 0;

		if(resInfo.Affinity) then
			affinity_Count = affinity_Count +1;
		end

		for resourceQuantityInfo in GameInfo.Resource_QuantityTypes("ResourceType = \"" .. resInfo.Type .. "\"") do
			self.resourceQuantity[k][j] = 0;
			j = j + 1;
		end
		k = k + 1;
	end

	-- What % of the relevant plots should get a resource (roughly)
	local landDensity : number = 20;
	local seaDensity : number = 30;

	local gridWidth : number, gridHeight : number = Map.GetGridSize();
	local baseRunningWeight = ((gridWidth * gridHeight) * (landDensity / 4)) / 100;
	local resourceTrackingTable : table = {};	

	for row in GameInfo.Resources("ResourceClassType = 'RESOURCECLASS_BASIC' OR ResourceClassType = 'RESOURCECLASS_STRATEGIC'") do
		local resourceData : table = {
			Class = row.ResourceClassType,
			RunningWeight = baseRunningWeight,
			NegativeWeight = row.NegativeWeight,
		};
		resourceTrackingTable[row.ID] = resourceData;
	end

	local plotResourceWeights : table = {};
	for i:number, plot:object in Plots() do

		local randChance : number = Map.Rand(100, "Resource random chance");
		local density : number = landDensity;
		if (plot:IsWater()) then
			density = seaDensity;
		end

		if (randChance <= density) then

			plotResourceWeights = {};
			local resourceID : number = -1;
			local totalWeight : number = 0;

			-- Compile weighted table of valid resources for this plot
			for id:number, resourceInfo:table in pairs(resourceTrackingTable) do
				local starting = false;
				local negative = false;
				for i : number = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
					local player : object = Players[i];
					if(player == nil) then
						error("player was nil");
					end
					if(player:IsAlive()) then
						local playerStartPlot = player:GetStartingPlot();
						if(plot:GetPlotIndex() == playerStartPlot:GetPlotIndex()) then
							starting = true;
						end
					end
				end
				
				if(resourceInfo.NegativeWeight > 0) then
					local negativeWeight = resourceInfo.NegativeWeight;
					local randomWeight = Game.Rand(100, "Weight");
					if (negativeWeight >= randomWeight) then
						negative = true;
					end
				end

				if plot:CanHaveResource(id) and starting == false and negative == false then
					table.insert(plotResourceWeights, {ID = id, Weight = resourceInfo.RunningWeight});
					totalWeight = totalWeight + resourceInfo.RunningWeight;
				end
			end

			if #plotResourceWeights > 0 then
				local weightRoll : number = Map.Rand(totalWeight, "Resource weight roll");
				for j:number, pair:table in ipairs(plotResourceWeights) do
					if (weightRoll <= pair.Weight) then
						resourceID = pair.ID;
						break;
					else
						weightRoll = weightRoll - pair.Weight;
					end
				end
			end

			if (resourceID >= 0) then				

				local amount : number = 1;
				local resourceInfo : table = GameInfo.Resources[resourceID];
				local quantity : table = {};

				-- Determine quantity for strategic resources
				if (resourceInfo.ResourceClassType == "RESOURCECLASS_STRATEGIC") then					
					local amountTotal = 0; -- Number of variations of this resource
					local randomFactor = 10; --Number to increase randomness
					local id = resourceInfo.ID;

					for resourceQuantityInfo in GameInfo.Resource_QuantityTypes("ResourceType = \"" .. resourceInfo.Type .. "\"") do
						local inputSetting = 2;
						if (resourceQuantityInfo.Setting == 1 or resourceQuantityInfo.Setting == 3) then
							inputSetting = resourceQuantityInfo.Setting;
						end
						
						if(resourceQuantityInfo.Max ~= nil and resourceQuantityInfo.Min ~= nil and (inputSetting == self.resource_setting or  self.resource_setting > 3)) then
							local min = resourceQuantityInfo.Min;
							local max = resourceQuantityInfo.Max;

							local quantityNumber = self:Quantities(id,amountTotal, min,max);

							table.insert(quantity, quantityNumber);
							print("Resource: ", resourceInfo.Type, " Minimum: ", min, " Maximum: ", max, " Quantity: ", quantityNumber);
							amountTotal = amountTotal + 1;
						end
					end

					
					table.sort(quantity);

					if (#quantity > 0 and amountTotal > 0) then
						local resourceAmount : number = Game.Rand(amountTotal * randomFactor, "Choosing quantity") + 1;
						--Go through a weighted list. The higher weight replaces the lower weight
						for j = 1, amountTotal, 1 do
							if(resourceAmount > (randomFactor * j) / amountTotal + randomFactor / amountTotal or j == 1) then
								amount = quantity[j];
							end
						end
					end
				end
				
				-- Check for being too close to a civ start.
				local bCanPlaceResource = true;
				local radius = 3;
				local playerNum = -1;
				for dx = -radius, radius do
					for dy = -radius, radius do
						local otherPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, radius);
						if(otherPlot) then
							if otherPlot:IsStartingPlot() then -- Loop through all ever-alive major civs, check if their start plot matches "otherPlot"
								for player_num = 1, self.iNumCivs do
									if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
										local x = self.startingPlots[player_num][1];
										local y = self.startingPlots[player_num][2];

										-- Do not allow resources unless they are strategic
										local specialPass = false;
										if((math.abs(dx) + math.abs(dy) >= 3) and resourceInfo.ResourceClassType == GameInfo.ResourceClasses["RESOURCECLASS_STRATEGIC"].Type and quantity[1] == amount) then
											specialPass = true;
										end

										if ((otherPlot:GetX() == x and otherPlot:GetY() == y) and not (specialPass)) then
											bCanPlaceResource =  false;
										end
									end
								end
							end
						end
					end
				end
								
				if bCanPlaceResource == true then
					plot:SetResourceType(resourceID, amount);
				end

				print("resource: ", resourceInfo.Type, " amount: ", amount, " x: ", plot:GetX(), " y: ", plot:GetY());

				local weightReduction: number = 1;
				if (resourceInfo.ResourceClassType == "RESOURCECLASS_STRATEGIC") then
					weightReduction = 2;
				end
				resourceTrackingTable[resourceID].RunningWeight = resourceTrackingTable[resourceID].RunningWeight - weightReduction;
			end
		end
	end

	-- Add mandatory titanium, geothermal, petroleum to every start if Strategic Balance option is enabled.
	if self.resource_setting == 5 then
		local strategic = {};
		local resourceCount = 0;
		for resInfo in GameInfo.Resources() do
			if(resInfo.ResourceClassType == GameInfo.ResourceClasses["RESOURCECLASS_STRATEGIC"].Type ) then
				if (resInfo.Affinity == false) then
					table.insert(strategic, resInfo.ID);
					resourceCount = resourceCount + 1;
				end
			end
		end

		for player_num = 1, self.iNumCivs do
			if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
				local x = self.startingPlots[player_num][1];
				local y = self.startingPlots[player_num][2];
				local plot = Map.GetPlot(x, y);
			
				local shuffled = GetShuffledCopyOfTable(strategic);
				for i = 1, resourceCount + 1, 1 do
					self.resourcesSet = 1;
					local copy = {};
					table.insert(copy, shuffled[i]);
					self:SetResources(copy, plot, 2)
				end
			end
		end
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:Quantities(resource, amount, min, max)
	local id = resource;
	local variations = amount;
	local minimum = min;
	local maximum = max;

	if (self.resourceQuantity[id][amount] == 0) then
		self.resourceQuantity[id][amount] =   Game.Rand(maximum - minimum, "Choosing quantity") + minimum;
	end

	return self.resourceQuantity[id][amount];
end

------------------------------------------------------------------------------
function AssignStartingPlots:InvalidBorderRegion(terrain, plotX, plotY)
	--Returns true if this plot is ocean and adjacent to coast
	local terrainType = terrain;
	local x = plotX;
	local y = plotY;

	if(terrainType == TerrainTypes.TERRAIN_OCEAN) then
		for loop, direction in ipairs(self.direction_types) do
			local adjacentPlot = Map.PlotDirection(x, y, direction)
			if (adjacentPlot ~= nil) then
				local adjacentTerrain = adjacentPlot:GetTerrainType();

				if(adjacentTerrain == TerrainTypes.TERRAIN_COAST) then
					return true;
				end
			end
		end
	end

	return false;
end

------------------------------------------------------------------------------
--This function makes sure the ocean plot can be claimed by a water city's territory skirt
function AssignStartingPlots:ReachableByWaterCity(plotX, plotY)
	
	for loop, direction in ipairs(self.direction_types) do
		local adjacentPlot = Map.PlotDirection(plotX, plotY, direction);

		if (adjacentPlot ~= nil) then
			local adjacentTerrain = adjacentPlot:GetTerrainType();
			local adjacentFeature = adjacentPlot:GetFeatureType();
			if(adjacentTerrain == TerrainTypes.TERRAIN_COAST and adjacentFeature ~= FeatureTypes.FEATURE_ICE) then
				return true;
			end
		end
	end

	return false;
end

------------------------------------------------------------------------------
function AssignStartingPlots:FindFallbackForUnmatchedRegionPriority(iRegionType, regions_still_available)
	-- Region start biases disabled for Civ:BE. This function is dormant.
	--
	-- This function acts upon Civs with a single Region Priority who were unable to be 
	-- matched to a region of their priority type. We will scan remaining regions for the
	-- one with the most plots of the matching terrain type.
	local iMostTundra, iMostTundraForest, iMostJungle, iMostForest, iMostDesert = 0, 0, 0, 0, 0;
	local iMostHills, iMostPlains, iMostGrass, iMostHybrid = 0, 0, 0, 0;
	local bestTundra, bestTundraForest, bestJungle, bestForest, bestDesert = -1, -1, -1, -1, -1;
	local bestHills, bestPlains, bestGrass, bestHybrid = -1, -1, -1, -1;

	for loop, region_number in ipairs(regions_still_available) do
		local terrainCounts = self.regionTerrainCounts[region_number];
		--local totalPlots = terrainCounts[1];
		--local areaPlots = terrainCounts[2];
		--local waterCount = terrainCounts[3];
		local flatlandsCount = terrainCounts[4];
		local hillsCount = terrainCounts[5];
		local peaksCount = terrainCounts[6];
		--local lakeCount = terrainCounts[7];
		local coastCount = terrainCounts[8];
		local oceanCount = terrainCounts[9];
		--local iceCount = terrainCounts[10];
		local grassCount = terrainCounts[11];
		local plainsCount = terrainCounts[12];
		local desertCount = terrainCounts[13];
		local tundraCount = terrainCounts[14];
		local snowCount = terrainCounts[15];
		local forestCount = terrainCounts[16];
		local jungleCount = terrainCounts[17];
		local marshCount = terrainCounts[18];
		--local riverCount = terrainCounts[19];
		local floodplainCount = terrainCounts[20];
		--local oasisCount = terrainCounts[21];
		--local coastalLandCount = terrainCounts[22];
		--local nextToCoastCount = terrainCounts[23];
		
		if iRegionType == 1 then -- Find fallback for Tundra priority------------------------------------------------------------------------------
			if tundraCount + snowCount > iMostTundra then
				bestTundra = region_number;
				iMostTundra = tundraCount + snowCount;
			end
			if forestCount > iMostTundraForest and jungleCount == 0 then
				bestTundraForest = region_number;
				iMostTundraForest = forestCount;
			end
		elseif iRegionType == 2 then -- Find fallback for Jungle priority
			if jungleCount > iMostJungle then
				bestJungle = region_number;
				iMostJungle = jungleCount;
			end
		elseif iRegionType == 3 then -- Find fallback for Forest priority
			if forestCount > iMostForest then
				bestForest = region_number;
				iMostForest = forestCount;
			end
		elseif iRegionType == 4 then -- Find fallback for Desert priority
			if desertCount + floodplainCount > iMostDesert then
				bestDesert = region_number;
				iMostDesert = desertCount + floodplainCount;
			end
		elseif iRegionType == 5 then -- Find fallback for Hills priority
			if hillsCount + peaksCount > iMostHills then
				bestHills = region_number;
				iMostHills = hillsCount + peaksCount;
			end
		elseif iRegionType == 6 then -- Find fallback for Plains priority
			if plainsCount > iMostPlains then
				bestPlains = region_number;
				iMostPlains = plainsCount;
			end
		elseif iRegionType == 7 then -- Find fallback for Grass priority
			if grassCount + marshCount > iMostGrass then
				bestGrass = region_number;
				iMostGrass = grassCount + marshCount;
			end
		elseif iRegionType == 8 then -- Find fallback for Hybrid priority
			if coastCount > iMostHybrid then
				bestHybrid = region_number;
				iMostHybrid = grassCount + plainsCount;
			end
		elseif iRegionType == 9 then -- Find fallback for Hybrid priority
			if grassCount + plainsCount > iMostHybrid then
				bestHybrid = region_number;
				iMostHybrid = grassCount + plainsCount;
			end
		end
	end
	
	if iRegionType == 1 then
		if bestTundra ~= -1 then
			return bestTundra
		elseif bestTundraForest ~= -1 then
			return bestTundraForest
		end
	elseif iRegionType == 2 and bestJungle ~= -1 then
		return bestJungle
	elseif iRegionType == 3 and bestForest ~= -1 then
		return bestForest
	elseif iRegionType == 4 and bestDesert ~= -1 then
		return bestDesert
	elseif iRegionType == 5 and bestHills ~= -1 then
		return bestHills
	elseif iRegionType == 6 and bestPlains ~= -1 then
		return bestPlains
	elseif iRegionType == 7 and bestGrass ~= -1 then
		return bestGrass
	elseif iRegionType == 8 and bestHybrid ~= -1 then
		return bestHybrid
	end

	return -1
end
------------------------------------------------------------------------------
function AssignStartingPlots:NormalizeTeamLocations()
	-- This function will reorganize which Civs are assigned to which start
	-- locations, to ensure that Civs on the same team start near one another.
	--Game:NormalizeStartingPlotLocations() 
end
------------------------------------------------------------------------------
function AssignStartingPlots:BalanceAndAssign()
	local playerList = {};
	for loop = 1, self.iNumCivs do
		local player_ID = self.player_ID_list[loop];
		table.insert(playerList, player_ID);
	end
	local playerListShuffled = GetShuffledCopyOfTable(playerList)
		-- Generate lists of player needs. Each additional need type is subordinate to those
	-- that come before. In other words, each Civ can have only one need type.

	local civ_set = table.fill(false, GameDefines.MAX_MAJOR_CIVS); -- Have to account for possible gaps in player ID numbers, for MP.
	local region_status = table.fill(false, self.iNumCivs);

	--Water Players
	local waterPlayers = 0;
	local waterPlayerList = {};
	for loop = 1, self.iNumCivs do
		local player_ID = self.player_ID_list[loop];
		local player = Players[player_ID];
		local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type;
		local bCivNeedsWaterStart = PlayerShouldStartWater(player_ID);
		if bCivNeedsWaterStart then
			table.insert(waterPlayerList , player_ID);
			print("Water Start is needed for Player", player_ID, "of Civ Type", civType);
			waterPlayers = waterPlayers + 1;
		end
	end

	--Water Starts
	self.startingWaterPlots = self:SpecialSort(self.startingWaterPlots, 3);
	local waterPlayerListShuffled = GetShuffledCopyOfTable(waterPlayerList );
	if(waterPlayers > 0 and self.method == 5) then
		-- Set water plots
		for region_number, player_ID in ipairs(waterPlayerListShuffled) do
			if(self.startingWaterPlots[region_number][1] ~= nil and self.startingWaterPlots[region_number][2] ~= nil) and not region_status[region_number] and not civ_set[player_ID+1] then
				local x = self.startingWaterPlots[region_number][1];
				local y = self.startingWaterPlots[region_number][2];
				local player = Players[player_ID];
				local start_plot = Map.GetPlot(x, y);
				local terrainType = start_plot:GetTerrainType();
				local featureType = start_plot:GetFeatureType();

				--Set the starting position as this water starting position
				if terrainType == TerrainTypes.TERRAIN_COAST and featureType  ~= FeatureTypes.FEATURE_ICE then
					print("Player: ", player_ID, "Is Starting in Water. x: ", x, " y: ", y);
					civ_set[player_ID+1] = true;
					region_status[region_number] = true;
					self.startingPlots[region_number][1] = x;
					self.startingPlots[region_number][2] = y;
					player:SetStartingPlot(start_plot);
				else
					print("Invalid Water Terrain");
				end
			else
				print("Invalid Start Coordinates Water");
			end
		end
	end

	-- Land Starts
	local regions = {};
	for region_number, player_ID in ipairs(playerListShuffled) do
		--If the region has a civ or the civ has a starting position
		if (region_status[region_number]) then
			print("The region has been used. Region: ", region_number);
		elseif (civ_set[player_ID+1]) then
			print("The player has started before. Player_id: ", player_ID);
			table.insert(regions, region_number);
		elseif(self.startingPlots[region_number][1] ~= nil and self.startingPlots[region_number][2] ~= nil and player_ID ~= -1) then
			local x = self.startingPlots[region_number][1];
			local y = self.startingPlots[region_number][2];
			local player = Players[player_ID]
			local start_plot = Map.GetPlot(x, y)
			local terrainType = start_plot:GetTerrainType();
				print("Player: ", player_ID, "Is Starting in Land. x: ", x, " y: ", y);
				player:SetStartingPlot(start_plot);
				civ_set[player_ID+1] = true;
				region_status[region_number] = true;
		else
			print("Invalid Start Coordinates Land");
		end
	end
	
	local playerList2 = {};
	for region_number, player_ID in ipairs(playerListShuffled) do
		if(civ_set[player_ID+1] == false) then
			table.insert(playerList2, player_ID);
			print("This player needs a second chance: ", player_ID);
		end
	end
	local playerListShuffled2 = GetShuffledCopyOfTable(playerList2);

	for i, player_ID in ipairs(playerListShuffled2) do
		for j, region_number in ipairs(regions) do
			if (region_status[region_number]) then
				print("The player has started before or the region has been used. Region: ", region_number);
			elseif (civ_set[player_ID+1]) then
				print("The player has started before. Player_id: ", player_ID);
			else
				local x = self.startingPlots[region_number][1];
				local y = self.startingPlots[region_number][2];
				local player = Players[player_ID]
				local start_plot = Map.GetPlot(x, y)
				local terrainType = start_plot:GetTerrainType();
				
				print("Player: ", player_ID, "Is Starting in Land. x: ", x, " y: ", y);
				player:SetStartingPlot(start_plot);
				civ_set[player_ID+1] = true;
				region_status[region_number] = true;
			end
		end
	end

	return;
end
------------------------------------------------------------------------------
function AssignStartingPlots:SpecialSort(sortTable, key)
	--Used to sort a 2d array like Waterplayerstart
	local new = {};
	local highest = math.huge;
	for i, t1 in ipairs(sortTable) do
		local nextHighest = 0;
		for j, t2 in ipairs(sortTable) do
			local score = t2[key];

			if (nextHighest < score and score < highest) then
				nextHighest = score;
			end
		end

		for j, t2 in ipairs(sortTable) do
			if (t2[key] == nextHighest and self.regionTypes[j] == 8) then
				table.insert(new,t2);
			end
		end
		highest = nextHighest;
	end	

	return new;
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceNaturalWonders()
end
------------------------------------------------------------------------------
-- Start of functions tied to SetStationStartingPlots()
-----------------------------------------------------------------------------
function AssignStartingPlots:SetStationStartingPlots(args)
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Start of functions tied to PlaceCityStates() -- Not used in BE.
------------------------------------------------------------------------------
function AssignStartingPlots:AssignCityStatesToRegionsOrToUninhabited(args)
end
------------------------------------------------------------------------------
function AssignStartingPlots:CanPlaceCityStateAt(x, y, area_ID, force_it, ignore_collisions)
end
------------------------------------------------------------------------------
function AssignStartingPlots:ObtainNextSectionInRegion(incoming_west_x, incoming_south_y,incoming_width, incoming_height, iAreaID, force_it, ignore_collisions)
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceCityState(coastal_plot_list, inland_plot_list, check_proximity, check_collision)
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceCityStateInRegion(city_state_number, region_number)
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceCityStates()
end
------------------------------------------------------------------------------
function AssignStartingPlots:NormalizeCityState(x, y)
end
------------------------------------------------------------------------------
function AssignStartingPlots:NormalizeCityStateLocations()
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Start of functions tied to PlaceResourcesAndCityStates()
------------------------------------------------------------------------------
function AssignStartingPlots:ResourceListCheckPlotForWildness(plot)
	-- Eliminated.
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceResourceImpact(x, y, impact_table_number, radius)
	-- This function operates upon one of the "impact and ripple" data overlays for resources.
	-- These data layers are a primary way of preventing assignments from clustering too much.
	-- Impact #s - 1 strategic - 2 luxury - 3 bonus - 4 fish - 5 city states - 6 natural wonders - 7 marble - 8 sheep
	local iW, iH = Map.GetGridSize();
	local wrapX = Map:IsWrapX();
	local wrapY = Map:IsWrapY();
	local impact_value = 99;
	local odd = self.firstRingYIsOdd;
	local even = self.firstRingYIsEven;
	local nextX, nextY, plot_adjustments;
	-- Place Impact!
	local impactPlotIndex = y * iW + x + 1;
	if impact_table_number == 1 then
		self.strategicData[impactPlotIndex] = impact_value;
	elseif impact_table_number == 3 then
		self.bonusData[impactPlotIndex] = impact_value;
	elseif impact_table_number == 4 then
		self.fishData[impactPlotIndex] = 1;
	elseif impact_table_number == 5 then
		self.cityStateData[impactPlotIndex] = impact_value;
	elseif impact_table_number == 6 then
		self.naturalWondersData[impactPlotIndex] = impact_value;
	end
	if radius == 0 then
		return
	end
	-- Place Ripples
	if radius > 0 and radius < iH / 2 then
		for ripple_radius = 1, radius do
			local ripple_value = radius - ripple_radius + 1;
			-- Moving clockwise around the ring, the first direction to travel will be Northeast.
			-- This matches the direction-based data in the odd and even tables. Each
			-- subsequent change in direction will correctly match with these tables, too.
			--
			-- Locate the plot within this ripple ring that is due West of the Impact Plot.
			local currentX = x - ripple_radius;
			local currentY = y;
			-- Now loop through the six directions, moving ripple_radius number of times
			-- per direction. At each plot in the ring, add the ripple_value for that ring 
			-- to the plot's entry in the distance data table.
			for direction_index = 1, 6 do
				for plot_to_handle = 1, ripple_radius do
					-- Must account for hex factor.
				 	if currentY / 2 > math.floor(currentY / 2) then -- Current Y is odd. Use odd table.
						plot_adjustments = odd[direction_index];
					else -- Current Y is even. Use plot adjustments from even table.
						plot_adjustments = even[direction_index];
					end
					-- Identify the next plot in the ring.
					nextX = currentX + plot_adjustments[1];
					nextY = currentY + plot_adjustments[2];
					-- Make sure the plot exists
					if wrapX == false and (nextX < 0 or nextX >= iW) then -- X is out of bounds.
						-- Do not add ripple data to this plot.
					elseif wrapY == false and (nextY < 0 or nextY >= iH) then -- Y is out of bounds.
						-- Do not add ripple data to this plot.
					else -- Plot is in bounds, process it.
						-- Handle any world wrap.
						local realX = nextX;
						local realY = nextY;
						if wrapX then
							realX = realX % iW;
						end
						if wrapY then
							realY = realY % iH;
						end
						-- Record ripple data for this plot.
						local ringPlotIndex = realY * iW + realX + 1;
						if impact_table_number == 1 then
							if self.strategicData[ringPlotIndex] > 0 then
								-- First choose the greater of the two, existing value or current ripple.
								local stronger_value = math.max(self.strategicData[ringPlotIndex], ripple_value);
								-- Now increase it by 2 to reflect that multiple civs are in range of this plot.
								local overlap_value = math.min(50, stronger_value + 2);
								self.strategicData[ringPlotIndex] = overlap_value;
							else
								self.strategicData[ringPlotIndex] = ripple_value;
							end
						elseif impact_table_number == 3 then
							if self.bonusData[ringPlotIndex] > 0 then
								-- First choose the greater of the two, existing value or current ripple.
								local stronger_value = math.max(self.bonusData[ringPlotIndex], ripple_value);
								-- Now increase it by 2 to reflect that multiple civs are in range of this plot.
								local overlap_value = math.min(50, stronger_value + 2);
								self.bonusData[ringPlotIndex] = overlap_value;
							else
								self.bonusData[ringPlotIndex] = ripple_value;
							end
						elseif impact_table_number == 4 then
							if self.fishData[ringPlotIndex] > 0 then
								-- First choose the greater of the two, existing value or current ripple.
								local stronger_value = math.max(self.fishData[ringPlotIndex], ripple_value);
								-- Now increase it by 2 to reflect that multiple civs are in range of this plot.
								local overlap_value = math.min(10, stronger_value + 1);
								self.fishData[ringPlotIndex] = overlap_value;
							else
								self.fishData[ringPlotIndex] = ripple_value;
							end
						elseif impact_table_number == 5 then
							self.cityStateData[ringPlotIndex] = 1;
						elseif impact_table_number == 6 then
							if self.naturalWondersData[ringPlotIndex] > 0 then
								-- First choose the greater of the two, existing value or current ripple.
								local stronger_value = math.max(self.naturalWondersData[ringPlotIndex], ripple_value);
								-- Now increase it by 2 to reflect that multiple civs are in range of this plot.
								local overlap_value = math.min(50, stronger_value + 2);
								self.naturalWondersData[ringPlotIndex] = overlap_value;
							else
								self.naturalWondersData[ringPlotIndex] = ripple_value;
							end
						end
					end
					currentX, currentY = nextX, nextY;
				end
			end
		end
	else
		print("Unsupported Radius length of ", radius, " passed to PlaceResourceImpact()");
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:BalanceCivStarts()
	-- This function will place an Affinity strategic resource and a food resource in the third ring around a Civ's start.
	-- The added Bonus is meant to make the start look more sexy, so to speak.
	-- Third-ring resources will take a long time to bring online, if the civ settles on the start plot, but can make the Planetfall choice more interesting.

	local iW, iH = Map.GetGridSize();
	local wrapX = Map:IsWrapX();
	local wrapY = Map:IsWrapY();
	local odd = self.firstRingYIsOdd;
	local even = self.firstRingYIsEven;
	local basic_food = {};
	local basic_production = {};
	local basic_energy = {};

	for resInfo in GameInfo.Resources() do
		for resourceYieldInfo in GameInfo.Resource_YieldChanges("ResourceType = \"" .. resInfo.Type .. "\"") do
			if(resInfo.ResourceClassType == GameInfo.ResourceClasses["RESOURCECLASS_BASIC"].Type ) then
				if (resourceYieldInfo.YieldType == GameInfo.Yields["YIELD_FOOD"].Type) then
					table.insert(basic_food, resInfo.ID);
				elseif (resourceYieldInfo.YieldType == GameInfo.Yields["YIELD_PRODUCTION"].Type) then
					table.insert(basic_production, resInfo.ID);
				elseif (resourceYieldInfo.YieldType == GameInfo.Yields["YIELD_ENERGY"].Type) then
					table.insert(basic_energy, resInfo.ID);
				elseif (resourceYieldInfo.YieldType == GameInfo.Yields["YIELD_CULTURE"].Type) then
					table.insert(self.basic_culture, resInfo.ID);
				elseif (resourceYieldInfo.YieldType == GameInfo.Yields["YIELD_SCIENCE"].Type) then
					table.insert(self.basic_science, resInfo.ID);
				end
			end
		end
	end	

	self:BasicFood(basic_food);
	self:BasicEnergyProduction(basic_production, true);
	self:BasicEnergyProduction(basic_energy, false);
end

------------------------------------------------------------------------------
function AssignStartingPlots:BasicFood(food)
	--Creates the Food Resources
	local basic_food = GetShuffledCopyOfTable(food);
	local playerFood = table.fill(0, self.iNumCivs);
	local plot = nil;

	for player_num = 1, self.iNumCivs, 1 do
		if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
			local x = self.startingPlots[player_num][1];
			local y = self.startingPlots[player_num][2];

			for loop, direction in ipairs(self.direction_types) do
				local adjacentPlot = Map.PlotDirection(x, y, direction)
				if (adjacentPlot ~= nil) then
					playerFood[player_num] = playerFood[player_num] + adjacentPlot:GetYield(YieldTypes.YIELD_FOOD);
				end
			end
		end
	end


	for player_num = 1, self.iNumCivs, 1 do
		playerFood[player_num] = math.floor(playerFood[player_num]/3); 
	end

	table.sort(playerFood);
	local averageFood = 0;
	local foodCount = 0;

	for player_num = 1, self.iNumCivs, 1 do
		if(playerFood[player_num] > 0) then
			foodCount = foodCount +1;
		end

		averageFood = averageFood + playerFood[player_num];
	end

	averageFood = math.floor(averageFood/foodCount);
	print("Average Food: ", averageFood);

	for player_num = 1, self.iNumCivs, 1 do
		if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
			playerFood[player_num] = playerFood[player_num] - averageFood;
			local rand = Map.Rand(3, "Resource Radius - Place Resource LUA") - 1;
			playerFood[player_num] = playerFood[player_num] + rand;
			local resourcesToSet = 1;
			local x = self.startingPlots[player_num][1];
			local y = self.startingPlots[player_num][2];
			plot = Map.GetPlot(x, y);

			if playerFood[player_num] > 2 then
				resourcesToSet = 0;
			elseif playerFood[player_num] < 0 then
				resourcesToSet = 2;
			end

			if (self.resource_setting == 4) then
				resourcesToSet = 2;
			end

			print("Resources To Set: ", resourcesToSet);

			for loop, direction in ipairs(self.direction_types) do
				local adjacentPlot = Map.PlotDirection(x, y, direction)
				if (adjacentPlot ~= nil) then
					for i = 1, table.getn(basic_food), 1 do
						local terrainType = adjacentPlot:GetTerrainType();
						if (adjacentPlot:CanHaveResource(basic_food[i]) and not adjacentPlot:IsImpassable() and terrainType ~= TerrainTypes.TERRAIN_TRENCH) then
							if(self:InvalidBorderRegion(terrainType, adjacentPlot:GetX() , adjacentPlot:GetY() ) == false) then
								if(terrainType ~= TerrainTypes.TERRAIN_OCEAN  or (terrainType == TerrainTypes.TERRAIN_OCEAN and self:ReachableByWaterCity(adjacentPlot:GetX() , adjacentPlot:GetY()) == true)) then
									if(resourcesToSet > 0) then
										adjacentPlot:SetResourceType(basic_food[i], 1);
										print("FOOD RESOURCE: ", basic_food[i]);
										basic_food = GetShuffledCopyOfTable(basic_food);
										resourcesToSet = resourcesToSet - 1;
									end
								end
							end
						end
					end
				end	
			end
		end
	end

	--Get the food within 3 hexes
	local outerFood = table.fill(0, self.iNumCivs);
	for player_num = 1, self.iNumCivs, 1 do
		if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then

			local x = self.startingPlots[player_num][1];
			local y = self.startingPlots[player_num][2];
			plot = Map.GetPlot(x, y);

			local radius = 3;
			for dx = -radius, radius do
				for dy = -radius, radius do
					local otherPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, radius);
					if(otherPlot) then
						if otherPlot:IsStartingPlot() then -- Loop through all ever-alive major civs, check if their start plot matches "otherPlot"
							for player_num = 1, self.iNumCivs do
								if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
									local x = self.startingPlots[player_num][1];
									local y = self.startingPlots[player_num][2];
									-- Need to compare otherPlot with this civ's start plot and return false if a match.
									if (not(otherPlot:GetX() == x and otherPlot:GetY() == y)) then
											outerFood[player_num] = outerFood[player_num] + otherPlot:GetYield(YieldTypes.YIELD_FOOD);
									end
								end
							end
						end
					end
				end
			end

			--Do not want the adjacent food
			local radius = 1;
			for dx = -radius, radius do
				for dy = -radius, radius do
					local otherPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, radius);
					if(otherPlot) then
						if otherPlot:IsStartingPlot() then -- Loop through all ever-alive major civs, check if their start plot matches "otherPlot"
							for player_num = 1, self.iNumCivs do
								if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
									local x = self.startingPlots[player_num][1];
									local y = self.startingPlots[player_num][2];
									-- Need to compare otherPlot with this civ's start plot and subtract it.
									if (not(otherPlot:GetX() == x and otherPlot:GetY() == y)) then
										outerFood[player_num] = outerFood[player_num] - otherPlot:GetYield(YieldTypes.YIELD_FOOD);
									end
								end
							end
						end
					end
				end
			end
		end
	end

	for player_num = 1, self.iNumCivs, 1 do
		outerFood[player_num] = math.floor(outerFood[player_num]/3); 
		outerFood[player_num] = outerFood[player_num];
	end

	table.sort(outerFood);
	local averageOuterFood = 0;
	local foodOuterCount = 0;

	for player_num = 1, self.iNumCivs, 1 do
		if(outerFood[player_num] >= 0) then
			foodOuterCount = foodOuterCount +1;
		end

		averageOuterFood = averageOuterFood + outerFood[player_num];
	end

	averageFood = math.floor(averageOuterFood/foodOuterCount);

	for player_num = 1, self.iNumCivs, 1 do
		if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
			outerFood[player_num] = outerFood[player_num] - averageOuterFood;
			local rand = Map.Rand(3, "Resource Radius - Place Resource LUA") - 1;
			outerFood[player_num] = outerFood[player_num] + rand;
			local resourcesToSet = 1;
			local x = self.startingPlots[player_num][1];
			local y = self.startingPlots[player_num][2];
			plot = Map.GetPlot(x, y);

			if outerFood[player_num] > -1 and outerFood[player_num] < 2 then
				resourcesToSet = 1;
			elseif outerFood[player_num] > 2 then
				resourcesToSet = 0;
			else 
				resourcesToSet = 2;
			end

			if (self.resource_setting == 4) then
				resourcesToSet = 2;
			end

			print("Resources To Set Outer: ", resourcesToSet);

			if (resourcesToSet > 0) then
				self.resourcesSet = resourcesToSet;
				if (self.resource_setting == 4) then
					self:SetResources(basic_food, plot, 1);
				else
					self:SetResources(basic_food, plot, 1 + resourcesToSet);
				end

				self.reach = true;
				if(self.resourcesSet > 0 ) then 
					local culture = {};
					culture = self.basic_science;
					self:SetResources(self.basic_culture, plot, 1);
				end 

				if(self.resourcesSet > 0 ) then 
					local science = {};
					science = self.basic_science;
					self:SetResources(self.basic_science, plot, 1);
				end 

				self.reach = false;

				if(self.resourcesSet > 0) then
					print("ERROR STILL NEED TO SET RESOURCES");
				end
			end
		end
	end
end

------------------------------------------------------------------------------
function AssignStartingPlots:BasicEnergyProduction(resource, isProduction)
	local basic_resource = GetShuffledCopyOfTable(resource);
	local playerRes = table.fill(0, self.iNumCivs);
	local production = isProduction;
	print("Resources To Set Outer ProductionOrEnergy: ", resourcesToSet);

	if(production == true) then
		print("Production");
	else
		print("Energy");
	end

	--Get the Energy or Production within 3 hexes
	for player_num = 1, self.iNumCivs, 1 do
		if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then

			local x = self.startingPlots[player_num][1];
			local y = self.startingPlots[player_num][2];
			plot = Map.GetPlot(x, y);

			local radius = 3;
			for dx = -radius, radius do
				for dy = -radius, radius do
					local otherPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, radius);
					if(otherPlot) then
						if otherPlot:IsStartingPlot() then -- Loop through all ever-alive major civs, check if their start plot matches "otherPlot"
							for player_num = 1, self.iNumCivs do
								if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
									local x = self.startingPlots[player_num][1];
									local y = self.startingPlots[player_num][2];
									-- Need to compare otherPlot with this civ's start plot and return false if a match.
									if (not(otherPlot:GetX() == x and otherPlot:GetY() == y)) then
										if(production == true) then
											playerRes[player_num] = playerRes[player_num] + otherPlot:GetYield(YieldTypes.YIELD_PRODUCTION);
										else
											playerRes[player_num] = playerRes[player_num] + otherPlot:GetYield(YieldTypes.YIELD_ENERGY);
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	for player_num = 1, self.iNumCivs, 1 do
		playerRes[player_num] = math.floor(playerRes[player_num]/3); 
		playerRes[player_num] = playerRes[player_num];
	end

	table.sort(playerRes);
	local averageRes = 0;
	local playerResCount = 0;

	for player_num = 1, self.iNumCivs, 1 do
		if(playerRes[player_num] >= 0) then
			playerResCount = playerResCount +1;
		end

		averageRes = averageRes + playerRes[player_num];
	end

	averageRes = math.floor(averageRes/playerResCount);

	for player_num = 1, self.iNumCivs, 1 do
		if(self.startingPlots[player_num][1] ~= nil and self.startingPlots[player_num][2] ~= nil) then
			playerRes[player_num] = playerRes[player_num] - averageRes;
			local rand = Map.Rand(3, "Resource Radius - Place Resource LUA") - 1;
			playerRes[player_num] = playerRes[player_num] + rand;
			local resourcesToSet;
			local x = self.startingPlots[player_num][1];
			local y = self.startingPlots[player_num][2];
			plot = Map.GetPlot(x, y);

			if playerRes[player_num] > -1 and playerRes[player_num] < 2 then
				resourcesToSet = 1;
			elseif playerRes[player_num] > 2 then
				resourcesToSet = 0;
			else 
				resourcesToSet = 2;
			end

			if (self.resource_setting == 4) then
				resourcesToSet = 3;
			end

			print("Resources To Set Outer ProductionOrEnergy: ", resourcesToSet);

			if (resourcesToSet > 0) then
				self.resourcesSet = resourcesToSet;
				local iStart = 4 - resourcesToSet;

				if(plot:IsWater()) then
					iStart = iStart - 1;
				end

				if (self.resource_setting == 4) then
					self:SetResources(basic_resource, plot, 1);
				else
					self:SetResources(basic_resource, plot, iStart);
				end

				self.reach = true;
				if(self.resourcesSet > 0 ) then 
					local culture = {};
					culture = self.basic_science;
					self:SetResources(self.basic_culture, plot, 1);
				end 

				if(self.resourcesSet > 0 ) then 
					local science = {};
					science = self.basic_science;
					self:SetResources(self.basic_science, plot, 1);
				end 

				self.reach = false;
				if(self.resourcesSet > 0) then
					print("ERROR STILL NEED TO SET RESOURCES");
				end
			end
		end
	end
end

------------------------------------------------------------------------------
function AssignStartingPlots:SetResources(resources, startPlot, targetRange, plotIndex, count)
	--Sets resources using rescursion
	local shuffledResources = GetShuffledCopyOfTable(resources);
	local plot = startPlot;

	if (plot == nil) then
		return;
	end

	local target = targetRange;
	local plotIndex = plotIndex or {};
	local count = count or 1;
	local x = plot:GetX();
	local y = plot:GetY();
	table.insert(plotIndex, plot:GetPlotIndex());

	if(count > 3 or self.resourcesSet <= 0) then
		return;
	end

	local numDirections = DirectionTypes.NUM_DIRECTION_TYPES;
	local direction = Game.Rand(numDirections, "direction");
	for loop = 0, numDirections - 1, 1 do
		local valid = true;
		local adjacentPlot = Map.PlotDirection(x, y, direction);

		if (self.resourcesSet <= 0) then
			return
		end

		--Checks to make sure the plot has not been processed
		for i, index in ipairs(plotIndex) do
			if (adjacentPlot == nil or (index ~= nil and index == adjacentPlot:GetPlotIndex())) then
				valid = false;
			end
		end

		--Place the resource
		if (adjacentPlot ~= nil and valid == true) then
			if(count >= targetRange) then
				shuffledResources = GetShuffledCopyOfTable(shuffledResources);
				for i = 1, table.getn(shuffledResources), 1 do
					local terrainType = adjacentPlot:GetTerrainType();
					if (adjacentPlot:CanHaveResource(shuffledResources[i]) and not adjacentPlot:IsImpassable() and terrainType ~= TerrainTypes.TERRAIN_TRENCH) then
						if(self:InvalidBorderRegion(terrainType, adjacentPlot:GetX() , adjacentPlot:GetY() ) == false) then
							if(terrainType ~= TerrainTypes.TERRAIN_OCEAN  or (terrainType == TerrainTypes.TERRAIN_OCEAN and self:ReachableByWaterCity(adjacentPlot:GetX() , adjacentPlot:GetY() ) == true) or (terrainType == TerrainTypes.TERRAIN_OCEAN and self.reach == true)) then
								if(self.resourcesSet > 0) then
									local quantity = 1;
									local quantityTable = {};
									local amountTotal = 0;
									for resInfo in GameInfo.Resources() do
										for resourceQuantityInfo in GameInfo.Resource_QuantityTypes("ResourceType = \"" .. resInfo.Type .. "\"") do
											local id = resInfo.ID;
											if(shuffledResources[i] == id) then
												local inputSetting = 2;
												if (resourceQuantityInfo.Setting == 1 or resourceQuantityInfo.Setting == 3) then
													inputSetting = resourceQuantityInfo.Setting;
												end
												if(resourceQuantityInfo.Max ~= nil and resourceQuantityInfo.Min ~= nil and ( inputSetting == self.resource_setting  or  self.resource_setting > 3)) then
													local min = resourceQuantityInfo.Min;
													local max = resourceQuantityInfo.Max;
													local quantityNumber = self:Quantities(id,amountTotal, min,max);
													table.insert(quantityTable, quantityNumber);
													--print("Resource: ", resInfo.Type, " Minimum: ", min, " Maximum: ", max, " Quantity: ", quantityNumber);
													amountTotal = amountTotal + 1;
												end
											end
										end
									end
								
									if(quantityTable ~= nil or quantityTable[1] ~= nil or quantityTable[1] > 0) then
										table.sort(quantityTable);
										quantity = quantityTable[1];
									end

									--Double Check
									if(quantityTable == nil or quantityTable[1] == nil or quantityTable[1] < 1) then
										quantity = 1;
									end
									
									if(adjacentPlot:CanHaveResource(shuffledResources[i])) then
										adjacentPlot:SetResourceType(shuffledResources[i], quantity);
										print("Set Resource: ", shuffledResources[i]);
										self.resourcesSet = self.resourcesSet - 1;
									end
								end
							end
						end
					end
				end
			end
		end

		self:SetResources(shuffledResources, adjacentPlot, target, plotIndex, count+1);
	end

	direction = direction + 1;
	if (direction == numDirections - 1) then
		direction = 0;
	end
end
	
function AssignStartingPlots:RelaxMiasmaNearStartLocations()
	-- By default, miasma is cleared on top of and immediately adjacent to start locations
	-- This could be exposed to modding later on if we add miasma-based game settings

	for i, startData in ipairs(self.startingPlots) do

		local x = startData[1];
		local y = startData[2];
		local plot = Map.GetPlot(x, y);

		if plot ~= nil then
			if plot:HasMiasma() then
				plot:SetMiasma(false);
			end

			-- Now loop through adjacent plots. Using Map.PlotDirection() in combination with
			-- direction types, an alternate first-ring hex adjustment method, instead of the
			-- odd/even tables used elsewhere in this file, which often have to process more rings.
			for loop, direction in ipairs(self.direction_types) do
				local adjPlot = Map.PlotDirection(x, y, direction)
				if adjPlot ~= nil then
					if adjPlot:HasMiasma() then
						adjPlot:SetMiasma(false);
					end
				end
			end
		end		
	end

	for i, startData in ipairs(self.startingWaterPlots) do

		local x = startData[1];
		local y = startData[2];
		local plot = Map.GetPlot(x, y);

		if plot ~= nil then
			if plot:HasMiasma() then
				plot:SetMiasma(false);
			end

			-- Now loop through adjacent plots. Using Map.PlotDirection() in combination with
			-- direction types, an alternate first-ring hex adjustment method, instead of the
			-- odd/even tables used elsewhere in this file, which often have to process more rings.
			for loop, direction in ipairs(self.direction_types) do
				local adjPlot = Map.PlotDirection(x, y, direction)
				if adjPlot ~= nil then
					if adjPlot:HasMiasma() then
						adjPlot:SetMiasma(false);
					end
				end
			end
		end		
	end
end
------------------------------------------------------------------------------
function AssignStartingPlots:PlaceResourcesAndCityStates()

	-- This function controls nearly all resource placement. Only resources
	-- placed during Normalization operations are handled elsewhere.
	--
	-- BE has dropped the idea of City States and Luxury resources. Only strategic and basic resources remain.
	
	local regionTypes : table = 
		{
			GameInfo.MapRegions["MAP_REGION_LAND_CONTINENT"].ID;
			GameInfo.MapRegions["MAP_REGION_LAND_CONTINENT"].ID;
			GameInfo.MapRegions["MAP_REGION_LAND_CONTINENT"].ID;
			GameInfo.MapRegions["MAP_REGION_WATER_ISLANDS"].ID;
			GameInfo.MapRegions["MAP_REGION_WATER_ISLANDS"].ID;
			GameInfo.MapRegions["MAP_REGION_WATER_OCEAN"].ID;
			GameInfo.MapRegions["MAP_REGION_WATER_OCEAN"].ID;
			GameInfo.MapRegions["MAP_REGION_WATER_OCEAN"].ID;
		};
	
	MapGenerator.CalculateRegions(regionTypes);
	local fertilityMap : table = CalculateFertilityMap();

	-- BE Function: Place the resources
	self:CreateResources(fertilityMap);
	self:BalanceCivStarts();

	-- Relax miasma near start locations
	self:RelaxMiasmaNearStartLocations();

	-- This operation must be saved for last, as it invalidates all regional data by resetting Area IDs.
	Map.RecalculateAreas();
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                             REFERENCE
------------------------------------------------------------------------------
--[[
Notes for Civ:BE

1. Wild Areas (that are defined before starts are chosen) and canyon plots are ignored by regional division.

2. Start locations attempt to avoid any substantial patches of Wild Area, especially the "Core" plots.

3. Natural Wonders, City States, and Luxury resources are removed.

4. Stations were handled in here temporarily, but migrated to the game core later.

5. Firaxite, Float Stone and Xenomass are "Affinity" or "Key" strategic resources. They
are visible from game start but have no early game applications. Geothermal, 
Petroleum and Titanium are hidden at start but have early game applications. The
rest of the resources are "Basic" and primarily offer plot-yield improvement.

6. Most of the Key resources are specifically placed inside the "Wild Areas" where the aliens
and alien nests spawn the most intently. Civs will have to contend with the aliens, one way
or another, to obtain substantial quantities of these resources.

7. Structural changes were made in numerous areas and functions for resource distribution.

------------------------------------------------------------------------------
-- Wildness Values Table
--
-- 10: Core plot, Forest.
-- 11: Periphery plot, Forest.
-- 12: Border plot, Forest.
-- 13: Ground Zero plot, Forest.
--
-- 20: Core plot, Desert.
-- 21: Periphery plot, Desert.
-- 22: Border plot, Desert.
-- 23: Ground Zero plot, Desert.
--
-- 30: Core plot, Tundra.
-- 31: Periphery plot, Tundra.
-- 32: Border plot, Tundra.
-- 33: Ground Zero plot, Tundra.
--
-- 40: Core plot, Ocean.
-- 41: Periphery plot, Ocean.
-- 43: Ground Zero plot, Ocean.
--
------------------------------------------------------------------------------

-- Reference Section from Civ5.

APPENDIX A - ORDER OF OPERATIONS

1. StartPlotSystem() is called from MapGenerator() in MapGenerator.lua

2. If left to default, StartPlotSystem() executes. However, since the core map
options (World Age, etc) are now custom-handled in each map script, nearly every
script needs to overwrite this function to process the Resources option. Many
scripts also need to pass in arguments, such as division method or bias adjustments.

3. AssignStartingPlots.Create() organizes the table that includes all member
functions and all common data.

4. AssignStartingPlots.Create() executes __Init() and __InitLuxuryWeights() to
populate data structures with values applicable to the current game and map. An
empty override is also provided via __CustomInit() to allow for easy modifications
on a small scale, instead of needing to replace all of the Create() function: for
instance, if a script wants to change only a couple of values in the self dot table.

5. AssignStartingPlots:DivideIntoRegions() is called. This function and its
children carry out the creation of Region Data, to be acted on by later methods.
-a. Division method is chosen by parameter. Default is Method 2, Continental.
-b. Four core methods are included. Refer to the function for details.
-c. If applicable, start locations are assigned to specific Areas (landmasses).
-d. Each populated landmass is processed. Any with more than one civ assigned 
to them are divided in to Regions. Any with one civ are designated as a Region.
If a Rectuangular method is chosen, the map is divided without regard to Areas.
-e. Regional division occurs based on "Start Placement Fertility" measurements,
which are hard-coded in the function that measures the worth of a given plot. To
change these values for a script or mod, override the applicable function.
-f. All methods generate a database of Regions. The data includes coordinates
of the southwest corner of the region, plus width and height. If width or 
height, counting from the SW corner, would exceed a map edge, world-wrap is 
implied. As such, all processes that act on Regions need to account for wrap.
Other data included are the AreaID of the region (-1 if a division method in
use that ignores Areas), the total Start Placement Fertility measured in that
region, the total plot count of the region's rectangle, and fertility/plot. (I 
was not told until later that no Y-Wrap support would be available. As such, 
the entire default system is wired for Y-Wrap support, which seems destined to 
lie dormant unless this code is re-used with Civ6 or some other game with Y-Wrap.)

6. AssignStartingPlots:ChooseLocations() is called.
-a. Each Region defined in self.regionData has its terrain types measured.
-b. Using the terrain types, each Region is classified. The classifications
should match the definitions in Regions.XML -- or Regions.xml needs to be 
altered to match the internal classifications of any modified process. The 
Regional classifications affect favored types of terrain for the start plot
selection in that Region, plus affect matching of start locations with those
civilizations who come with Terrain Bias (preferring certain conditions to 
support their specific abilities), as well as the pool from which the Region's
Luxury type will be selected.
-c. An order of processing for Regions is determined. Regions of lowest average
fertility get their start plots chosen first. When a start plot is selected, it
creates a zone around itself where any additional starts will be reluctant to
appear, so the order matters. We give those with the worst land the best pick
of the land they have, while those with the best land will be the ones (if any)
to suffer being "pushed around" by proximity to already-chosen start plots.
-d. Start plots are chosen. There is a method that forces starts to occur along
the oceans, another method that allows for inland placement, and a third method
that ignores AreaID and instead looks for the most fertile Area available.

7. AssignStartingPlots:BalanceAndAssign() is called.
-a. Each start plot is evaluated for land quality. Those not meeting playable
standards are modified via adding Bonus Resources, Oases, or Hills. Ice, if
any, is removed from the waters immediately surrounding the start plot.
-b. The civilizations active in the current game are checked for Terrain Bias.
Any civs with biases are given first pick of start locations, seeking their
particular type of bias. Then civs who have a bias against certain terrain
conditions are given pick of what is left. Finally, civs without bias are
randomly assigned to the remaining regions.
-c. If the game is a Team game, start locations may be exchanged in an effort
to ensure that teammates start near one another. (This may upset Biases).

8. AssignStartingPlots:PlaceNaturalWonders() is called.
-a. All plots on the map are evaluated for eligibility for each Natural
wonder. Map scripts can overwrite eligibility calculations for any given NW
type, where desired. Lists of candidate plots are assembled for each NW.
-b. Some NW's with stricter eligibility may be prioritized to always appear
when eligible. The number of NWs that are eligible is checked against the 
map. If the map can support more than the number allowed for that game (based
on map size), then the ones that will be placed are selected at random.
-c. The order of placement gives priority to any "always appear if eligible"
wonders, then priority after that goes to the wonder with the fewest candidates.
-d. There are minimum distance considerations for both civ starts and other
Natural Wonders, reflected in the Impact Data Layers. If collisions eliminate
all of a wonder's candidate plots, then a replacement wonder will be "pulled 
off the bench and put in the game", if such a replacement is available.

9. AssignStartingPlots:PlaceResourcesAndCityStates() is called.
-a. Luxury resources are assigned roles. Each Region draws from a weighted
pool of Luxury types applicable to its dominant terrain type. This process
occurs according to Region Type, with Type 1 (Tundra) going first. Where
multiple regions of the same type occur, those within each category are
randomized in the selection order. When all regions have been matched to a
Luxury type (and each Luxury type can be spread across up to three regions)
then the City States pick three of the remaining types, at random. The
number of types to be disabled for that map size are removed, then the 
remainder are assigned to be distributed globally, at random. Note that all
of these values are subject to modification. See Great Plains, for example.
-b. City States are assigned roles. If enough of them (1.35x civ count, at 
least), then one will be assigned to each region. If the CS count way
exceeds the civ count, multiple CS may be assigned per region. Of those
not assigned to a region off the bat, the land of the map must be evaluated
to determine how much land exists outside of any region (if any). City
States get assigned to these "Uninhabited" lands next. Then we check for
any Luxuries that got split three-ways (a misfortune for those regions)
and, if there are enough unassigned CS remaining to give each such region
a bonus CS, this is done. Any remaining CS are awarded to Regions with the
lowest average fertility per land plot (and bound to have more total land
around as a result).
-c. The city state locations are chosen. Two methods exist: regional
placement, which strongly favors the edges of regions (civ starts strongly
favor the center of regions), and Uninhabited, which are completely random.
-d. Any city states that were unable to be placed where they were slated to 
go (due to proximity collisions, aka "overcrowded area", then are moved to 
a "last chance" fallback list and will be squeezed in anywhere on the map 
that they can fit. If even that fails, the city state is discarded.
-e. Luxury resources are placed. Each civ gets at least one at its start
location. Regions of low fertility can get up to two more at their starts.
Then each city state gets one luxury, the type depending on what is 
possible to place at their territory, crossed with the pool of types
available to city states in that game. Then, affected by what has already
been placed on the map, the amount of luxuries for each given region are
determined and placed. Finally, based on what has been placed so far, the
amount of the remaining types is determined, and they are placed globally.
-f. Each civ is given a second Luxury type at its start plot (except in 
games using the Resources core map option available on most scripts, and
choosing the Sparse setting.) This second Luxury type CAN be Marble, which
boosts wonder production. (Marble is not in the normal rotation, though.)
-g. City State locations low on food (typical) or hammers get some help
in the normalization process: mostly food Bonus resources.
-h. Strategic resources are placed globally. The terrain balance greatly
affects location and quantity of various types and their balance. So the
game is going to play differently on different map scripts.
-i. Bonus resources are distributed randomly, with weightings. (Poor 
terrain types get more assistance, particularly the Tundra. Hills regions
get extra Bonus support as well.)
-j. Various cleanup operations occur, including placing petroleum in the sea, 
fixing Sugar terrain -- and as the very last item, recalculating Area IDs, 
which invalidates the entire Region Data pool, so it MUST come last.

10. Process ends. Map generation continues according to MapGenerator()
------------------------------------------------------------------------------

APPENDIX B - ADVICE FOR MODDERS

Depending upon the game areas being modified, it may be necessary to modify
the start placement and resource distribution code to support your effort.

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
If you are modifying Civilizations:

* You can plug your new or modified civilizations in to the Terrain Bias 
system via table entries in Civ5Civilizations.xml

1. Start Along Ocean
2. Start Along River		-- Ended up inactive for the initial civ pool, but is operational in the code.
3. Start Region Priority
4. Start Region Avoid

Along Ocean is boolean, defaulting to false, and is processed first, 
overriding all other concerns. Along River is boolean and comes next.

Priority and Avoid refer to "region types", of which there are eight. Each 
of these region types is dominated by the associated terrain.
1. Tundra
2. Jungle
3. Forest
4. Desert
5. Hills
6. Plains
7. Grass
8. Hybrid (of plains and grass).

The defintions are sequential, so that a region that might qualify for
more than one designation gets the lowest-number it qualifies for.

The Priority and Avoid can be multiple-case. There are multiple-case Avoid
needs in the initial Civ pool, but only single-case Priority needs. This is
because the single-case needs have a fallback method that will place the civ
in the region with the most of its favored terrain type, if no region is 
available that is dominated by that terrain. Whereas any Civ that has multiple
Priority needs must find an exact region match to one of its needs or it gets
no bias. Thus I found that all of the biases desired for the initial Civ pool
were able to be met via single Priority.

Any clash between Priority and Avoid, Priority wins. 

I hope you enjoy this new ability to flavor and influence start locations.
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
If you are modifying Resources:

XML no longer plays any role whatsoever on the distribution of Resources, but
it does still define available resource types and how they will interact with
the game.

Do not place a Luxury resource type at the top of the list, in ID slot #0.
Other than that, you can do what you will with the list and how they are ordered.

Be warned, there is NO automatic handling of resource balance and appearance for
new or modified resource types. Gone is the Civ4 method of XML-based terrain
permissions. Gone is plug-and-play with new resource types. If you remove any
types from the list, you will need to disable the hard-coded handling of those
types present in the resource distribution. If you modify or add types, you will
not see them in the game until you add them to the hard-coded distribution.

The distribution is handled wholly within this file, here in Lua. Whether you 
approve of this change is your prerogative, but it does come with benefits in
the form of greatly increased power over how the resources are placed.

Bonus resources are used as the primary method for start point balancing, both
for civs and city states. Bonus Resources do nothing at all other than affect
yields of an individual tile and the type of improvement needed in that tile.

If you modify or add bonus resources, you may want to modify Normalization
methods as well, so your mod interacts with this subsystem. These are the 
methods involved with Bonus resource normalization:

AttemptToPlaceBonusResourceAtPlot()
AttemptToPlaceHillsAtPlot()
AttemptToPlaceSmallStrategicAtPlot()
NormalizeStartLocation()
NormalizeCityState()
NormalizeCityStateLocations()	-- Dependent on PlaceLuxuries being executed first.
AddExtraBonusesToHillsRegions()

Strategic Resources are now quantified, so their placement is no longer of the
nature of on/off, and having extra of something may help. Strategics are no longer
a significant part of the trading system. As such, their balance is looser in
Civ5 than it had to be in Civ4 or Civ3. Strategics are now placed globally, but
you can modify this to any method you choose. The default method is here:

PlaceStrategicAndBonusResources()

And it primarily relies upon the per-tile approach of this method:

ProcessResourceList()

Bonus resources are the same, for their global distribution. Additional functions
that provide custom handling are here:

AddStrategicBalanceResources()	-- Only called when this game launch option is in effect.
PlaceSmallQuantitiesOfStrategics()
PlaceFish()
PlaceSexyBonusAtCivStarts()
PlaceOilInTheSea()
FixSugarJungles()

All three types of Resources, which each play a different role in the game, are
dependent upon the new "Impact and Ripple" data layers to detect previously
placed instances and remain at appropriate distances. By replacing a singular,
hardcoded "minimum distance" with the impact-and-ripple, I have been able to
introduce variable distances. This creates a less contrived-looking result and
allows for some clustering of resources without letting the clusters grow too 
large, and without predetermining the nature and distribution of clusters. You
can most easily understand the net effect of this change by examing the fish
distribution. You will see that is less regular than the Civ4 method, yet still
avoids packing too many fish in to any given area. Larger clusters are possible
but quite rare, and the added variance should make city placement more interesting.

Another benefit of the Impact and Ripple is that it is Hex Accurate. The ripples
form a true hexagon (radiating outward from the impact plot, with weightings and
biases weakening the farther away from the impact it sits) instead of a rectangle
defined by an x-y coordinate area scan.

What this means for you, as a Resources modder, is that you will need to grasp
the operation of Impact and Ripple in order to properly calibrate any placements
of resources that you decide to make. This is true for all three types. Each has
its own layer of Impact and Ripple, but you could choose to remove a resource 
from participation in a given layer, assign it to a different layer or to its own
layer, or even discard this method and come up with your own. Realize that each
resource placed will impact its layer, rippling outward from its plot to whatever
radius range you have selected, and then bar any later placements from being close
to that resource.

Everywhere in this code that a civ start is placed, or a city state, or a resource,
there are associated Impacts and Ripples on one or more data layers. The 
interaction of all this activity is why a common database was needed. Yet because
none of this data affects the game after game launch and the map has been set, it 
is all handled locally here in Lua, then is discarded and its memory recycled.

Meanwhile, Luxury resources are more tightly controlled than ever. The Regional
Division methods are as close to fair as I could make them, considering the highly
varied and unpredicatable landforms generated by the various map scripts. They
are fair enough to form a basis for distributing Luxuries in a way to create
supply and demand, to foster trade and diplomacy.


All Luxury resource placements are handled via this method:

PlaceSpecificNumberOfResources()

This method also handles placement of sea-based sources of petroleum.


Like ProcessResourceList(), this method acts upon a plot list fed to it, but 
instead of handling large numbers of plots and placing one for every n plots, it
tends to handle much smaller number of plots, and will return the number it was
unable to place for whatever reason (collisions with the luxury data layer being
the main cause, and not enough members in the plot list to receive all the
resources being placed is another) so that fallback methods can try again.

As I mentioned earlier, XML no longer governs resource placement. Gone are the 
XML terrain permissions, a hardwired "all or nothing" approach that could allow
a resource to appear in forest (any forest), or not. The new method allows for 
more subtlety, such as creating a plot list that includes only forests on hills,
or which can allow a resource to appear along rivers in the plains but only 
away from rivers in grasslands. The sky is the limit, now, when it comes to 
customizing resource appearance. Any method you can measure and implement, and
translate in to a list of candidate plots, you can apply here.

The default permissions are now contained in an interaction between two married
functions: terrain-based plot lists and a function matching each given resource
to a selection of lists appropriate to that resource.

The three list-generating functions are these:

GenerateGlobalResourcePlotLists()
GenerateLuxuryPlotListsAtCitySite()
GenerateLuxuryPlotListsInRegion()


The indexing function is:

GetIndicesForLuxuryType()


The process uses one of these three list generations (depending on whether it 
is currently trying to assign Luxuries globally, regionally, or in support of
a specific civ or city state start location).

Other methods determine WHICH Luxury fits which role and how much of it to place;
then these processes come up with candidate plot lists, and then the indexing
matches the appropriate lists to the specific luxury type. Finally, all of this
data is passed to the function that actually places the Luxury, which is:

PlaceSpecificNumberOfResources()


If you want to modify the terrain permissions of existing Luxury types, you 
need only handle the list generators and the indexing function.


If you want to modify which Luxury types get assigned to which Region types:

__InitLuxuryWeights()
IdentifyRegionsOfThisType()
SortRegionsByType()
AssignLuxuryToRegion()

All weightings for regional matching are contained here. But beware, the
system has to handle up to 22 civilizations and 41 city states, so the 
combination of self.iNumMaxAllowedForRegions and the number of regions to
which any given Luxury can be assigned must multiply out to more than 22.

The default system allows up to 8 types for regions, up to 3 regions per type,
factoring out to 24 maximum allowable, barely enough to cover 22 civs.

Perhaps in an Expansion pack, more Luxury types could be added, to ease the
stress on the system. As it is, I had to spend a lot of political capital 
with Jon to get us to Fifteen Luxury Types, and have enough to make this
new concept and this new system work. The amount is plenty for the default
numbers of civs for each map size, though. If too many types come available
in a given game, it could upset the game balance regarding Health and Trade.


If you wish to add new Luxury types, there is quite a bit involved. You will 
either have to plug your modifications in to the existing system, or replace
the entire system. I have worked to make it as easy as possible to interact
with the new system, documenting every function, every design element. And
since this entire system exists here in Lua, nothing is beyond your reach.

The "handy resource ID shortcuts" will free you from needing to order the
luxuries in the XML in any particular fashion. These IDs will adapt to the
XML list. But you will have to create new shortcuts for any added or renamed
Luxury types, and activate the shortcuts here:

__Init()

You will also need to deactivate or remove any code handling luxury types
that your mod removes. I recommend using an editor with a Find feature and 
scan the file for all instances of keys that you want to remove. At each
instance found, if the key is in a group, you can safely remove it from 
the group so long as the group retains at least one key in it. If the key
is the only one being acted upon, you may need to replace it with a different
key or else deactivate that chunk of code. (If the method attempts to act
upon a nil-value key, that will cause an Assert and the start finder will
exit without finishing all of its operations.)

If you are going to plug in to the new system, you need to determine if the
default terrain-based plot lists meet your needs. If not, create new list 
types for all three list-generation methods and index them as applicable.

GenerateGlobalResourcePlotLists()
GenerateLuxuryPlotListsAtCitySite()
GenerateLuxuryPlotListsInRegion()
GetIndicesForLuxuryType()

You will also need to modify functions that determine which Luxury types
can be placed at City States (this affects which luxury each receives).

GetListOfAllowableLuxuriesAtCitySite()


Finally, the command center of Luxury Distribution is here:

PlaceLuxuries()
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
If you are modifying Terrain:

You will need to update every aspect of the new system to make it operate
correctly on your terrain changes. Or you will need to replace the entire system.

I'm sorry if that is bad news, but if you modified Terrain for Civ4, you likely
experienced it being applied inconsistently (not working on lots of map scripts)
and ran in to barriers where something you wanted to do was impossible, because
only certain limited permissions were enabled through the XML. You may even have
had to rise to the level of modifying the game core DLLs in C++ to open up more
functionality.

Whatever interactions with the game core your terrain needs to make remain in the
XML and the C++. The only relevant aspects here involve how your terrain interacts
with map generation, start placement, and resource distribution.

I have modified the base map generation methods to include more parameters and
options, so that more of the map scripts can rely on them. This means less 
hardcoding in individual scripts, to where an update to the core methods that 
includes new terrain types or feature types will have a wider reach.

As for start placement and resources, a big part of Jon's vision for Civ5 was to
bring back grandiose terrain, realistically large regions of Desert, Tundra, 
Plains, and so on. But this type of map, combined with the old start generation
method, tended to force starts on grassland, and do other things counter to the
vision. So I designed the new system to more accurately divide the map, not by 
strict tile count, but by relative worth, trying to give each civ as fair a patch
of land as possible. Where the terrain would be too harsh, we would support it
with Bonus resources, which could now be placed in any quantity needed, thanks to
being untied from the trade system. The regonal division divides the map, then
the classification system identifies each region's dominant terrain type and aims
to give the civ who starts there a flavored environment, complete with a start in
or near that type of terrain, enough Bonus to remove the worst cases of "bad luck", 
and a cluster of luxury resources at hand that is appropriate to that region type.

In doing all of this, I have hard-coded the system with countless assumptions 
based on the default terrain. If you wish to make use of this system in tandem 
with new types of terrain or with modified yields of existing terrain, or both,
you will need to rewire the system, mold it to the specific needs of the new
terrain balance that you are crafting.

This begins with the Start Placement Fertility, which is measured per plot here:

MeasureStartPlacementFertilityOfPlot()


Measurements are processed in two ways, but you likely don't need to mod these:

MeasureStartPlacementFertilityInRectangle()
MeasureStartPlacementFertilityOfLandmass()


Once you have regions dividing in ways appropriate to your new terrain, you will
need to update terrain measurements and regional classifications here:

MeasureTerrainInRegions()
DetermineRegionTypes()

You may also have XML work to do in regard to regions. The region list is here:
CIV5Regions.xml

And each Civilization's specific regional or terrain bias is found here:
CIV5Civilizations.xml


Start plot location is a rather sizable operation, spanning half a dozen functions.

MeasureSinglePlot()
EvaluateCandidatePlot()
IterateThroughCandidatePlotList()
FindStart()
FindCoastalStart()
FindStartWithoutRegardToAreaID()
ChooseLocations()

Depending on the nature of your modifications, you may need to recalibrate this 
entire system. However, like with Start Fertility, the core of the system is 
handled at the plot level, evaluating the meaning of each type of plot for each
type of region. I have enacted a simple mechanism at the core, with only four
categories of plot measurement: Food, Prod, Good, Junk. The food label may be
misleading, as this is the primary mechanism for biasing starting terrain. For
instance, in tundra regions I have tundra tiles set as Food, but grass are not.
A desert region sets Plains as Food but Grass is not, while a Jungle region sets
Grass as Food but Plains aren't. The Good tiles act as a hedge, and are the main
way of differentiating one candidate site from another, so that among a group of
plots of similar terrain, the best tends to get picked. I also have the overall
standards set reasonably low to keep the Center Bias element of the system at 
the forefront of start placement. This is chiefly because the exact quality of 
the initial starting location is less urgent than maintaining as good of a 
positioning as possible among civs. Balancing the quality of the start plot
against positioning near the center of each region was a fun challenge to 
tackle, and I feel that I have succeeded in my design goals. Just be aware that
any change loosening the bias toward the center could ripple through the system.

Regional terrain biases that purposely put starts in non-ideal terrain are
intended to be supported via Normalization and other compensations built in to
the system in general. Yet the normalization used in Civ5 is much more lightly
applied than Civ4's methods. The new system modifies the actual terrain as
little as possible, giving support mostly through the addition of Bonus type
resources, which add food. Jon wanted starts to occur in a variety of terrain
yet for each to be competitive. He directed me to use resources to balance it.


If your terrain modifications affect tile yields, or introduce new elements in
to the ecosystem, it is likely your mod would benefit from adjusting the start
site normalization process.

AttemptToPlaceBonusResourceAtPlot()
AttemptToPlaceHillsAtPlot()
AttemptToPlaceSmallStrategicAtPlot()
NormalizeStartLocation()
PlaceSexyBonusAtCivStarts()
AddExtraBonusesToHillsRegions()

City State placement is subordinate to civ placement, in the new system. The 
city states get no consideration whatsoever to the quality of their starts, only
to the location relative to civilizations. So this is the one area of the system
that is likely to be unaffected by terrain mods, except at Normalization:

NormalizeCityState()
NormalizeCityStateLocations()


Finally, a terrain mod is sure to scramble the hard-coded and carefully balanced
resource distribution system. That entire system is predicated upon the nature
of default terrain, what it yields, how the pieces interact, how they are placed
by map scripts, and in general governed by a measured sense of realism, informed
by gameplay needs and a drive for simplicity. From the order of operations upon
regions (sorted by dominant terrain type) to the interwoven nature of resource
terrain preferences, it is unlikely the default implementation will properly 
support any significant terrain mod. The work needed to integrate a terrain mod
in to resource distribution would be similar to that needed for a resource mod,
so I will refer you back to that section of the appendix for additional info.
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
If you are modifying game rules:

The new system is rife with dependencies upon elements in the default rules. This
need not be a barrier to your mod, but it will surely assist in your cause to
be alert to possible side effects of game rules changes. One of the biggest
dependencies lies with rules that govern tile improvements: how much they benefit,
where they are possible to build, when upgrades to their yield output come online
and so forth. Evaluations for Fertility that governs regional division, for 
Normalization that props up weaker locations, and the logic of resource distribution
(such as placing numerous Deer in the tundra to make small cities viable there)
all depend in large part on the current game rules. So if, for instance, your mod
were to remove or push back the activation of yield boost at Fresh Water farms, 
this would impact the accuracy of the weighting that the start finder places on
fresh water plots and on fresh water grasslands in particular. This is the type of
assumption built in to the system now. In a way it is unfriendly to mods, but it 
also provides a stronger support for the default rule set, and sets an example of
how the system could support mods as well, if re-calibrated successfully.

The start placement and resource distribution systems include no mechanism for
automatically detecting game rules modifications, or terrain or resource mods, 
either. So to the degree that your mod may impact the logic of start placement,
you may want to consider making adjustments to the system, to ensure that it
behaves in ways productive to your mod.
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

------------------------------------------------------------------------------

APPENDIX C - ACKNOWLEDGEMENTS

Thanks go to Jon for turning me loose on this system. I had the vision for
this system as far back as the middle of vanilla Civ4 development, but I did
not get the opportunity to act on it until now. Designing, coding, testing 
and implementing my baby here have been a true pleasure. That the effort has
enabled a key element of Jon's overall vision for the game is a pride point.

Thanks to Ed Beach for his brilliant algorithm, which has enhanced the value
and performance of this system to a great degree.

Thanks to Shaun Seckman and Brian Wade for numerous instances of assistance
with Lua programming issues, and for providing the initial ports of Python to
Lua, which gave me an easy launching point for all of my tasks.

Thanks to everyone on the Civ5 development team whom I met on my visit to 
Firaxis HQ in Baltimore, who were so warm and welcoming and supportive. It
has been a joy to be part of such a positive working environment and to 
contribute to a team like this. If every gamer got to see the inside of
the studio and how things really work, I believe they would be inspired.

Thanks to all on the web team, who provided direct and indirect support. I
can't reveal any details here, but each of you knows who you are.

Finally, special thanks to my wife, Jaime, who offered advice, input,
feedback and general support throughout my design and programming effort.

- Robert B. Thomas	(Sirian)		April 26, 2010
]]--
------------------------------------------------------------------------------